//
// SwiftGenKit
// Copyright © 2022 SwiftGen
// MIT Licence
//

import Foundation
import PathKit

extension Strings {
    struct Entry {
        var comment: String?
        let key: String
        let translation: String
        let types: [PlaceholderType]
        let parameters: [Parameter]
        let keyStructure: [String]
        
        init(
            key: String,
            translation: String,
            types: [PlaceholderType],
            parameters: [Parameter],
            keyStructureSeparator: String
        ) {
            self.key = key
            self.translation = translation
            self.types = types
            self.parameters = parameters
            self.keyStructure = Self.split(key: key, separator: keyStructureSeparator)
        }
        
        init(key: String, translation: String, keyStructureSeparator: String) throws {
            let types = try PlaceholderType.placeholderTypes(fromFormat: translation)
            let parameters = Parameter.extractParameterNames(from: translation, type: .object)

            self.init(
                key: key,
                translation: translation,
                types: types,
                parameters: parameters,
                keyStructureSeparator: keyStructureSeparator
            )
        }
        
        // MARK: - Structured keys
        
        private static func split(key: String, separator: String) -> [String] {
            key
                .components(separatedBy: separator)
                .filter { !$0.isEmpty }
        }
    }
}
