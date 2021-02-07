import XCTest

@testable import gigi

class MoveSearcherTest: XCTestCase {
  func testAbsolutePin() throws {
    let board = try Board.fromFen("7k/8/8/3q4/8/2r5/3P4/3K4 w - - 0 1")
    let searcher = MoveSearcher(maxDepth: 3)
    let move = searcher.findBestMove(board).getFirstMove()!.toLan()
    XCTAssertNotEqual(move, "d2c3")
  }

  func testMateInOne() throws {
    let board = try Board.fromFen("8/8/8/6q1/8/3k4/8/3K4 b - - 0 1")
    let searcher = MoveSearcher(maxDepth: 3)
    let moveAndScore = searcher.findBestMove(board)
    XCTAssertEqual(moveAndScore.getFirstMove()!.toLan(), "g5d2")
    XCTAssertGreaterThanOrEqual(moveAndScore.score, 10_000)
  }

  func testBeingMatedInOne() throws {
    let board = try Board.fromFen("5r2/8/8/6q1/8/3k4/8/4K3 w - - 0 1")
    let searcher = MoveSearcher(maxDepth: 3)
    let moveAndScore = searcher.findBestMove(board)
    XCTAssertEqual(moveAndScore.getFirstMove()!.toLan(), "e1d1")
    XCTAssertLessThanOrEqual(moveAndScore.score, -10_000)
  }

  func testMateInTwo() throws {
    let board = try Board.fromFen("4r2k/6pp/7N/1r1Q4/8/8/8/6K1 w - - 0 1")
    let searcher = MoveSearcher(maxDepth: 4)
    let moveAndScore = searcher.findBestMove(board)
    XCTAssertEqual(moveAndScore.getFirstMove()!.toLan(), "d5g8")
    XCTAssertGreaterThanOrEqual(moveAndScore.score, 10_000)
  }

  func testAvoidStaleMate() throws {
    let board = try Board.fromFen("7k/7r/8/8/8/q4N2/8/6K1 b - - 0 1")
    let searcher = MoveSearcher(maxDepth: 3)
    let move = searcher.findBestMove(board).getFirstMove()!.toLan()
    XCTAssertNotEqual(move, "a3f3")
  }

  func testAvoidMate() throws {
    let board = try Board.fromFen("7k/8/7r/7q/8/8/6PP/2r3RK w - - 0 1")
    let searcher = MoveSearcher(maxDepth: 3)
    let move = searcher.findBestMove(board).getFirstMove()!.toLan()
    XCTAssertEqual(move, "h2h3")
  }

  func testQuiesce_avoidCapture() throws {
    let board = try Board.fromFen("3r1k2/8/8/8/1p6/r7/8/2Q1K3 w - - 0 1")
    let searcher = MoveSearcher(maxDepth: 1)
    let move = searcher.findBestMove(board).getFirstMove()!.toLan()
    XCTAssertNotEqual(move, "c1a3")
  }
}
