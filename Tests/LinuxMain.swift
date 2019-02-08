import XCTest

import swiftyvulkanTests

var tests = [XCTestCaseEntry]()
tests += swiftyvulkanTests.allTests()
XCTMain(tests)