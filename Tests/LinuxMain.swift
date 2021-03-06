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
    ("testIndexCombine", testIndexCombine),
    ("testPostCombine", testPostCombine),
    ("testGetCombine", testGetCombine),
    ("testPatchCombine", testPatchCombine),
    ("testDeleteCombine", testDeleteCombine),
    ("testMockedGet", testMockedGet),
    ("testMockedPostCombine", testMockedPostCombine),
    ("testMockedGetCombine", testMockedGetCombine),
    ("testMockedDeleteCombine", testMockedDeleteCombine),
  ]
}

XCTMain([
  testCase(MicroyaIntegrationTests.allTests)
])
