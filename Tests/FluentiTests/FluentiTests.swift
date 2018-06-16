import XCTest
@testable import Fluenti

final class FluentiTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Fluenti().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
