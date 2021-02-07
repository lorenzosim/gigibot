import Foundation

/// Allows to get information about the board, for example if a square is attacked.
public enum BoardUtil {
  /// Returrns whether the given player is in check.
  public static func isInCheck(board: Board, player: Player) -> Bool {
    // Find the king and see if it's attacked
    for pos in Position.all() {
      let square = board.getSquare(at: pos)
      if square != nil && square!.piece == Piece.king && square!.player == player {
        return isSquareAttacked(board: board, pos: pos, player: player)
      }
    }
    return false
  }

  /// Returns whether the given square for the given player is under attack.
  public static func isSquareAttacked(board: Board, pos: Position, player: Player) -> Bool {
    // Check horizontally and vertically (rook and queen)
    for offset in [(0, 1), (0, -1), (1, 0), (-1, 0)] {
      let attacker = findAttacker(board: board, pos: pos, offset: offset, player: player)
      if attacker == Piece.rook || attacker == Piece.queen {
        return true
      }
    }

    // Check diagonally (bishop and queen).
    for offset in [(1, 1), (1, -1), (-1, 1), (-1, -1)] {
      let attacker = findAttacker(board: board, pos: pos, offset: offset, player: player)
      if attacker == Piece.bishop || attacker == Piece.queen {
        return true
      }
    }

    // Check knight
    for offset in [(2, 1), (2, -1), (-2, 1), (-2, -1), (1, 2), (1, -2), (-1, 2), (-1, -2)] {
      let attacker = findAttacker(
        board: board, pos: pos, offset: offset, player: player, one_step: true)
      if attacker == Piece.knight {
        return true
      }
    }

    // Check king
    for offset in [(1, 1), (1, -1), (1, 0), (0, 1), (0, -1), (-1, -1), (-1, 0), (-1, 1)] {
      let attacker = findAttacker(
        board: board, pos: pos, offset: offset, player: player, one_step: true)
      if attacker == Piece.king {
        return true
      }
    }

    // Check pawns
    let previousRow = player.isWhite() ? pos.row + 1 : pos.row - 1
    if previousRow >= 0 && previousRow < Board.boardSize {
      for c in [pos.col + 1, pos.col - 1] {
        if c >= 0 && c < Board.boardSize {
          let sq = board.getSquare(at: Position.at(row: previousRow, col: c))
          if sq != nil && sq!.player != player && sq!.piece == Piece.pawn {
            return true
          }
        }
      }
    }
    return false
  }

  /// Returns the piece attacking the given position, if any. The piece is found by starting from
  /// the given position and adding the offset until a piece is encountered or the end of the board
  /// is reached. Can optionally only apply the offset once instead of going till the end of the board.
  private static func findAttacker(
    board: Board, pos: Position, offset: (Int, Int),
    player: Player,
    one_step: Bool = false
  ) -> Piece? {
    var r = pos.row + offset.0
    var c = pos.col + offset.1
    while r >= 0 && r < Board.boardSize && c >= 0 && c < Board.boardSize {
      let square = board.getSquare(at: Position.at(row: r, col: c))
      if square != nil {
        // One we encounter a non-empty square we have found the attacker or a piece blocking it.
        return square!.player == player ? nil : square!.piece
      }
      r += offset.0
      c += offset.1
      if one_step {
        break
      }
    }
    return nil
  }
}
