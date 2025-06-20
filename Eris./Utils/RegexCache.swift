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
        case "ruby", "rb":
            return ["def", "class", "module", "if", "else", "elsif", "unless", "case",
                   "when", "while", "for", "break", "next", "return", "yield", "begin",
                   "rescue", "ensure", "end", "do", "require", "include", "extend", "attr",
                   "private", "public", "protected", "self", "super", "nil", "true", "false"]
        case "php":
            return ["function", "class", "interface", "namespace", "use", "extends", "implements",
                   "public", "private", "protected", "static", "final", "abstract", "if", "else",
                   "elseif", "switch", "case", "default", "for", "foreach", "while", "do", "break",
                   "continue", "return", "try", "catch", "finally", "throw", "new", "echo", "print"]
        case "kotlin", "kt":
            return ["fun", "val", "var", "class", "interface", "object", "companion", "if",
                   "else", "when", "for", "while", "do", "break", "continue", "return", "try",
                   "catch", "finally", "throw", "import", "package", "public", "private", "protected",
                   "internal", "override", "abstract", "open", "data", "suspend", "coroutine"]
        case "csharp", "cs", "c#":
            return ["class", "interface", "struct", "enum", "public", "private", "protected",
                   "internal", "static", "void", "int", "string", "bool", "if", "else", "switch",
                   "case", "default", "for", "foreach", "while", "do", "break", "continue", "return",
                   "try", "catch", "finally", "throw", "using", "namespace", "new", "this", "base",
                   "virtual", "override", "abstract", "async", "await", "var", "const"]
        case "sql":
            return ["SELECT", "FROM", "WHERE", "JOIN", "LEFT", "RIGHT", "INNER", "OUTER",
                   "ON", "AS", "INSERT", "INTO", "VALUES", "UPDATE", "SET", "DELETE", "CREATE",
                   "TABLE", "ALTER", "DROP", "INDEX", "VIEW", "PROCEDURE", "FUNCTION", "TRIGGER",
                   "BEGIN", "END", "IF", "ELSE", "CASE", "WHEN", "THEN", "AND", "OR", "NOT",
                   "NULL", "DISTINCT", "GROUP", "BY", "HAVING", "ORDER", "LIMIT", "OFFSET"]
        case "shell", "bash", "sh":
            return ["if", "then", "else", "elif", "fi", "case", "esac", "for", "while",
                   "do", "done", "function", "return", "exit", "export", "source", "alias",
                   "echo", "printf", "read", "cd", "ls", "mkdir", "rm", "cp", "mv", "grep",
                   "sed", "awk", "find", "chmod", "chown", "sudo", "apt", "yum", "brew"]
        case "yaml", "yml":
            return ["true", "false", "null", "yes", "no", "on", "off"]
        case "json":
            return ["true", "false", "null"]
        case "markdown", "md":
            return []
        case "html":
            return ["html", "head", "body", "div", "span", "p", "a", "img", "ul", "ol", "li",
                   "table", "tr", "td", "th", "form", "input", "button", "select", "option",
                   "textarea", "label", "header", "footer", "nav", "section", "article", "aside",
                   "main", "figure", "figcaption", "script", "style", "link", "meta", "title"]
        case "css":
            return ["color", "background", "border", "margin", "padding", "width", "height",
                   "display", "position", "top", "right", "bottom", "left", "float", "clear",
                   "font", "text", "align", "justify", "transform", "transition", "animation",
                   "flex", "grid", "absolute", "relative", "fixed", "static", "inherit", "initial"]
        case "objc", "objective-c", "objectivec":
            return ["@interface", "@implementation", "@property", "@synthesize", "@dynamic",
                   "@protocol", "@class", "@selector", "@encode", "@try", "@catch", "@finally",
                   "@throw", "@synchronized", "@autoreleasepool", "if", "else", "for", "while",
                   "do", "switch", "case", "default", "break", "continue", "return", "self",
                   "super", "nil", "YES", "NO", "BOOL", "id", "void", "NSString", "NSArray"]
        case "r":
            return ["function", "if", "else", "for", "while", "repeat", "break", "next",
                   "return", "library", "require", "source", "install.packages", "data.frame",
                   "matrix", "vector", "list", "factor", "NA", "NULL", "TRUE", "FALSE", "Inf",
                   "NaN", "is.na", "is.null", "length", "dim", "nrow", "ncol", "mean", "sum"]
        case "matlab":
            return ["function", "if", "else", "elseif", "end", "for", "while", "switch",
                   "case", "otherwise", "break", "continue", "return", "global", "persistent",
                   "classdef", "properties", "methods", "events", "try", "catch", "plot",
                   "figure", "subplot", "title", "xlabel", "ylabel", "legend", "grid", "hold"]
        case "perl":
            return ["sub", "my", "our", "local", "use", "require", "package", "if", "else",
                   "elsif", "unless", "while", "for", "foreach", "do", "until", "next", "last",
                   "return", "die", "warn", "print", "say", "open", "close", "read", "write"]
        case "scala":
            return ["def", "val", "var", "class", "object", "trait", "extends", "with",
                   "import", "package", "if", "else", "match", "case", "for", "while", "do",
                   "yield", "return", "try", "catch", "finally", "throw", "new", "this", "super",
                   "private", "protected", "public", "override", "abstract", "final", "sealed"]
        case "haskell", "hs":
            return ["module", "import", "data", "type", "newtype", "class", "instance", "where",
                   "let", "in", "if", "then", "else", "case", "of", "do", "return", "IO", "Maybe",
                   "Either", "Int", "Integer", "Float", "Double", "Bool", "True", "False", "String"]
        case "dart":
            return ["import", "library", "part", "class", "abstract", "extends", "implements",
                   "with", "mixin", "enum", "typedef", "function", "var", "final", "const", "dynamic",
                   "void", "null", "true", "false", "if", "else", "for", "while", "do", "switch",
                   "case", "default", "break", "continue", "return", "try", "catch", "finally",
                   "throw", "async", "await", "yield", "sync", "Future", "Stream", "get", "set"]
        case "lua":
            return ["function", "local", "if", "then", "else", "elseif", "end", "for", "while",
                   "do", "repeat", "until", "break", "return", "and", "or", "not", "nil", "true",
                   "false", "in", "pairs", "ipairs", "next", "print", "require", "module"]
        case "elixir", "ex":
            return ["defmodule", "def", "defp", "defmacro", "defprotocol", "defimpl", "defstruct",
                   "do", "end", "fn", "if", "else", "unless", "case", "cond", "when", "for",
                   "while", "try", "catch", "rescue", "after", "raise", "throw", "import", "alias",
                   "require", "use", "quote", "unquote", "module", "true", "false", "nil"]
        case "clojure", "clj":
            return ["def", "defn", "defmacro", "defprotocol", "deftype", "defrecord", "ns",
                   "require", "import", "use", "if", "when", "cond", "case", "let", "fn",
                   "loop", "recur", "for", "doseq", "while", "try", "catch", "finally", "throw",
                   "do", "quote", "unquote", "true", "false", "nil", "and", "or", "not"]
        case "vue":
            return ["template", "script", "style", "export", "default", "import", "from", "data",
                   "methods", "computed", "watch", "props", "components", "mounted", "created",
                   "beforeMount", "beforeCreate", "updated", "destroyed", "setup", "ref", "reactive",
                   "computed", "watch", "onMounted", "onUpdated", "onUnmounted", "defineProps",
                   "defineEmits", "defineExpose", "provide", "inject", "nextTick", "v-if", "v-else",
                   "v-for", "v-model", "v-show", "v-bind", "v-on", "v-slot"]
        case "react", "jsx", "tsx":
            return ["import", "export", "default", "from", "class", "extends", "const", "let",
                   "var", "function", "return", "if", "else", "switch", "case", "for", "while",
                   "do", "break", "continue", "useState", "useEffect", "useContext", "useReducer",
                   "useCallback", "useMemo", "useRef", "useImperativeHandle", "useLayoutEffect",
                   "useDebugValue", "React", "Component", "Fragment", "Suspense", "lazy", "memo",
                   "forwardRef", "createContext", "createElement", "render", "props", "state"]
        case "svelte":
            return ["export", "import", "from", "let", "const", "function", "if", "else", "each",
                   "await", "then", "catch", "as", "async", "onMount", "onDestroy", "beforeUpdate",
                   "afterUpdate", "tick", "setContext", "getContext", "createEventDispatcher",
                   "writable", "readable", "derived", "get", "subscribe", "set", "update"]
        case "angular":
            return ["import", "export", "from", "class", "interface", "implements", "extends",
                   "constructor", "ngOnInit", "ngOnDestroy", "ngOnChanges", "ngAfterViewInit",
                   "Component", "Injectable", "Directive", "Pipe", "NgModule", "Input", "Output",
                   "EventEmitter", "ViewChild", "ContentChild", "HostListener", "HostBinding",
                   "providers", "declarations", "imports", "exports", "bootstrap", "selector",
                   "template", "templateUrl", "styleUrls", "styles"]
        case "dockerfile", "docker":
            return ["FROM", "RUN", "CMD", "LABEL", "MAINTAINER", "EXPOSE", "ENV", "ADD",
                   "COPY", "ENTRYPOINT", "VOLUME", "USER", "WORKDIR", "ARG", "ONBUILD",
                   "STOPSIGNAL", "HEALTHCHECK", "SHELL", "AS", "apt-get", "yum", "apk",
                   "pip", "npm", "yarn", "curl", "wget", "mkdir", "cd", "rm", "chmod"]
        case "terraform", "tf":
            return ["resource", "data", "variable", "output", "provider", "module", "locals",
                   "terraform", "required_providers", "required_version", "backend", "count",
                   "for_each", "depends_on", "lifecycle", "create_before_destroy", "prevent_destroy",
                   "ignore_changes", "replace_triggered_by", "source", "version", "region", "type",
                   "name", "value", "default", "description", "sensitive", "validation", "condition"]
        case "graphql", "gql":
            return ["query", "mutation", "subscription", "fragment", "schema", "type", "interface",
                   "union", "enum", "scalar", "input", "directive", "extends", "implements", "on",
                   "Int", "Float", "String", "Boolean", "ID", "null", "true", "false"]
        case "solidity", "sol":
            return ["pragma", "contract", "interface", "library", "function", "modifier", "event",
                   "struct", "enum", "mapping", "address", "uint", "int", "bool", "string", "bytes",
                   "public", "private", "internal", "external", "pure", "view", "payable", "memory",
                   "storage", "calldata", "if", "else", "for", "while", "do", "break", "continue",
                   "return", "require", "assert", "revert", "emit", "new", "this", "msg", "block"]
        case "zig":
            return ["const", "var", "fn", "pub", "struct", "enum", "union", "if", "else",
                   "while", "for", "switch", "return", "break", "continue", "defer", "errdefer",
                   "try", "catch", "error", "anyerror", "comptime", "inline", "export", "extern",
                   "align", "packed", "threadlocal", "volatile", "allowzero", "test", "import"]
        case "nim":
            return ["proc", "func", "method", "template", "macro", "iterator", "converter",
                   "var", "let", "const", "type", "object", "enum", "tuple", "seq", "array",
                   "if", "elif", "else", "case", "of", "when", "for", "while", "break", "continue",
                   "return", "yield", "try", "except", "finally", "raise", "import", "include",
                   "export", "from", "as", "nil", "true", "false", "and", "or", "not", "xor"]
        case "julia", "jl":
            return ["function", "macro", "module", "struct", "mutable", "abstract", "type",
                   "immutable", "typealias", "bitstype", "using", "import", "export", "const",
                   "let", "global", "local", "if", "elseif", "else", "end", "for", "while",
                   "break", "continue", "return", "try", "catch", "finally", "throw", "begin",
                   "quote", "true", "false", "nothing", "missing", "Inf", "NaN"]
        case "groovy", "gradle":
            return ["def", "class", "interface", "enum", "trait", "extends", "implements",
                   "import", "package", "if", "else", "switch", "case", "default", "for", "while",
                   "do", "break", "continue", "return", "try", "catch", "finally", "throw", "new",
                   "this", "super", "public", "private", "protected", "static", "final", "abstract",
                   "synchronized", "volatile", "transient", "assert", "true", "false", "null"]
        case "powershell", "ps1":
            return ["function", "param", "process", "begin", "end", "if", "else", "elseif",
                   "switch", "foreach", "for", "while", "do", "break", "continue", "return",
                   "try", "catch", "finally", "throw", "trap", "class", "enum", "using",
                   "Import-Module", "Export-ModuleMember", "New-Object", "Add-Type", "Get-",
                   "Set-", "Remove-", "Invoke-", "Out-", "Write-", "$true", "$false", "$null"]
        case "vb", "vbnet", "visualbasic":
            return ["Public", "Private", "Protected", "Friend", "Shared", "Static", "Dim",
                   "Const", "Class", "Structure", "Module", "Interface", "Enum", "Function",
                   "Sub", "Property", "Get", "Set", "If", "Then", "Else", "ElseIf", "End",
                   "Select", "Case", "For", "Each", "Next", "While", "Do", "Loop", "Until",
                   "Exit", "Continue", "Return", "Try", "Catch", "Finally", "Throw", "Imports",
                   "Inherits", "Implements", "Overrides", "Overloads", "True", "False", "Nothing"]
        case "fortran", "f90", "f95":
            return ["program", "module", "subroutine", "function", "contains", "use", "implicit",
                   "integer", "real", "complex", "logical", "character", "dimension", "parameter",
                   "allocatable", "pointer", "if", "then", "else", "elseif", "endif", "do", "while",
                   "enddo", "select", "case", "default", "exit", "cycle", "return", "call", "stop",
                   "read", "write", "print", "open", "close", "allocate", "deallocate"]
        case "pascal", "delphi":
            return ["program", "unit", "interface", "implementation", "uses", "type", "const",
                   "var", "procedure", "function", "begin", "end", "if", "then", "else", "case",
                   "of", "for", "to", "downto", "while", "do", "repeat", "until", "break",
                   "continue", "exit", "try", "except", "finally", "raise", "class", "object",
                   "record", "array", "string", "integer", "real", "boolean", "true", "false", "nil"]
        default:
            return ["func", "function", "def", "class", "return", "if", "else", "for",
                   "while", "import", "const", "var", "let"]
        }
    }
}