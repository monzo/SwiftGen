//
//  StringsParameterTests.swift
//  
//
//  Created by Mohammed Ahmad on 10/01/2025.
//

@testable import SwiftGenKit
import XCTest

final class StringsParameterTests: XCTestCase {
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
        let string = "Welcome, {{ displayName }}"
        
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
        let string = "I give {{ appleCount }} apples to {{ name }}"
        
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
            "{{parameterName}}",
            "{{ parameter_name }}",
            "{{  PARAM123  }}"
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
            "{{parameter.name}}"
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
}
