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
            return String(string[range]).snakeToCamelCase
        }
        
        return parameterNames.map { .init(name: $0, type: type) }
    }
}

// MARK: - Private Helpers

// MARK: Parameter Regex

private extension Strings.Parameter {
    /// This regular expression is used to match named parameters embedded within double curly braces in a string.
    ///
    /// - Note: The pattern will match sequences like `{{parameterName}}`, where `parameterName` consists of
    /// alphanumeric characters and underscores, and must start with a lowercase letter. The expression allows
    /// for optional whitespace both inside and outside the braces.
    static let namedParameterRegEx: NSRegularExpression = {
        do {
            return try NSRegularExpression(
                pattern: #"\{\{\s*([a-z][a-z0-9_]*)\s*\}\}"#,
                options: []
            )
        } catch {
            fatalError("Error building the regular expression used to match the named parameter format")
        }
    }()
}

// MARK: String Helpers

private extension String {
    /// Converts a `snake_case` string to `camelCase`.
    ///
    /// - Note: Handles edge cases such as leading, trailing, and multiple underscores by ignoring them
    /// and not including empty segments in the output. If the input is an empty string or consists only
    /// of underscores, the computed property will return an empty string.
    var snakeToCamelCase: String {
        guard !self.isEmpty else { return "" }

        let components = self.split(separator: "_")
        
        guard !components.isEmpty else { return "" }
        
        return components.enumerated().map { (index, element) in
            let lowercased = element.lowercased()
            if index == 0 {
                return lowercased
            } else {
                return lowercased.capitalizingFirstLetter
            }
        }.joined()
    }
    
    var capitalizingFirstLetter: String {
        prefix(1).capitalized + dropFirst()
    }
}
