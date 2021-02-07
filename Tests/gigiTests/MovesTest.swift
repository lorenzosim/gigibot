import XCTest

@testable import gigi

class MovesTest: XCTestCase {
  func testSimplePawnMove() throws {
    var board = Board.startingPosition()
    board = try Move.fromLan("e2e3").make(board)
    try checkBoard(board, "rnbqkbnr/pppppppp/8/8/8/4P3/PPPP1PPP/RNBQKBNR b KQkq - 0 1")
  }

  func testSimplePieceMove() throws {
    var board = Board.startingPosition()
    board = try Move.fromLan("g1f3").make(board)
    try checkBoard(board, "rnbqkbnr/pppppppp/8/8/8/5N2/PPPPPPPP/RNBQKB1R b KQkq - 1 1")
  }

  func testCapture() throws {
    var board =
      try Board.fromFen("rnbqkbnr/ppp1pppp/8/3p4/6P1/8/PPPPPP1P/RNBQKBNR b KQkq - 0 1")
    board = try Move.fromLan("c8g4").make(board)
    try checkBoard(board, "rn1qkbnr/ppp1pppp/8/3p4/6b1/8/PPPPPP1P/RNBQKBNR w KQkq - 0 2")
  }

  func testEnPassantCapture() throws {
    var board =
      try Board.fromFen("rnbqkbnr/ppppp1pp/8/8/5pP1/2N4P/PPPPPP2/R1BQKBNR b KQkq g3 0 3")
    board = try Move.fromLan("f4g3").make(board)
    try checkBoard(board, "rnbqkbnr/ppppp1pp/8/8/8/2N3pP/PPPPPP2/R1BQKBNR w KQkq - 0 4")
  }

  func testCastle_white() throws {
    let board = try Board.fromFen("r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
    try checkBoard(Move.fromLan("e1g1").make(board), "r3k2r/8/8/8/8/8/8/R4RK1 b kq - 1 1")
    try checkBoard(Move.fromLan("e1c1").make(board), "r3k2r/8/8/8/8/8/8/2KR3R b kq - 1 1")
  }

  func testCastle_black() throws {
    let board = try Board.fromFen("r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1")
    try checkBoard(Move.fromLan("e8g8").make(board), "r4rk1/8/8/8/8/8/8/R3K2R w KQ - 1 2")
    try checkBoard(Move.fromLan("e8c8").make(board), "2kr3r/8/8/8/8/8/8/R3K2R w KQ - 1 2")
  }

  func testCastleRights_white() throws {
    var board = try Board.fromFen("r3k2r/8/8/8/8/8/2n2n2/R3K2R w KQkq - 0 1")
    // Move king
    try checkBoard(Move.fromLan("e1e2").make(board), "r3k2r/8/8/8/8/8/2n1Kn2/R6R b kq - 1 1")
    // Move left rook
    try checkBoard(Move.fromLan("h1h2").make(board), "r3k2r/8/8/8/8/8/2n2n1R/R3K3 b Qkq - 1 1")
    // Move right rook
    try checkBoard(Move.fromLan("a1a2").make(board), "r3k2r/8/8/8/8/8/R1n2n2/4K2R b Kkq - 1 1")

    board = try Board.fromFen("r3k2r/8/8/8/8/8/2n2n2/R3K2R b KQkq - 0 1")
    // Left rook captured
    try checkBoard(Move.fromLan("c2a1").make(board), "r3k2r/8/8/8/8/8/5n2/n3K2R w Kkq - 0 2")
    // Right rook captured
    try checkBoard(Move.fromLan("f2h1").make(board), "r3k2r/8/8/8/8/8/2n5/R3K2n w Qkq - 0 2")
  }

  func testCastleRights_black() throws {
    var board = try Board.fromFen("r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1")
    // Move king
    try checkBoard(Move.fromLan("e8f7").make(board), "r6r/5k2/8/8/8/8/8/R3K2R w KQ - 1 2")
    // Move left rook
    try checkBoard(Move.fromLan("a8a7").make(board), "4k2r/r7/8/8/8/8/8/R3K2R w KQk - 1 2")
    // Move right rook
    try checkBoard(Move.fromLan("h8h5").make(board), "r3k3/8/8/7r/8/8/8/R3K2R w KQq - 1 2")

    board = try Board.fromFen("r3k2r/8/8/8/3BB3/8/5n2/n3K2R w KQkq - 0 1")
    // Left rook captured
    try checkBoard(Move.fromLan("e4a8").make(board), "B3k2r/8/8/8/3B4/8/5n2/n3K2R b KQk - 0 1")
    // Right rook captured
    try checkBoard(Move.fromLan("d4h8").make(board), "r3k2B/8/8/8/4B3/8/5n2/n3K2R b KQq - 0 1")
  }

  func testPromotion() throws {
    var board = try Board.fromFen("8/1P3k2/8/8/8/8/7p/4K3 w - - 0 1")
    board = try Move.fromLan("b7b8q").make(board)
    try checkBoard(board, "1Q6/5k2/8/8/8/8/7p/4K3 b - - 0 1")
    try checkBoard(Move.fromLan("h2h1r").make(board), "1Q6/5k2/8/8/8/8/8/4K2r w - - 0 2")
  }

  func testEnPassant_white() throws {
    var board = Board.startingPosition()
    board = try Move.fromLan("e2e4").make(board)
    try checkBoard(board, "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1")
  }

  func testEnPassant_black() throws {
    var board = try Board.fromFen("rnbqkbnr/1ppppppp/p7/P7/8/8/1PPPPPPP/RNBQKBNR b KQkq - 0 2")
    board = try Move.fromLan("b7b5").make(board)
    try checkBoard(board, "rnbqkbnr/2pppppp/p7/Pp6/8/8/1PPPPPPP/RNBQKBNR w KQkq b6 0 3")

  }

  func checkBoard(_ board: Board, _ fen: String) throws {
    let actual = FenConverter.boardToFen(board)
    XCTAssertEqual(actual, fen)
  }
}
