import Foundation

/// Converts to and from FEN notation.
enum FenConverter {
  static func boardFromFen(_ fen: String) throws -> Board {
    let parts = fen.split(separator: " ")
    if parts.count < 4 {
      // Fen is normally 6 parts, but we allow it with only 4 (will set initial move counts)
      throw InvalidFen.invalid(fen: fen)
    }

    // First part: pieces for each row of the board
    let rows = parts[0].split(separator: "/")
    if rows.count != Board.boardSize {
      throw InvalidFen.invalid(fen: fen)
    }
    var squares = ContiguousArray<ContiguousArray<Board.Square?>>()
    for i in 0..<Board.boardSize {
      let squareRow = try createRow(row: String(rows[Board.boardSize - 1 - i]))
      squares.append(squareRow)
    }

    // Turn
    let turn = parts[1] == "w" ? Player.white : Player.black

    // Casting rights
    let rights = parts[2]
    let castleRights = CastleRights(
      whiteKing: rights.contains("K"),
      whiteQueen: rights.contains("Q"),
      blackKing: rights.contains("k"),
      blackQueen: rights.contains("q"))

    // En passan move.
    let enPassantPos = parts[3] == "-" ? nil : try Position.fromString(String(parts[3]))

    // Number of moves.
    let halfMoveClock = parts.count > 4 ? Int(parts[4]) ?? 0 : 0
    let numFullMoves = parts.count > 5 ? Int(parts[5]) ?? 0 : 0
    return Board(
      squares: squares,
      turn: turn,
      castleRights: castleRights,
      enPassantPos: enPassantPos,
      halfMoveClock: halfMoveClock,
      numFullMoves: numFullMoves)
  }

  static func boardToFen(_ board: Board) -> String {
    var result = ""
    // Rows
    var rows: [String] = []
    for r in (0..<Board.boardSize).reversed() {
      var row = ""
      var emptyCount = 0
      for c in 0..<Board.boardSize {
        let square = board.getSquare(at: Position.at(row: r, col: c))
        if square == nil {
          emptyCount += 1
        } else {
          if emptyCount > 0 {
            row += String(emptyCount)
            emptyCount = 0
          }
          row += squareToLetter(square!)
        }
      }
      if emptyCount > 0 {
        row += String(emptyCount)
      }
      rows.append(row)
    }
    result += rows.joined(separator: "/")

    // Turn
    result += " " + (board.turn.isWhite() ? "w" : "b")

    // Caste Rights
    let casteRights = board.castleRights
    var rights = ""
    if casteRights.whiteKing {
      rights += "K"
    }
    if casteRights.whiteQueen {
      rights += "Q"
    }
    if casteRights.blackKing {
      rights += "k"
    }
    if casteRights.blackQueen {
      rights += "q"
    }
    result += " " + (rights.isEmpty ? "-" : rights)

    // En passant
    result += " " + (board.enPassantPos?.asString() ?? "-")

    // Move counts
    result += " \(board.halfMoveClock) \(board.numFullMoves)"

    return result
  }

  private static func createRow(row: String) throws -> ContiguousArray<Board.Square?> {
    var result = ContiguousArray<Board.Square?>(repeating: nil, count: Board.boardSize)
    var col = 0
    for ch in row {
      if ch.isNumber {
        // A number is the count of empty squares.
        col += ch.wholeNumberValue!
      } else {
        let square = try letterToSquare(ch)
        result[col] = square
        col += 1
      }
    }
    return result
  }

  private static func letterToSquare(_ letter: Character) throws -> Board.Square {
    let player = letter.isUppercase ? Player.white : Player.black
    let piece = try Piece.fromLetter(letter.lowercased())
    return Board.Square(piece, player)
  }

  private static func squareToLetter(_ square: Board.Square) -> String {
    let character = square.piece.letter()
    return square.player.isWhite() ? character.uppercased() : character
  }

  enum InvalidFen: Error {
    case invalid(fen: String)
  }
}
