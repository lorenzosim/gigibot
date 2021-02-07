import Foundation

/// A chess game, with the current status of the board and the ability to find the best move.
public class Game {
  private var board: Board
  private var searcher: MoveSearcher?
  private let dispatchQueue = DispatchQueue(label: "moveSearcher", attributes: .concurrent)

  public init(board: Board) {
    self.board = board
  }

  public func getBoard() -> Board {
    return board
  }

  /// Find the best move and returns its principal variation. This method will search accoring to the given time options, but it can always
  /// forced to return right away by calling the stopSearch method.
  public func findBestMove(
    timeOptions: TimeStatus, callback: @escaping (PrincipalVariation) -> Void
  ) throws {
    if searcher != nil {
      throw GameError.searchInProgress
    }
    searcher = MoveSearcher()
    let maxTimeMs = timeOptions.getMaxMoveTimeMs()
    let currentBoard = board
    var searchCompleted = false

    dispatchQueue.async {
      let bestMove = self.searcher!.findBestMove(currentBoard)
      searchCompleted = true
      self.searcher = nil
      callback(bestMove)
    }
    if maxTimeMs != nil {
      // If we have a maximum time, stop the searcher once we reach it. Do that only if the search
      // wasn't already completed (can happen in case of mate).
      dispatchQueue.asyncAfter(deadline: .now() + .milliseconds(maxTimeMs!)) {
        if !searchCompleted {
          self.searcher!.stop()
        }
      }
    }
  }

  public func stopSearch() {
    if searcher != nil {
      searcher!.stop()
    }
  }

  public func move(_ move: Move) throws {
    if searcher != nil {
      throw GameError.searchInProgress
    }
    board = move.make(board)
  }

  enum GameError: Error {
    case searchInProgress
  }

  /// The timing options at this point of the game. Supports the following:
  /// -Specifc time to make the move
  /// -Time left to make N moves or until the end, with an optional increment per move
  /// -No limits at all (useful for a analysis where the user can stop it manually)
  public struct TimeStatus {
    /// A complete guess on how many moves remain.
    private static let estimatedMovesToGo = 40
    let moveTime: Int?
    let timeLeftMs: Int?
    let timeIncrementMs: Int?
    let movesToGo: Int?

    init(moveTime: Int?, timeLeftMs: Int?, timeIncrementMs: Int?, movesToGo: Int?) {
      self.moveTime = moveTime
      self.timeLeftMs = timeLeftMs
      self.timeIncrementMs = timeIncrementMs
      self.movesToGo = movesToGo
    }

    /// Tries to guess how much time we should allocate for the next move.
    func getMaxMoveTimeMs() -> Int? {
      if moveTime != nil {
        // We have a specific limit, use it
        return moveTime!
      }
      if timeLeftMs == nil {
        // No limit (search will need to be manually stopped)
        return nil
      }

      // For simplicity, divide the time equally between the remaining moves.
      let remainingMoves = movesToGo ?? TimeStatus.estimatedMovesToGo
      let moveIncrement = self.timeIncrementMs ?? 0
      return ((moveIncrement * remainingMoves) + timeLeftMs!) / remainingMoves
    }
  }
}
