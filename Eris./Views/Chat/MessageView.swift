//
//  MessageView.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import SwiftUI

struct MessageView: View {
    let content: String
    let isUser: Bool
    
    var body: some View {
        if isUser {
            // User messages with bubble
            Text(content)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.gray)
                )
                .foregroundStyle(.white)
        } else {
            // Assistant messages without bubble, full width
            MarkdownMessageView(content: content)
        }
    }
}

struct MarkdownMessageView: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(parseMarkdown(content), id: \.id) { block in
                switch block.type {
                case .text:
                    Text(block.content)
                        .foregroundStyle(.primary)
                case .header1:
                    Text(block.content)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                case .header2:
                    Text(block.content)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                case .header3:
                    Text(block.content)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                case .bold:
                    Text(block.content)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                case .italic:
                    Text(block.content)
                        .italic()
                        .foregroundStyle(.primary)
                case .bulletPoint:
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(block.content)
                            .foregroundStyle(.primary)
                    }
                case .numberedList:
                    HStack(alignment: .top, spacing: 8) {
                        Text(block.metadata ?? "")
                            .foregroundStyle(.secondary)
                        Text(block.content)
                            .foregroundStyle(.primary)
                    }
                case .code:
                    Text(block.content)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                case .codeBlock:
                    VStack(alignment: .leading, spacing: 4) {
                        if let language = block.metadata {
                            Text(language)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(block.content)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.primary)
                                .padding()
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Simple markdown parser
    private func parseMarkdown(_ text: String) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        var i = 0
        var inCodeBlock = false
        var codeBlockContent = ""
        var codeBlockLanguage: String?
        
        while i < lines.count {
            let line = String(lines[i])
            
            // Check for code block
            if line.starts(with: "```") {
                if inCodeBlock {
                    // End code block
                    if !codeBlockContent.isEmpty {
                        blocks.append(MarkdownBlock(
                            type: .codeBlock,
                            content: codeBlockContent.trimmingCharacters(in: .newlines),
                            metadata: codeBlockLanguage
                        ))
                    }
                    codeBlockContent = ""
                    codeBlockLanguage = nil
                    inCodeBlock = false
                } else {
                    // Start code block
                    inCodeBlock = true
                    codeBlockLanguage = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    if codeBlockLanguage?.isEmpty == true {
                        codeBlockLanguage = nil
                    }
                }
                i += 1
                continue
            }
            
            if inCodeBlock {
                codeBlockContent += line + "\n"
                i += 1
                continue
            }
            
            // Headers
            if line.starts(with: "### ") {
                blocks.append(MarkdownBlock(type: .header3, content: String(line.dropFirst(4))))
            } else if line.starts(with: "## ") {
                blocks.append(MarkdownBlock(type: .header2, content: String(line.dropFirst(3))))
            } else if line.starts(with: "# ") {
                blocks.append(MarkdownBlock(type: .header1, content: String(line.dropFirst(2))))
            }
            // Bold text
            else if line.contains("**") {
                let parts = line.split(separator: "**")
                for (index, part) in parts.enumerated() {
                    if index % 2 == 1 {
                        blocks.append(MarkdownBlock(type: .bold, content: String(part)))
                    } else if !part.isEmpty {
                        blocks.append(MarkdownBlock(type: .text, content: String(part)))
                    }
                }
            }
            // Bullet points
            else if line.starts(with: "- ") || line.starts(with: "* ") {
                blocks.append(MarkdownBlock(type: .bulletPoint, content: String(line.dropFirst(2))))
            }
            // Numbered lists
            else if let match = line.firstMatch(of: /^(\d+)\.\s+(.*)/) {
                let number = String(match.1)
                let content = String(match.2)
                blocks.append(MarkdownBlock(type: .numberedList, content: content, metadata: number + "."))
            }
            // Inline code
            else if line.contains("`") && !line.starts(with: "```") {
                let parts = line.split(separator: "`")
                for (index, part) in parts.enumerated() {
                    if index % 2 == 1 {
                        blocks.append(MarkdownBlock(type: .code, content: String(part)))
                    } else if !part.isEmpty {
                        blocks.append(MarkdownBlock(type: .text, content: String(part)))
                    }
                }
            }
            // Regular text
            else if !line.isEmpty {
                blocks.append(MarkdownBlock(type: .text, content: line))
            }
            
            i += 1
        }
        
        return blocks.isEmpty ? [MarkdownBlock(type: .text, content: text)] : blocks
    }
}

struct MarkdownBlock: Identifiable {
    let id = UUID()
    let type: BlockType
    let content: String
    var metadata: String? = nil
    
    enum BlockType {
        case text
        case header1
        case header2
        case header3
        case bold
        case italic
        case bulletPoint
        case numberedList
        case code
        case codeBlock
    }
}

#Preview {
    VStack(spacing: 20) {
        MessageView(
            content: "Hello, this is a user message",
            isUser: true
        )
        
        MessageView(
            content: """
            **Verificación de Instalación**
            
            Primero, asegúrate de tener Homebrew instalado:
            
            ```bash
            # Instala Homebrew
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            ```
            
            **Instalación de Python**
            
            1. Abre Terminal
            2. Ejecuta el comando: `brew install python3`
            3. Verifica la instalación: `python3 --version`
            
            - Python 3.x es recomendado
            - Incluye pip para gestionar paquetes
            - Compatible con virtual environments
            """,
            isUser: false
        )
    }
    .padding()
}