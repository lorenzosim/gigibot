import Foundation

/// Finds the best move from a given board position using Negamax with alpha-beta pruning, see:
/// https://en.wikipedia.org/wiki/Negamax#Negamax_with_alpha_beta_pruning.
public class MoveSearcher {
  private static let quiesceMaxDepth = 2
  private var shouldStopSearch: Bool
  private let maxDepth: Int

  public init(maxDepth: Int = 1000) {
    self.maxDepth = maxDepth
    self.shouldStopSearch = false
  }

  /// Finds the best move, checking up to the specified maxDepth. Can stop earlier if mate is reached or stop() is called.
  public func findBestMove(_ board: Board) -> PrincipalVariation {
    var bestMove: PrincipalVariation? = nil

    for depth in 1...maxDepth {
      let move = calcBestMove(board, depth, alpha: -100_000, beta: 100_000)
      if shouldStopSearch {
        // If we should stop searching, don't try to use move since that is only a partial result.
        break
      }
      bestMove = move
      if move.isMate() {
        break  // No point in searching further if we already found a mate.
      }
    }

    // TODO: Could technically be null if we were stopped so early that we didn't even do depth=1.
    return bestMove!
  }

  func stop() {
    self.shouldStopSearch = true
  }

  private func calcBestMove(_ board: Board, _ depth: Int, alpha: Int, beta: Int)
    -> PrincipalVariation
  {
    if depth == 0 {
      return PrincipalVariation(
        score: calcQuiesceScore(
          board: board, alpha: alpha, beta: beta, maxDepth: MoveSearcher.quiesceMaxDepth),
        moves: [])
    }

    let moves = MoveGenerator.getPossibleMoves(board)
    var bestMove: PrincipalVariation? = nil
    var newalpha = alpha
    for move in moves {
      if shouldStopSearch {
        break
      }
      let movedBoard = move.make(board)
      if BoardUtil.isInCheck(board: movedBoard, player: board.turn) {
        // We are not allowed to move into check.
        continue
      }

      let nextMove = calcBestMove(movedBoard, depth - 1, alpha: -beta, beta: -newalpha)
      let score = -nextMove.score
      if bestMove == nil || score > bestMove!.score {
        bestMove = PrincipalVariation(score: score, moves: [move] + nextMove.moves)
      }
      newalpha = max(newalpha, score)
      if newalpha >= beta {
        break
      }
    }

    if bestMove == nil {
      // If there are no possible moves it's checkmate if we are in check, stalemate otherwise.
      let score =
        BoardUtil.isInCheck(board: board, player: board.turn)
        ? -PrincipalVariation.mateScore : 0
      return PrincipalVariation(score: score, moves: [])
    }

    return bestMove!
  }

  private func calcQuiesceScore(board: Board, alpha: Int, beta: Int, maxDepth: Int) -> Int {
    let standPat = PositionEvaluator.getBoardScore(board)
    if maxDepth == 0 || standPat >= beta {
      return standPat
    }
    var newalpha = max(alpha, standPat)

    let captureMoves = MoveGenerator.getPossibleMoves(board, onlyCaptures: true)
    for move in captureMoves {
      if shouldStopSearch {
        break
      }
      let movedBoard = move.make(board)
      if BoardUtil.isInCheck(board: movedBoard, player: board.turn) {
        // We are not allowed to move into check.
        continue
      }

      let score = -calcQuiesceScore(
        board: movedBoard, alpha: -beta, beta: -newalpha, maxDepth: maxDepth - 1)
      if score >= beta {
        return beta
      }
      newalpha = max(newalpha, score)
    }
    return newalpha
  }
}

public struct PrincipalVariation {
  // Minimum score to be considered mate.
  static let mateScore = 10_000
  public let score: Int
  public let moves: [Move]

  public init(score: Int, moves: [Move]) {
    self.score = score
    self.moves = moves
  }

  public func getPv() -> String {
    return moves.map({ $0.toLan() }).joined(separator: " ")
  }

  public func getFirstMove() -> Move? {
    return moves.count > 0 ? moves[0] : nil
  }

  public func getDepth() -> Int {
    return moves.count
  }

  public func getNumMoves() -> Int {
    return Int((Double(moves.count) / 2.0).rounded(.up))
  }

  public func isMate() -> Bool {
    return abs(score) >= PrincipalVariation.mateScore
  }
}
