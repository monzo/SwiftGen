@testable import SwiftGenKit
import TestUtils
import XCTest

final class StringsDictFileParserTests: XCTestCase {
    private var parser: Strings.StringsDictFileParser!
    private var options: ParserOptionValues!
    
    override func setUp() {
        super.setUp()
        let options = try! ParserOptionValues(options: [:], available: Strings.Parser.allOptions)
        parser = Strings.StringsDictFileParser(options: options)
    }
    
    override func tearDown() {
        parser = nil
        options = nil
        super.tearDown()
    }
    
    func test_parseFile_readsKeys() throws {
        // Given
        let filePath = Fixtures.resource(for: "LocNamedParameters.stringsdict", sub: .strings)
        
        // When
        let stringsDictEntry = try parser.parseFile(at: filePath)
        
        // Then
        let keys = stringsDictEntry
            .map { $0.key }
            .sorted()
        
        XCTAssertEqual(keys, ["pots.count"])
    }
    
    func test_parseFile_readsParameters() throws {
        // Given
        let filePath = Fixtures.resource(for: "LocNamedParameters.stringsdict", sub: .strings)
        
        // When
        let stringsDictEntry = try parser.parseFile(at: filePath)
        
        // Then
        let parameters = stringsDictEntry
            .map { $0.parameters }
            .filter { !$0.isEmpty }
            .sorted(by: { $0.count < $1.count })
        
        XCTAssertEqual(
            parameters[0],
            [.init(name: "potCount", type: .int)]
        )
    }
}
