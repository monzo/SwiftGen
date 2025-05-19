@testable import SwiftGenKit
import XCTest

final class StringsParameterTests: XCTestCase {
  func test_extractParameterNames_hasPositionalParameters_returnEmptyArray() {
    // Given
    let stringWithPositionalParameters = "Welcome, %@"
    
    // When
    let parameterNames = Strings.Parameter.extractParameterNames(
      from: stringWithPositionalParameters,
      type: .object,
      hasPositionalPlaceholders: true
    )
    
    // Then
    XCTAssertTrue(parameterNames.isEmpty)
  }
  
  func test_extractParameterNames_returnEmptyArray() {
    // Given
    let string = "This string has no named parameters"
    
    // When
    let parameterNames = Strings.Parameter.extractParameterNames(
      from: string,
      type: .object
    )
    
    // Then
    XCTAssertTrue(parameterNames.isEmpty)
  }
  
  func test_extractParameterNames_returnsOneNamedParameter() {
    // Given
    let string = "Welcome, {{ display_name }}"
    
    // When
    let parametersNames = Strings.Parameter.extractParameterNames(
      from: string,
      type: .object
    )
    
    // Then
    XCTAssertEqual(parametersNames, [.init(name: "displayName", type: .object)])
  }
  
  func test_extractParameterNames_returnsMultipleNamedParameters() {
    // Given
    let string = "I give {{ apple_count }} apples to {{ name }}"
    
    // When
    let parameterNames = Strings.Parameter.extractParameterNames(
      from: string,
      type: .object
    )
    
    // Then
    XCTAssertEqual(
      parameterNames,
      [
        .init(name: "appleCount", type: .object),
        .init(name: "name", type: .object)
      ]
    )
  }
  
  func test_extractParameterNames_expectedRegexMatches() {
    // Given
    let stringsWithMatchingParams = [
      "{{parameter_name}}",
      "{{ parameter_name }}",
      "{{parameter_name     }}",
      "{{ parameter1_name1 }}",
      "{{x}}"
    ]
    
    stringsWithMatchingParams.forEach {
      // When
      let parameterNames = Strings.Parameter.extractParameterNames(
        from: $0,
        type: .object
      )
      
      // Then
      XCTAssertFalse(parameterNames.isEmpty)
    }
  }
  
  func test_extractParameterNames_expectedRegexNonMatches() {
    // Given
    let stringsWithNonMatchingParams = [
      "{parameterName}",
      "{{parameter name}}",
      "{{parameter-name}}",
      "{{parameter.name}}",
      "{{ Parameter }}",
      "{{  PARAM123  }}",
      "{{X}}"
    ]
    
    stringsWithNonMatchingParams.forEach {
      // When
      let parameterNames = Strings.Parameter.extractParameterNames(
        from: $0,
        type: .object
      )
      
      // Then
      XCTAssertTrue(parameterNames.isEmpty)
    }
  }
  
  func test_extractParameterNames_regexWorksWithOrdinalSuffix() {
    // Given
    let stringWithOrdinalSuffix = "{{parameter_name}}th"
    
    // When
    let parameterNames = Strings.Parameter.extractParameterNames(
      from: stringWithOrdinalSuffix,
      type: .object
    )
    
    // Then
    XCTAssertEqual(parameterNames, [.init(name: "parameterName", type: .object)])
  }
  
  func test_extractParameterNames_returnsStringPlaceholderType() {
    // Given
    let placeholderType = Strings.PlaceholderType.object
    
    // When
    let parameterNames = Strings.Parameter.extractParameterNames(
      from: "{{ test }}",
      type: placeholderType
    )
    
    // Then
    XCTAssertEqual(parameterNames[0].type, placeholderType)
  }
  
  func test_extractParameterNames_returnsIntPlaceholderType() {
    // Given
    let placeholderType = Strings.PlaceholderType.int
    
    // When
    let parameterNames = Strings.Parameter.extractParameterNames(
      from: "{{ test }}",
      type: placeholderType
    )
    
    // Then
    XCTAssertEqual(parameterNames[0].type, placeholderType)
  }
  
  func test_extractParameterNames_convertsSnakeToCamelCase() {
    // Given
    let strings = [
      "{{parameter_name}}",
      "{{this_is_a_test}}",
      "{{}}",
      "{{param_name_}}",
      "{{foo__bar}}",
      "{{_}}"
    ]
    
    let expectedResults = [
      "parameterName",
      "thisIsATest",
      "paramName",
      "fooBar"
    ]
    
    // When
    let parameters = strings.flatMap {
      Strings.Parameter.extractParameterNames(from: $0, type: .object)
    }
    
    // Then
    for (index, parameter) in parameters.enumerated() {
      XCTAssertEqual(parameter.name, expectedResults[index])
    }
  }
}
