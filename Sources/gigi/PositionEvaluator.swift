import Foundation

/// Evaluates the "score" of a position in centipawns. Uses a simple evaluation function, with a value for each piece and square, see:
/// https://www.chessprogramming.org/Simplified_Evaluation_Function
public enum PositionEvaluator {
  /// Score for each piece. Using an array instead of a dictionary since that's way faster.
  private static let scoreByPiece = createScoreByPiece()

  /// Additional score for each piece and square. Using an array instead of a dictionary since
  /// that's way faster.
  private static let bonusScoreByPiece = createScoreboard()

  /// Bonus score to use for the king during the endgame.
  private static let bonusScoreKingEndGame = createKingScoreboardEndgame()

  /// Bonus score to use for the king during the middle game..
  private static let bonusScoreKingMiddleGame = createKingScoreboardMiddleGame()

  /// Calculates the score for the given board, in centipawns. The score is relative to the current turn, not to white.
  public static func getBoardScore(_ board: Board) -> Int {
    var score = 0
    var numQueens = [0, 0]
    var numRooks = [0, 0]
    var numMinorPieces = [0, 0]
    var kingSquares: [Position?] = [nil, nil]

    for pos in Position.all() {
      let square = board.getSquare(at: pos)
      if square == nil {
        continue
      }
      // Update pieces counts/positions.
      let piece = square!.piece
      let player = square!.player
      if piece == Piece.queen {
        numQueens[player.rawValue] += 1
      } else if piece == Piece.rook {
        numRooks[player.rawValue] += 1
      } else if piece == .king {
        kingSquares[player.rawValue] = pos
      } else if piece.isMinor() {
        numMinorPieces[player.rawValue] += 1
      }

      // Update score: score for each piece plus a bonus for each position.
      // The bonus for the king is calculated later, since it needs additional info.
      var squareScore = scoreByPiece[piece.rawValue]
      if piece != Piece.king {
        // Need to mirror the row since we have just 1 table for both players.
        let row = square!.player.isWhite() ? Board.boardSize - pos.row - 1 : pos.row
        squareScore += bonusScoreByPiece[piece.rawValue][row][pos.col]
      }
      score += square!.player == board.turn ? squareScore : -squareScore
    }

    // Rough guess for the endgame: no queens or queen and max 1 minor piece.
    let isEndGame =
      (numQueens[0] == 0 || (numQueens[0] == 1 && numRooks[0] == 0 && numMinorPieces[0] <= 1))
      && (numQueens[1] == 0 || (numQueens[1] == 1 && numRooks[1] == 0 && numMinorPieces[1] <= 1))

    // Compute additional scores for the kings, using the appropriate boards.
    for player in [Player.white, Player.black] {
      let pos = kingSquares[player.rawValue]
      if pos != nil {
        let row = player.isWhite() ? Board.boardSize - pos!.row - 1 : pos!.row
        let pieceScore =
          isEndGame
          ? bonusScoreKingEndGame[row][pos!.col] : bonusScoreKingMiddleGame[row][pos!.col]
        score += player == board.turn ? pieceScore : -pieceScore
      }
    }
    return score
  }

  private static func createScoreByPiece() -> [Int] {
    var result: [Int] = Array()
    result.insert(100, at: Piece.pawn.rawValue)
    result.insert(320, at: Piece.knight.rawValue)
    result.insert(330, at: Piece.bishop.rawValue)
    result.insert(500, at: Piece.rook.rawValue)
    result.insert(900, at: Piece.queen.rawValue)
    result.insert(20_000, at: Piece.king.rawValue)
    return result
  }

