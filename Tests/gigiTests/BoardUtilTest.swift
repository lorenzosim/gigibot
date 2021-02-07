import XCTest

@testable import gigi

class BoardUtilTest: XCTestCase {
  func testIsInCheck_queen() throws {
    let board = try Board.fromFen("7k/8/8/8/6q1/8/8/3K4 w - - 0 1")
    XCTAssertEqual(true, BoardUtil.isInCheck(board: board, player: Player.white))
    XCTAssertEqual(false, BoardUtil.isInCheck(board: board, player: Player.black))
  }

  func testIsInCheck_rook() throws {
    let board = try Board.fromFen("7k/8/8/8/8/8/8/3K2r1 w - - 0 1")
    XCTAssertEqual(true, BoardUtil.isInCheck(board: board, player: Player.white))
  }

  func testIsInCheck_knight() throws {
    let board = try Board.fromFen("7k/8/8/8/8/8/5n2/3K4 b - - 0 1")
    XCTAssertEqual(true, BoardUtil.isInCheck(board: board, player: Player.white))
  }

  func testIsInCheck_bishop() throws {
    let board = try Board.fromFen("7k/8/8/8/b7/8/8/3K4 b - - 0 1")
    XCTAssertEqual(true, BoardUtil.isInCheck(board: board, player: Player.white))
  }

  func testIsInCheck_pawn() throws {
    let board = try Board.fromFen("7k/8/8/8/B7/8/2p5/3K4 b - - 0 1")
    XCTAssertEqual(true, BoardUtil.isInCheck(board: board, player: Player.white))
  }

  func testIsInCheck_nocheck() throws {
    let board = try Board.fromFen("7k/8/8/7r/B5b1/7q/4P3/3K4 b - - 0 1")
    XCTAssertEqual(false, BoardUtil.isInCheck(board: board, player: Player.white))
  }
}
