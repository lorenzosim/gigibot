import Foundation

/// A chess move.
public struct Move: CustomStringConvertible {
  let from: Position
  let to: Position
  let promotionPiece: Piece?

  public init(from: Position, to: Position, promotionPiece: Piece? = nil) {
    self.from = from
    self.to = to
    self.promotionPiece = promotionPiece
  }

  /// Creates the move from algebraic notation.
  public static func fromLan(_ lan: String) throws -> Move {
    let from = try Position.fromString(String(lan.prefix(2)))

    let startIdx = lan.startIndex
    let toString = lan[lan.index(startIdx, offsetBy: 2)..<lan.index(startIdx, offsetBy: 4)]
    let to = try Position.fromString(String(toString))

    let pieceLetter = lan.count > 4 ? lan[lan.index(startIdx, offsetBy: 4)] : nil
    let piece = pieceLetter == nil ? nil : try Piece.fromLetter(String(pieceLetter!))
    return Move(from: from, to: to, promotionPiece: piece)
  }

  /// Makes the move on the board and returns the updated board.
  public func make(_ board: Board) -> Board {
    let movedPiece = board.getSquare(at: from)!.piece

    // Update half move clock
    let halfMoveClock: Int
    if movedPiece == Piece.pawn || board.getSquare(at: to) != nil {
      halfMoveClock = 0
    } else {
      halfMoveClock = board.halfMoveClock + 1
    }

    // Update the destination.
    var newSquares = board.squares
    if promotionPiece == nil {
      newSquares[to.row][to.col] = newSquares[from.row][from.col]
    } else {
      newSquares[to.row][to.col] = Board.Square(promotionPiece!, board.turn)
    }

    // If En passant, remove the captured pawn.
    if movedPiece == Piece.pawn && board.enPassantPos == to {
      let offset = board.turn.isWhite() ? -1 : 1
      newSquares[to.row + offset][to.col] = nil
    }

    // If castling, move the rook as well
    if movedPiece == Piece.king && abs(from.col - to.col) > 1 {
      if to.col == 6 {
        // Castle king-side.
        newSquares[to.row][5] = newSquares[to.row][7]
        newSquares[to.row][7] = nil
      } else {
        // Castle queen-side
        newSquares[to.row][3] = newSquares[to.row][0]
        newSquares[to.row][0] = nil
      }
    }

    // Clear out from
    newSquares[from.row][from.col] = nil

    // Update our castling rights if we moved king or rook.
    var castleRights = board.castleRights
    let ourFirstRow = board.turn.isWhite() ? 0 : 7
    if from.row == ourFirstRow {
      if movedPiece == Piece.king {
        castleRights = castleRights.removeFor(player: board.turn)
      } else if movedPiece == Piece.rook {
        if from.col == 7 {
          castleRights = castleRights.removeFor(player: board.turn, kingSide: true)
        } else if from.col == 0 {
          castleRights = castleRights.removeFor(player: board.turn, kingSide: false)
        }
      }
    }

    // Update opponent's catle rights if we captured the square where the rook is.
    // If the rook is no longer there, casting rights were already removed so it's a no-op.
    let opponentFirstRow = board.turn.isWhite() ? 7 : 0
    if to.row == opponentFirstRow {
      if to.col == 7 {
        castleRights = castleRights.removeFor(player: board.turn.opposite(), kingSide: true)
      } else if to.col == 0 {
        castleRights = castleRights.removeFor(player: board.turn.opposite(), kingSide: false)
      }
    }

    // Update number of moves.
    var numFullMoves = board.numFullMoves
    if !board.turn.isWhite() {
      numFullMoves += 1
    }

    // Update en passant piece.
    var enPassantPos: Position? = nil
    if movedPiece == Piece.pawn && abs(to.row - from.row) == 2 {
      let offset = board.turn.isWhite() ? -1 : 1
      enPassantPos = Position.at(row: to.row + offset, col: to.col)
    }

    return Board(
      squares: newSquares,
      turn: board.turn.opposite(),
      castleRights: castleRights,
      enPassantPos: enPassantPos,
      halfMoveClock: halfMoveClock,
      numFullMoves: numFullMoves)
  }

  /// Returns the move in long algebraic notation.
  public func toLan() -> String {
    return from.asString() + to.asString() + (promotionPiece?.letter() ?? "")
  }

  public var description: String {
    return toLan()
  }
}
