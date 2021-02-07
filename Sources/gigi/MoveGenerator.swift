import Foundation

/// Generates chess moves.
public enum MoveGenerator {
  /// Returns all the pseudolegal (ignores checks) moves on the given board.
  public static func getPossibleMoves(_ board: Board, onlyCaptures: Bool = false) -> [Move] {
    var gen = InternalGenerator(board: board, onlyCaptures: onlyCaptures)
    gen.getAllSquaresMoves()
    return gen.moves
  }

  /// Returns all the pseudolegal (ignores checks) moves on the given board for the piece on the given square.
  public static func getPossibleMovesSquare(
    _ board: Board, pos: Position, onlyCaptures: Bool = false
  )
    -> [Move]
  {
    var gen = InternalGenerator(board: board, onlyCaptures: onlyCaptures)
    gen.genSquareMoves(pos: pos)
    return gen.moves
  }
}

private struct InternalGenerator {
  let board: Board
  let onlyCaptures: Bool
  var moves: [Move]

  init(board: Board, onlyCaptures: Bool) {
    self.board = board
    self.onlyCaptures = onlyCaptures
    self.moves = []
  }

  mutating func getAllSquaresMoves() {
    for pos in Position.all() {
      genSquareMoves(pos: pos)
    }
  }

  mutating func genSquareMoves(pos: Position) {
    let square = board.getSquare(at: pos)
    if square == nil || square!.player != board.turn {
      return
    }

    switch square!.piece {
    case .bishop:
      genMoves([(1, 1), (1, -1), (-1, -1), (-1, 1)], pos: pos)
    case .rook:
      genMoves([(1, 0), (-1, 0), (0, 1), (0, -1)], pos: pos)
    case .queen:
      genMoves([(1, 1), (1, -1), (1, 0), (0, 1), (0, -1), (-1, -1), (-1, 0), (-1, 1)], pos: pos)
    case .king:
      genKingMoves(pos: pos)
    case .knight:
      genMoves(
        [(1, 2), (1, -2), (-1, 2), (-1, -2), (2, 1), (2, -1), (-2, 1), (-2, -1)], pos: pos,
        oneStep: true)
    case .pawn:
      genPawnMoves(pos: pos)
    }
  }

  private mutating func genMoves(_ offsets: [(Int, Int)], pos: Position, oneStep: Bool = false) {
    for offset in offsets {
      var r = pos.row + offset.0
      var c = pos.col + offset.1
      while r >= 0 && r < Board.boardSize && c >= 0 && c < Board.boardSize {
        let to = Position.at(row: r, col: c)
        let square = board.getSquare(at: to)
        if square == nil {
          // Move to the square
          if !onlyCaptures {
            moves.append(Move(from: pos, to: to))
          }
        } else {
          if square!.player != board.turn {
            // Capture
            moves.append(Move(from: pos, to: to))
          }
          // Either we capture or there's a piece blocking us, in either case we are done.
          break
        }
        if oneStep {
          break
        }
        r += offset.0
        c += offset.1
      }
    }
  }

  private mutating func genPawnMoves(pos: Position) {
    let turn = board.turn
    let pawnStartRow = turn.isWhite() ? 1 : 6
    let offset = turn.isWhite() ? 1 : -1
    let nextRow = pos.row + offset

    // Advance
    if !onlyCaptures {
      if board.getSquare(at: Position.at(row: nextRow, col: pos.col)) == nil {
        // Advance 1 square
        genPawMoves(turn: turn, from: pos, to: Position.at(row: nextRow, col: pos.col))
        if pos.row == pawnStartRow
          && board.getSquare(at: Position.at(row: nextRow + offset, col: pos.col)) == nil
        {
          // Advance 2 squares
          genPawMoves(
            turn: turn, from: pos, to: Position.at(row: nextRow + offset, col: pos.col))
        }
      }
    }

    // Capture
    for col in [pos.col - 1, pos.col + 1] {
      if col >= 0 && col < Board.boardSize {
        let destSquare = board.getSquare(at: Position.at(row: nextRow, col: col))
        if destSquare != nil && destSquare!.player != turn {
          genPawMoves(
            turn: turn, from: pos, to: Position.at(row: nextRow, col: col))
        }
      }
    }

    // Capture en passant
    let enPassantPos = board.enPassantPos
    if enPassantPos != nil
      && enPassantPos!.row == nextRow
      && abs(enPassantPos!.col - pos.col) == 1
    {
      moves.append(Move(from: pos, to: Position.at(row: enPassantPos!.row, col: enPassantPos!.col)))
    }
  }

  private mutating func genPawMoves(turn: Player, from: Position, to: Position) {
    let lastRow = turn.isWhite() ? 7 : 0
    if to.row == lastRow {
      // Pawn is promoting, generation promotions with all possible pieces.
      for piece in [Piece.queen, Piece.rook, Piece.knight, Piece.bishop] {
        moves.append(Move(from: from, to: to, promotionPiece: piece))
      }
    } else {
      // Regular advance
      moves.append(Move(from: from, to: to))
    }
  }

  private mutating func genKingMoves(pos: Position) {
    genMoves(
      [(1, 1), (1, -1), (1, 0), (0, 1), (0, -1), (-1, -1), (-1, 0), (-1, 1)], pos: pos,
      oneStep: true)

    if onlyCaptures {
      return
    }

    // Castling.
    // Note: no need to check where the king/rooks are since castle rights are revoked if they
    // ever moved.
    let kingRow = board.turn.isWhite() ? 0 : 7
    if board.hasKingCastleRight()
      && canCastle(row: kingRow, emptyCols: [5, 6], notAttackedCols: [4, 5, 6])
    {
      moves.append(
        Move(from: Position.at(row: kingRow, col: 4), to: Position.at(row: kingRow, col: 6)))
    }
    if board.hasQueenCastleRight()
      && canCastle(row: kingRow, emptyCols: [1, 2, 3], notAttackedCols: [2, 3, 4])
    {
      moves.append(
        Move(from: Position.at(row: kingRow, col: 4), to: Position.at(row: kingRow, col: 2)))
    }
  }

  private func canCastle(row: Int, emptyCols: [Int], notAttackedCols: [Int]) -> Bool {
    // Check empty squares
    for col in emptyCols {
      if board.getSquare(at: Position.at(row: row, col: col)) != nil {
        return false
      }
    }
    // Check not attacked
    for col in notAttackedCols {
      if BoardUtil.isSquareAttacked(
        board: board, pos: Position.at(row: row, col: col), player: board.turn)
      {
        return false
      }
    }
    return true
  }
}
