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
    
    XCTAssertEqual(keys, ["account.title", "billingUnits.message", "pots.count"])
  }
  
  func test_parseFile_readsParameters() throws {
    // Given
    let filePath = Fixtures.resource(for: "LocNamedParameters.stringsdict", sub: .strings)
    
    // When
    let stringsDictEntry = try parser.parseFile(at: filePath)
    
    // Then
    let parameters = stringsDictEntry
      .map { $0.parameters }
      .sorted { lhs, rhs in
        let lhsName = lhs.first?.name ?? ""
        let rhsName = rhs.first?.name ?? ""
        return lhsName < rhsName
      }
    
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
      [.init(name: "count", type: .int)]
    )
    
    let thirdEntryParameters = parameters[2]
    XCTAssertEqual(thirdEntryParameters.count, 1)
    XCTAssertEqual(
      thirdEntryParameters,
      [.init(name: "potCount", type: .int)]
    )
  }
}
