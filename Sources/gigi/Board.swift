import Foundation

/// A chess board at a particular position, including the current turn, casteling rights and en passan state.
public struct Board {
  static let boardSize = 8
  // Squares in row-major order.
  let squares: ContiguousArray<ContiguousArray<Square?>>
  let turn: Player
  let castleRights: CastleRights
  let enPassantPos: Position?
  let halfMoveClock: Int
  let numFullMoves: Int

  init(
    squares: ContiguousArray<ContiguousArray<Square?>>, turn: Player, castleRights: CastleRights,
    enPassantPos: Position?, halfMoveClock: Int, numFullMoves: Int
  ) {
    self.squares = squares
    self.turn = turn
    self.enPassantPos = enPassantPos
    self.castleRights = castleRights
    self.halfMoveClock = halfMoveClock
    self.numFullMoves = numFullMoves
  }

  public static func startingPosition() -> Board {
    return try! FenConverter.boardFromFen(
      "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
  }

  public static func fromFen(_ fen: String) throws -> Board {
    return try FenConverter.boardFromFen(fen)
  }

  public func toFen() -> String {
    return FenConverter.boardToFen(self)
  }

  public func getSquare(at pos: Position) -> Square? {
    return squares[pos.row][pos.col]
  }

  public func hasKingCastleRight() -> Bool {
    return turn.isWhite() ? castleRights.whiteKing : castleRights.blackKing
  }

  public func hasQueenCastleRight() -> Bool {
    return turn.isWhite() ? castleRights.whiteQueen : castleRights.blackQueen
  }

  /// A non-empty square of the board. Empty squares are represented with nil.
  public struct Square {
    let piece: Piece
    let player: Player

    public init(_ piece: Piece, _ player: Player) {
      self.piece = piece
      self.player = player
    }
  }
}

/// A chess piece.
public enum Piece: Int, CaseIterable {
  case pawn = 0
  case knight, bishop, rook, queen, king

  public static func fromLetter(_ letter: String) throws -> Piece {
    for piece in Piece.allCases {
      if piece.letter() == letter {
        return piece
      }
    }
    throw InvalidPiece.invalid(letter: letter)
  }

  public func letter() -> String {
    switch self {
    case .king:
      return "k"
    case .queen:
      return "q"
    case .rook:
      return "r"
    case .bishop:
      return "b"
    case .knight:
      return "n"
    case .pawn:
      return "p"
    }
  }

  public func isMajor() -> Bool {
    return self == .queen || self == .rook
  }

  public func isMinor() -> Bool {
    return self == .bishop || self == .knight
  }

  enum InvalidPiece: Error {
    case invalid(letter: String)
  }
}

/// The player: black or white.
public enum Player: Int {
  case white = 0
  case black

  public func opposite() -> Player {
    return isWhite() ? .black : .white
  }

  public func isWhite() -> Bool {
    return self == .white
  }

  public func isBlack() -> Bool {
    return self == .black
  }
}

/// The rights to castle. Note: does not take into consideration checks.
public struct CastleRights {
  let whiteKing: Bool  // White, king-side
  let whiteQueen: Bool  // White, queen-side
  let blackKing: Bool  // Black, king-side
  let blackQueen: Bool  // Black, queen-side

  public init(whiteKing: Bool, whiteQueen: Bool, blackKing: Bool, blackQueen: Bool) {
    self.whiteKing = whiteKing
    self.whiteQueen = whiteQueen
    self.blackKing = blackKing
    self.blackQueen = blackQueen
  }

  /// Returns new rights, removing the right for the given player and optionally for a specific side only.
  public func removeFor(player: Player, kingSide: Bool? = nil) -> CastleRights {
    let setKingSide = kingSide == nil || kingSide!
    let setQueenSide = kingSide == nil || !(kingSide!)

    let newWhiteKing = player.isWhite() && setKingSide ? false : whiteKing
    let newWhiteQueen = player.isWhite() && setQueenSide ? false : whiteQueen
    let newBlackKing = player.isBlack() && setKingSide ? false : blackKing
    let newBlackQueen = player.isBlack() && setQueenSide ? false : blackQueen

    return CastleRights(
      whiteKing: newWhiteKing,
      whiteQueen: newWhiteQueen,
      blackKing: newBlackKing,
      blackQueen: newBlackQueen)
  }
}

/// A position on the board
public struct Position: Equatable {
  private static let allPositions = genAllPositions()  // DO NOT SUBMIT.....DOES THIS ACTUALLY NOT COPY? IF NOT MIGHT AW WELL GET RID OF IT.
  let row: Int
  let col: Int

  private init(row: Int, col: Int) {
    self.row = row
    self.col = col
  }

  public static func at(row: Int, col: Int) -> Position {
    return allPositions[row * Board.boardSize + col]
  }

  public static func all() -> ContiguousArray<Position> {
    return allPositions
  }

  static func fromString(_ str: String) throws -> Position {
    if str.count != 2 {
      throw InvalidPosition.invalid(pos: str)
    }
    let aPos = Character("a").asciiValue!
    let col = Int(str[str.index(str.startIndex, offsetBy: 0)].asciiValue! - aPos)
    let row = str[str.index(str.startIndex, offsetBy: 1)].wholeNumberValue! - 1

    if row < 0 || row > Board.boardSize || col < 0 || col > Board.boardSize {
      throw InvalidPosition.invalid(pos: str)
    }
    return at(row: row, col: col)
  }

  func asString() -> String {
    let r = String(row + 1)
    let c = String(UnicodeScalar(UInt8(col) + Character("a").asciiValue!))
    return c + r
  }

  public static func == (lhs: Position, rhs: Position) -> Bool {
    return lhs.row == rhs.row && lhs.col == rhs.col
  }

  private static func genAllPositions() -> ContiguousArray<Position> {
    var result = ContiguousArray<Position>()
    for r in 0..<Board.boardSize {
      for c in 0..<Board.boardSize {
        result.append(Position(row: r, col: c))
      }
    }
    return result
  }

  enum InvalidPosition: Error {
    case invalid(pos: String)
  }
}
