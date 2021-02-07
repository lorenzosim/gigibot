import XCTest

@testable import gigi

class MoveGeneratorTest: XCTestCase {
  func testMoveQueen() throws {
    let moves = try getMoves("8/8/8/8/8/5Q2/8/8 w - - 0 1", "f3")
    checkMoves(
      moves,
      [
        "f3g4", "f3h5", "f3e4", "f3d5", "f3c6", "f3b7", "f3a8", "f3f4", "f3f5",
        "f3f6", "f3f7", "f3f8", "f3g3", "f3h3", "f3e3", "f3d3", "f3c3", "f3b3",
        "f3a3", "f3e2", "f3d1", "f3f2", "f3f1", "f3g2", "f3h1",
      ])
  }

  func testMoveKing() throws {
    let moves = try getMoves("8/8/8/8/8/5K2/8/8 w - - 0 1", "f3")
    checkMoves(moves, ["f3e2", "f3e3", "f3e4", "f3f2", "f3f4", "f3g2", "f3g3", "f3g4"])
  }

  func testMoveBishop() throws {
    let moves = try getMoves("8/8/8/8/8/5B2/8/8 w - - 0 1", "f3")
    checkMoves(
      moves,
      [
        "f3a8", "f3b7", "f3c6", "f3d5", "f3e4",
        "f3h5", "f3g4",
        "f3g2", "f3h1",
        "f3e2", "f3d1",
      ])
  }

  func testMoveRook() throws {
    let moves = try getMoves("8/8/8/8/8/5R2/8/8 w - - 0 1", "f3")
    checkMoves(
      moves,
      [
        "f3a3", "f3b3", "f3c3", "f3d3", "f3e3", "f3g3", "f3h3",
        "f3f1", "f3f2", "f3f4", "f3f5", "f3f6", "f3f7", "f3f8",
      ])
  }

  func testMoveKnight() throws {
    let moves = try getMoves("8/8/8/8/8/5N2/8/8 w - - 0 1", "f3")
    checkMoves(moves, ["f3g1", "f3h2", "f3h4", "f3g5", "f3e5", "f3d4", "f3d2", "f3e1"])
  }

  func testMoveKing_whiteCastleKingSide() throws {
    // All squares occupied
    var moves = try getMoves("r3k2r/pppppppp/8/8/8/8/PPPPPPPP/RBNQKBNR w KQkq - 0 1", "e1")
    checkMoves(moves, [])

    // 1 square occupied
    moves = try getMoves("r3k2r/pppppppp/8/8/8/8/PPPPPPPP/RBNQK1NR w KQkq - 0 1", "e1")
    checkMoves(moves, ["e1f1"])

    // King in check
    moves = try getMoves("r3k2r/pppppppp/8/8/4q3/8/PPPP1PPP/RBNQK2R w Kkq - 0 1", "e1")
    checkMoves(moves, ["e1e2", "e1f1"])

    // F1 attacked
    moves = try getMoves("r3k2r/pppppppp/8/8/5q2/8/PPPP2PP/RBNQK2R w Kkq - 0 1", "e1")
    checkMoves(moves, ["e1e2", "e1f1", "e1f2"])

    // G1 attacked
    moves = try getMoves("r3k3/ppppp1pp/8/8/8/8/PPPP3p/RBNQK2R w Kq - 0 1", "e1")
    checkMoves(moves, ["e1e2", "e1f1", "e1f2"])

    // No right
    moves = try getMoves("r3k2r/pppppppp/8/8/8/8/PPPPPPPP/RBNQK2R w Qkq - 0 1", "e1")
    checkMoves(moves, ["e1f1"])

    // Allowed
    moves = try getMoves("r3k2r/pppppppp/6q1/8/8/6N1/PPPPPP1P/RBNQK2R w Kkq - 0 1", "e1")
    checkMoves(moves, ["e1f1", "e1g1"])
  }

  func testMoveKing_whiteCastleQueenSide() throws {
    // All squares occupied
    var moves = try getMoves("r3k2r/pppppppp/8/8/8/8/PPPPPPPP/RBNQKBNR w KQkq - 0 1", "e1")
    checkMoves(moves, [])

    // 1 square occupied
    moves = try getMoves("r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R1N1KBNR w KQkq - 0 1", "e1")
    checkMoves(moves, ["e1d1"])

    // King in check
    moves = try getMoves("r3k2r/pppppppp/8/8/1b6/8/PPP1PPPP/R3KBNR w KQkq - 0 1", "e1")
    checkMoves(moves, ["e1d1", "e1d2"])

    // D1 attacked
    moves = try getMoves("r3k2r/pppppppp/8/8/8/8/P3pPPP/R3KBNR w KQkq - 0 1", "e1")
    checkMoves(moves, ["e1d1", "e1d2", "e1e2"])

    // C1 attacked
    moves = try getMoves("r3k2r/pppppppp/8/8/1b6/1n6/P3PPPP/R3KBNR w KQkq - 0 1", "e1")
    checkMoves(moves, ["e1d1", "e1d2"])

    // No right
    moves = try getMoves("r3k2r/pppppppp/8/8/8/4B3/PPP1PPPP/R3KBNR w Kkq - 0 1", "e1")
    checkMoves(moves, ["e1d1", "e1d2"])

    // Allowed
    moves = try getMoves("r3k2r/pppppppp/8/8/8/4B3/PPP1PPPP/R3KBNR w KQkq - 0 1", "e1")
    checkMoves(moves, ["e1d1", "e1d2", "e1c1"])
  }

