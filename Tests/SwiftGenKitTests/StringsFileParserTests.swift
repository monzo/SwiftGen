@testable import SwiftGenKit
import TestUtils
import XCTest

final class StringsFileParserTests: XCTestCase {
    private var parser: Strings.StringsFileParser!
    private var options: ParserOptionValues!
    
    override func setUp() {
        super.setUp()
        let options = try! ParserOptionValues(options: [:], available: Strings.Parser.allOptions)
        parser = Strings.StringsFileParser(options: options)
    }
    
    override func tearDown() {
        parser = nil
        options = nil
        super.tearDown()
    }
    
    func test_parseFile_readsKeys() throws {
        // Given
        let filePath = Fixtures.resource(for: "LocNamedParameters.strings", sub: .strings)
        
        // When
        let stringsEntry = try parser.parseFile(at: filePath)
        
        // Then
        let keys = stringsEntry.map { $0.key }
        XCTAssertEqual(
            keys.sorted(),
            ["no.parameter", "one.parameter", "two.parameters"]
        )
    }
    
    func test_parseFile_readsTranslations() throws {
        // Given
        let filePath = Fixtures.resource(for: "LocNamedParameters.strings", sub: .strings)
        
        // When
        let stringsEntry = try parser.parseFile(at: filePath)
        
        // Then
        let translations = stringsEntry.map { $0.translation }
        XCTAssertEqual(
            translations.sorted(),
            [
                "Hello, {{name}}!",
                "This string has no named parameters",
                "Welcome, {{name}}! You have {{message_count}} unread messages."
            ]
        )
    }
    
    func test_parseFile_readsParameters() throws {
        // Given
        let filePath = Fixtures.resource(for: "LocNamedParameters.strings", sub: .strings)
        
        // When
        let stringsEntry = try parser.parseFile(at: filePath)
        
        // Then
        let parameters = stringsEntry
            .map { $0.parameters }
            .sorted(by: { $0.count < $1.count })
        
        let firstEntryParameters = parameters[0]
        XCTAssertEqual(firstEntryParameters.count, 0)
        XCTAssertEqual(
            firstEntryParameters,
            []
        )
        
        let secondEntryParameters = parameters[1]
        XCTAssertEqual(secondEntryParameters.count, 1)
        XCTAssertEqual(
            secondEntryParameters,
            [
                .init(name: "name", type: .object)
            ]
        )
        
        let thirdEntryParameters = parameters[2]
        XCTAssertEqual(thirdEntryParameters.count, 2)
        XCTAssertEqual(
            thirdEntryParameters,
            [
                .init(name: "name", type: .object),
                .init(name: "messageCount", type: .object)
            ]
        )
    }
}
