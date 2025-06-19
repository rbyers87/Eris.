//
//  CodeBlockView.swift
//  Eris.
//
//  Created by Ignacio Palacio on 19/6/25.
//

import SwiftUI

struct CodeBlockView: View {
    let code: String
    let language: String?
    @State private var isCopied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with language and copy button
            HStack {
                if let language = language, !language.isEmpty {
                    Text(language.lowercased())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("code")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    UIPasteboard.general.string = code
                    isCopied = true
                    HapticManager.shared.notification(.success)
                    
                    // Reset after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isCopied = false
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .font(.caption)
                        Text(isCopied ? "Copied" : "Copy")
                            .font(.caption)
                    }
                    .foregroundStyle(isCopied ? .green : .secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.15))
            
            // Code content with syntax highlighting
            ScrollView(.horizontal, showsIndicators: true) {
                SyntaxHighlightedText(code: code, language: language ?? "")
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.gray.opacity(0.1))
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct SyntaxHighlightedText: View {
    let code: String
    let language: String
    
    var body: some View {
        let highlightedCode = highlightSyntax(code, language: language)
        
        Text(AttributedString(highlightedCode))
            .font(.system(.caption, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func highlightSyntax(_ code: String, language: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: code)
        let fullRange = NSRange(location: 0, length: code.count)
        
        // Base text color
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)
        
        // Language-specific highlighting
        switch language.lowercased() {
        case "swift", "python", "javascript", "js", "bash", "shell":
            highlightKeywords(in: attributedString, language: language)
            highlightStrings(in: attributedString)
            highlightComments(in: attributedString)
            highlightNumbers(in: attributedString)
        default:
            // Basic highlighting for unknown languages
            highlightStrings(in: attributedString)
            highlightComments(in: attributedString)
            highlightNumbers(in: attributedString)
        }
        
        return attributedString
    }
    
    private func highlightKeywords(in attributedString: NSMutableAttributedString, language: String) {
        let keywords: [String]
        
        switch language.lowercased() {
        case "swift":
            keywords = ["func", "var", "let", "if", "else", "for", "while", "return", "class", "struct", "enum", "protocol", "import", "private", "public", "internal", "static", "override", "init", "self", "true", "false", "nil", "@Published", "@State", "@StateObject", "@ObservedObject", "@Binding", "@Environment", "async", "await", "try", "catch", "throws"]
        case "python":
            keywords = ["def", "class", "if", "else", "elif", "for", "while", "return", "import", "from", "as", "try", "except", "finally", "with", "lambda", "True", "False", "None", "and", "or", "not", "in", "is", "await", "async"]
        case "javascript", "js":
            keywords = ["function", "var", "let", "const", "if", "else", "for", "while", "return", "class", "import", "export", "from", "new", "this", "true", "false", "null", "undefined", "async", "await", "try", "catch", "finally"]
        case "bash", "shell":
            keywords = ["if", "then", "else", "elif", "fi", "for", "while", "do", "done", "function", "return", "exit", "export", "source", "alias"]
        default:
            keywords = []
        }
        
        let string = attributedString.string
        for keyword in keywords {
            let pattern = "\\b\(keyword)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
                for match in matches {
                    attributedString.addAttribute(.foregroundColor, value: UIColor.systemPurple, range: match.range)
                }
            }
        }
    }
    
    private func highlightStrings(in attributedString: NSMutableAttributedString) {
        let string = attributedString.string
        let patterns = ["\"[^\"]*\"", "'[^']*'", "`[^`]*`"]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
                for match in matches {
                    attributedString.addAttribute(.foregroundColor, value: UIColor.systemRed, range: match.range)
                }
            }
        }
    }
    
    private func highlightComments(in attributedString: NSMutableAttributedString) {
        let string = attributedString.string
        let patterns = [
            "//.*$",           // Single line comments
            "#.*$",            // Python/Shell comments
            "/\\*[\\s\\S]*?\\*/", // Multi-line comments
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) {
                let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
                for match in matches {
                    attributedString.addAttribute(.foregroundColor, value: UIColor.systemGreen, range: match.range)
                }
            }
        }
    }
    
    private func highlightNumbers(in attributedString: NSMutableAttributedString) {
        let string = attributedString.string
        let pattern = "\\b\\d+(\\.\\d+)?\\b"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            for match in matches {
                attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: match.range)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CodeBlockView(
            code: """
            func greet(name: String) -> String {
                // This is a comment
                let greeting = "Hello, \\(name)!"
                return greeting
            }
            
            let result = greet(name: "World")
            print(result) // Output: Hello, World!
            """,
            language: "swift"
        )
        
        CodeBlockView(
            code: """
            def factorial(n):
                # Calculate factorial recursively
                if n <= 1:
                    return 1
                else:
                    return n * factorial(n - 1)
            
            result = factorial(5)
            print(f"5! = {result}")  # Output: 5! = 120
            """,
            language: "python"
        )
    }
    .padding()
}