  private static func createScoreboard() -> [[[Int]]] {
    var result: [[[Int]]] = Array()

    result.insert(
      [
        [0, 0, 0, 0, 0, 0, 0, 0],
        [50, 50, 50, 50, 50, 50, 50, 50],
        [10, 10, 20, 30, 30, 20, 10, 10],
        [5, 5, 10, 25, 25, 10, 5, 5],
        [0, 0, 0, 20, 20, 0, 0, 0],
        [5, -5, -10, 0, 0, -10, -5, 5],
        [5, 10, 10, -20, -20, 10, 10, 5],
        [0, 0, 0, 0, 0, 0, 0, 0],
      ],
      at: Piece.pawn.rawValue)

    result.insert(
      [
        [-50, -40, -30, -30, -30, -30, -40, -50],
        [-40, -20, 0, 0, 0, 0, -20, -40],
        [-30, 0, 10, 15, 15, 10, 0, -30],
        [-30, 5, 15, 20, 20, 15, 5, -30],
        [-30, 0, 15, 20, 20, 15, 0, -30],
        [-30, 5, 10, 15, 15, 10, 5, -30],
        [-40, -20, 0, 5, 5, 0, -20, -40],
        [-50, -40, -30, -30, -30, -30, -40, -50],
      ],
      at: Piece.knight.rawValue)

    result.insert(
      [
        [-20, -10, -10, -10, -10, -10, -10, -20],
        [-10, 0, 0, 0, 0, 0, 0, -10],
        [-10, 0, 5, 10, 10, 5, 0, -10],
        [-10, 5, 5, 10, 10, 5, 5, -10],
        [-10, 0, 10, 10, 10, 10, 0, -10],
        [-10, 10, 10, 10, 10, 10, 10, -10],
        [-10, 5, 0, 0, 0, 0, 5, -10],
        [-20, -10, -10, -10, -10, -10, -10, -20],
      ],
      at: Piece.bishop.rawValue)

    result.insert(
      [
        [0, 0, 0, 0, 0, 0, 0, 0],
        [5, 10, 10, 10, 10, 10, 10, 5],
        [-5, 0, 0, 0, 0, 0, 0, -5],
        [-5, 0, 0, 0, 0, 0, 0, -5],
        [-5, 0, 0, 0, 0, 0, 0, -5],
        [-5, 0, 0, 0, 0, 0, 0, -5],
        [-5, 0, 0, 0, 0, 0, 0, -5],
        [0, 0, 0, 5, 5, 0, 0, 0],
      ],
      at: Piece.rook.rawValue)

    result.insert(
      [
        [-20, -10, -10, -5, -5, -10, -10, -20],
        [-10, 0, 0, 0, 0, 0, 0, -10],
        [-10, 0, 5, 5, 5, 5, 0, -10],
        [-5, 0, 5, 5, 5, 5, 0, -5],
        [0, 0, 5, 5, 5, 5, 0, -5],
        [-10, 5, 5, 5, 5, 5, 0, -10],
        [-10, 0, 5, 0, 0, 0, 0, -10],
        [-20, -10, -10, -5, -5, -10, -10, -20],
      ],
      at: Piece.queen.rawValue)
    return result
  }

  private static func createKingScoreboardMiddleGame() -> [[Int]] {
    return
      [
        [-30, -40, -40, -50, -50, -40, -40, -30],
        [-30, -40, -40, -50, -50, -40, -40, -30],
        [-30, -40, -40, -50, -50, -40, -40, -30],
        [-30, -40, -40, -50, -50, -40, -40, -30],
        [-20, -30, -30, -40, -40, -30, -30, -20],
        [-10, -20, -20, -20, -20, -20, -20, -10],
        [20, 20, 0, 0, 0, 0, 20, 20],
        [20, 30, 10, 0, 0, 10, 30, 20],
      ]
  }

  private static func createKingScoreboardEndgame() -> [[Int]] {
    return
      [
        [-50, -40, -30, -20, -20, -30, -40, -50],
        [-30, -20, -10, 0, 0, -10, -20, -30],
        [-30, -10, 20, 30, 30, 20, -10, -30],
        [-30, -10, 30, 40, 40, 30, -10, -30],
        [-30, -10, 30, 40, 40, 30, -10, -30],
        [-30, -10, 20, 30, 30, 20, -10, -30],
        [-30, -30, 0, 0, 0, 0, -30, -30],
        [-50, -30, -30, -30, -30, -30, -30, -50],
      ]
  }
}