  func testMoveKing_blackCastleKingSide() throws {
    // All squares occupied
    var moves = try getMoves("r3kbnr/pppppppp/8/8/8/8/PPPPPPPP/R3K2R b KQk - 0 1", "e8")
    checkMoves(moves, ["e8d8"])

    // 1 square occupied
    moves = try getMoves("r3kb1r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R b KQk - 0 1", "e8")
    checkMoves(moves, ["e8d8"])

    // King in check
    moves = try getMoves("r3k2r/pppp1ppp/8/8/4R3/8/PPPP1PPP/RBNQK2R b Kkq - 0 1", "e8")
    checkMoves(moves, ["e8d8", "e8f8", "e8e7"])

    // F8 attacked
    moves = try getMoves("r3k2r/pppp1Rpp/8/8/8/8/PPPP1PPP/RBNQK2R b Kk - 0 1", "e8")
    checkMoves(moves, ["e8d8", "e8f8", "e8f7", "e8e7"])

    // G8 attacked
    moves = try getMoves("r3k2r/pppp2pP/8/8/8/8/PPPP1PPP/RBNQK2R b Kk - 0 1", "e8")
    checkMoves(moves, ["e8f8", "e8f7", "e8e7", "e8d8"])

    // No right
    moves = try getMoves("r1n1k2r/pppp2pR/8/8/8/8/PPPP1PPP/RBNQK2R b Kq - 0 1", "e8")
    checkMoves(moves, ["e8f8", "e8f7", "e8e7", "e8d8"])

    // Allowed
    moves = try getMoves("r1n1k2r/pppp2pR/8/8/8/8/PPPP1PPP/RBNQK2R b Kk - 0 1", "e8")
    checkMoves(moves, ["e8g8", "e8f8", "e8f7", "e8e7", "e8d8"])
  }

  func testMovePawn_white() throws {
    // Blocked
    var moves = try getMoves("8/8/8/8/5k2/5P2/8/8 w - - 0 1", "f3")
    checkMoves(moves, [])

    // Forward
    moves = try getMoves("8/8/8/8/8/5P2/8/8 w - - 0 1", "f3")
    checkMoves(moves, ["f3f4"])

    // Capture
    moves = try getMoves("8/8/8/8/4r1r1/5P2/8/8 w - - 0 1", "f3")
    checkMoves(moves, ["f3e4", "f3f4", "f3g4"])

    // Twice forward
    moves = try getMoves("8/8/8/8/8/8/5P2/8 w - - 0 1", "f2")
    checkMoves(moves, ["f2f3", "f2f4"])

    // Twice forward, blocked
    moves = try getMoves("8/8/8/8/8/5p2/5P2/8 w - - 0 1", "f2")
    checkMoves(moves, [])

    // Promotion
    moves = try getMoves("6n1/5P2/8/8/8/8/8/8 w - - 0 1", "f7")
    checkMoves(
      moves,
      [
        "f7f8b", "f7f8n", "f7f8q", "f7f8r",
        "f7g8b", "f7g8n", "f7g8q", "f7g8r",
      ])

    // En Passant
    moves = try getMoves("rnbqkbnr/pppp1pp1/7p/4pP2/8/8/PPPPP1PP/RNBQKBNR w KQkq e6 0 3", "f5")
    checkMoves(moves, ["f5f6", "f5e6"])
  }

  func testMovePawn_black() throws {
    // Blocked
    var moves = try getMoves("8/5p2/5p2/8/8/8/8/8 b - - 0 1", "f7")
    checkMoves(moves, [])

    // Forward
    moves = try getMoves("8/5p2/5p2/8/8/8/8/8 b - - 0 1", "f6")
    checkMoves(moves, ["f6f5"])

    // Capture
    moves = try getMoves("8/5p2/5pB1/8/8/8/8/8 b - - 0 1", "f7")
    checkMoves(moves, ["f7g6"])

    // Twice forward
    moves = try getMoves("8/5p2/8/8/8/8/8/8 b - - 0 1", "f7")
    checkMoves(moves, ["f7f6", "f7f5"])

    // Promotion
    moves = try getMoves("8/8/8/8/8/8/5p2/8 b - - 0 1", "f2")
    checkMoves(moves, ["f2f1q", "f2f1r", "f2f1n", "f2f1b"])

    // En passant
    moves = try getMoves(
      "rnbqkbnr/ppppp1pp/8/8/5pP1/2N4P/PPPPPP2/R1BQKBNR b KQkq g3 0 3", "f4")
    checkMoves(moves, ["f4g3", "f4f3"])
  }

  func testCaptureOnlyMoves() throws {
    let board = try Board.fromFen("3k4/5P2/8/8/4Q1Nq/4b2R/3PpB2/R3K3 w Q - 0 1")
    let moves = MoveGenerator.getPossibleMoves(board, onlyCaptures: true)
    checkMoves(moves, ["h3h4", "h3e3", "g4e3", "d2e3", "e1e2", "f2e3", "f2h4", "e4e3"])
  }

  func checkMoves(_ moves: [Move], _ expected: [String]) {
    let strMoves = moves.map { $0.toLan() }
    XCTAssertEqual(strMoves.sorted(), expected.sorted())
  }

  private func getMoves(_ fen: String, _ pos: String) throws -> [Move] {
    let board = try Board.fromFen(fen)
    return MoveGenerator.getPossibleMovesSquare(board, pos: try Position.fromString(pos))
  }
}
