// Generated using Sourcery 1.0.3 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

@testable import MicroyaTests
import XCTest

// swiftlint:disable line_length file_length

extension MicroyaIntegrationTests {
  static var allTests: [(String, (MicroyaIntegrationTests) -> () throws -> Void)] = [
    ("testIndex", testIndex),
    ("testPost", testPost),
    ("testGet", testGet),
    ("testPatch", testPatch),
    ("testDelete", testDelete),
  ]
}

XCTMain([
  testCase(MicroyaIntegrationTests.allTests)
])
