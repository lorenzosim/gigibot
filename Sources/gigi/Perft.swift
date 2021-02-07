import Foundation

/// Generates all the possible moves up to the given depth. Useful to test the chess engine by comparing the number of moves with
/// canonical results.
enum Perf {

  /// Returns the possible number of moves with the given depth on the given board. Can optionally print some info, including execution
  /// time and number of moves for each sub-move.
  static func perft(_ board: Board, depth: Int, printInfo: Bool = true) -> Int {
    let start = DispatchTime.now()
    let count = getNumMoves(board, depth: depth, printMoves: printInfo)
    let diff = DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds
    if printInfo {
      print("\nTotal: \(count), calculated in \(diff/1_000_000)ms")
    }
    return count
  }

  private static func getNumMoves(_ board: Board, depth: Int, printMoves: Bool) -> Int {
    if depth == 0 {
      return 1
    }
    var count = 0
    let moves = MoveGenerator.getPossibleMoves(board)
    for move in moves {
      let newboard = move.make(board)
      if BoardUtil.isInCheck(board: newboard, player: board.turn) {
        // We can't walk into a check.
        continue
      }
      let subcount = getNumMoves(newboard, depth: depth - 1, printMoves: false)
      count += subcount
      if printMoves {
        print(move.toLan() + ": " + String(subcount))
      }
    }
    return count
  }
}
