//
// SwiftGenKit
// Copyright © 2022 SwiftGen
// MIT Licence
//

import Foundation
import PathKit

extension Strings {
    final class StringsDictFileParser: StringsFileTypeParser {
        private let options: ParserOptionValues
        
        init(options: ParserOptionValues) {
            self.options = options
        }
        
        static let extensions = ["stringsdict"]
        
        func parseFile(at path: Path) throws -> [Strings.Entry] {
            guard let data = try? path.read() else {
                throw ParserError.failureOnLoading(path: path)
            }
            
            do {
                let plurals = try PropertyListDecoder()
                    .decode([String: StringsDict].self, from: data)
                    .compactMapValues { stringsDict -> StringsDict.PluralEntry? in
                        // We only support .pluralEntry (and not .variableWidthEntry) for now, so filter out the rest
                        guard case let .pluralEntry(pluralEntry) = stringsDict else { return nil }
                        return pluralEntry
                    }
                
                return try plurals.map { keyValuePair -> Entry in
                    let (key, pluralEntry) = keyValuePair
                    return Entry(
                        key: key,
                        translation: "Plural format key: \"\(pluralEntry.formatKey)\"",
                        types: try PlaceholderType.placeholderTypes(
                            fromFormat: pluralEntry.formatKeyWithVariableValueTypes
                        ),
                        parameters: Parameter.extractParameterNames(
                            from: pluralEntry.firstOtherRule,
                            type: pluralEntry.placeholderType
                        ),
                        keyStructureSeparator: options[Option.separator]
                    )
                }
            } catch DecodingError.keyNotFound(let codingKey, let context) {
                throw ParserError.invalidPluralFormat(
                    missingVariableKey: codingKey.stringValue,
                    pluralKey: context.codingPath.first?.stringValue ?? ""
                )
            }
        }
    }
}

// MARK: - Private Helpers

private extension StringsDict.PluralEntry {
    var firstOtherRule: String {
        self.variables.map { $0.rule.other }.first ?? ""
    }
    
    /// - Note: For the first iteration of the named parameters work, we expect  all 
    /// `.stringsdict` entries to be a count so we can return an integer for the time being.
    ///
    /// - Returns: .int
    var placeholderType: Strings.PlaceholderType {
        .int
    }
}
