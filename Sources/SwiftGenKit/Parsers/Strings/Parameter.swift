import Foundation

// MARK: - Parameter Model

extension Strings {
    public struct Parameter: Equatable {
        public let name: String
        public let type: PlaceholderType
    }
}

// MARK: - Extract Parameter Names

extension Strings.Parameter {
    /// Extracts parameter names from a given string
    ///
    /// - Parameters:
    ///   - string: The input string containing potential parameters
    ///   - type: The placeholder type used to assign a type to each extracted parameter
    /// - Returns: An array of `Parameter` objects representing the extracted parameters
    ///
    /// Example: "Welcome, {{displayName}}" --> [Parameter(name: "displayName", type: .string)]
    static func extractParameterNames(
        from string: String,
        type: Strings.PlaceholderType
    ) -> [Strings.Parameter] {
        let results = namedParameterRegEx.matches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.utf16.count)
        )
        
        let parameterNames = results.compactMap { result -> String? in
            /// `result.range(at: 1)` extracts the first capture group (i.e. the parameter name)
            guard let range = Range(result.range(at: 1), in: string) else {
                return nil
            }
            return String(string[range])
        }
        
        return parameterNames.map { .init(name: $0, type: type) }
    }
}

// MARK: - Private Helpers

private extension Strings.Parameter {
    /// This regular expression is used to match named parameters embedded within double curly braces in a string.
    ///
    /// - Note: The pattern will match sequences like `{{parameterName}}`, where `parameterName` consists of
    /// alphanumeric characters and underscores. The expression allows for optional whitespace both inside
    /// and outside the braces.
    static let namedParameterRegEx: NSRegularExpression = {
        do {
            return try NSRegularExpression(
                pattern: #"\{\{\s*([a-zA-Z0-9_]+)\s*\}\}"#,
                options: []
            )
        } catch {
            fatalError("Error building the regular expression used to match the named parameter format")
        }
    }()
}
