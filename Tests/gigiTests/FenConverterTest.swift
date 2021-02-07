import XCTest

@testable import gigi

class FenConverterTest: XCTestCase {
  func testRoundTripConversion() throws {
    try checkFen("r1bqkbnr/pppppppp/2n5/4P3/8/8/PPPP1PPP/RNBQKBNR b KQkq - 0 2")
    try checkFen("r1bqkbnr/pppppppp/2n5/4P3/8/8/PPPP1PPP/RNBQKBNR w K - 3 2")
    try checkFen("r1bqkbnr/pppppppp/2n5/4P3/8/8/PPPP1PPP/RNBQKBNR b Qq - 0 2")
    try checkFen("3r1r1k/1b3p2/p2p1Q2/2p5/4P3/3P4/PPP2PPP/R4RK1 b - - 0 1")
    try checkFen("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1")
  }

  private func checkFen(_ expected: String) throws {
    let board = try FenConverter.boardFromFen(expected)
    let actual = FenConverter.boardToFen(board)
    XCTAssertEqual(expected, actual)
  }
}
