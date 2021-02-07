import XCTest

@testable import gigi

class PositionEvaluatorTest: XCTestCase {
  func testSimple() throws {
    var board = try Board.fromFen("4k3/2qp4/8/8/8/8/5Q2/3KR3 w - - 0 1")
    var score = PositionEvaluator.getBoardScore(board)
    XCTAssertEqual(420, score)  // Rook (505) + Queen(900) - Pawn (80) - Queen (905)

    // Same but with black's turn, should be the opposite.
    board = try Board.fromFen("3qk3/3p4/8/8/8/8/8/3KRQ2 b - - 0 1")
    score = PositionEvaluator.getBoardScore(board)
    XCTAssertEqual(-420, score)
  }

  func testNoKing() throws {
    let board = try Board.fromFen("rnbq1bnr/pppppppp/8/8/8/8/8/4K3 w - - 0 1")
    let score = PositionEvaluator.getBoardScore(board)
    XCTAssertGreaterThan(score, 10_000)
  }

  func testKingMiddleGame() throws {
    let board = try Board.fromFen("8/8/8/2rqQR2/8/8/8/2k1K3 w - - 0 1")
    let score = PositionEvaluator.getBoardScore(board)
    XCTAssertEqual(40, score)
  }

  func testKingEndGame() throws {
    let board = try Board.fromFen("8/8/8/8/8/8/8/2k1K3 w - - 0 1")
    let score = PositionEvaluator.getBoardScore(board)
    XCTAssertEqual(0, score)
  }
}
