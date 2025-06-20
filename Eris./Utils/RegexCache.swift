import Foundation

class RegexCache: MemoryPressureObserver {
    static let shared = RegexCache()
    
    private var cache = NSCache<NSString, NSRegularExpression>()
    private let queue = DispatchQueue(label: "com.eris.regexcache", attributes: .concurrent)
    
    private init() {
        // Configure cache
        cache.countLimit = 50 // Maximum number of cached regex
        
        // Register for memory warnings
        MemoryManager.shared.addObserver(self)
    }
    
    deinit {
        MemoryManager.shared.removeObserver(self)
    }
    
    // MARK: - Cache Operations
    
    func regex(for pattern: String) throws -> NSRegularExpression {
        let key = pattern as NSString
        
        // Try to get from cache
        if let cached = queue.sync(execute: { cache.object(forKey: key) }) {
            return cached
        }
        
        // Create new regex
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        
        // Store in cache
        queue.async(flags: .barrier) {
            self.cache.setObject(regex, forKey: key)
        }
        
        return regex
    }
    
    func clearCache() {
        queue.async(flags: .barrier) {
            self.cache.removeAllObjects()
            print("✓ Cleared regex cache")
        }
    }
    
    // MARK: - MemoryPressureObserver
    
    func didReceiveMemoryWarning() {
        clearCache()
    }
    
    // MARK: - Syntax Highlighting Helpers
    
    func syntaxHighlightingRegex(for language: String) throws -> NSRegularExpression {
        let keywords = getSyntaxKeywords(for: language)
        let pattern = "\\b(\(keywords.joined(separator: "|")))\\b"
        return try regex(for: pattern)
    }
    
    private func getSyntaxKeywords(for language: String) -> [String] {
        switch language.lowercased() {
        case "swift":
            return ["func", "var", "let", "if", "else", "return", "class", "struct", "enum", 
                   "protocol", "extension", "import", "typealias", "guard", "defer", "init",
                   "deinit", "throws", "async", "await", "actor", "some", "any"]
        case "python", "py":
            return ["def", "class", "import", "from", "return", "if", "else", "elif", 
                   "for", "while", "break", "continue", "pass", "lambda", "with", "as",
                   "try", "except", "finally", "raise", "yield", "async", "await"]
        case "javascript", "js", "typescript", "ts":
            return ["function", "const", "let", "var", "if", "else", "return", "class",
                   "extends", "import", "export", "from", "async", "await", "new", "this",
                   "try", "catch", "finally", "throw", "typeof", "instanceof"]
        case "java":
            return ["public", "private", "protected", "class", "interface", "extends",
                   "implements", "import", "package", "return", "if", "else", "for",
                   "while", "do", "break", "continue", "new", "this", "super", "try",
                   "catch", "finally", "throw", "throws", "void", "static", "final"]
        case "go":
            return ["func", "var", "const", "if", "else", "return", "package", "import",
                   "type", "struct", "interface", "map", "range", "for", "switch", "case",
                   "default", "break", "continue", "goto", "defer", "go", "chan", "select"]
        case "rust":
            return ["fn", "let", "mut", "const", "if", "else", "return", "use", "mod",
                   "pub", "struct", "enum", "impl", "trait", "match", "for", "while",
                   "loop", "break", "continue", "async", "await", "move", "ref"]
        case "c", "cpp", "c++":
            return ["int", "float", "double", "char", "void", "if", "else", "return",
                   "for", "while", "do", "break", "continue", "switch", "case", "default",
                   "struct", "class", "public", "private", "protected", "new", "delete",
                   "include", "define", "typedef", "const", "static", "extern"]
        default:
            return ["func", "function", "def", "class", "return", "if", "else", "for",
                   "while", "import", "const", "var", "let"]
        }
    }
}