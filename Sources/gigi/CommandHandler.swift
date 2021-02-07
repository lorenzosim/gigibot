import Foundation

/// Handles UCI commands. Doesn't support all the commands, for instance there's no handling for pondering.
public class CommandHandler {
  private static let version = "1.0"

  /// File path where to log all the commands sent and received, useful for debugging.
  private let logFilePath: String?
  private var logFileHandle: FileHandle? = nil
  private var game: Game? = nil

  public init(logFilePath: String? = nil) {
    self.logFilePath = logFilePath
    initLogFile()
  }

  public func start() {
    print("Gigi \(CommandHandler.version)")
    while true {
      let command = readLine() ?? "quit"
      handleCommand(command)
    }
  }

  private func handleCommand(_ command: String) {
    logCommand("<" + command)

    switch command {
    case "quit":
      exit(0)
    case "isready":
      respond("readyok")
    case "uci":
      respond("id name Gigi \(CommandHandler.version)")
      respond("uciok")
    case "ucinewgame":
      game = nil
    case _ where command.starts(with: "setoption"):
      respond("No such option")
    case _ where command.starts(with: "position "):
      handlePositionCommand(String(command.dropFirst("position ".count)))
    case _ where command.starts(with: "go perft"):
      // Unofficial, but very handy for testing.
      let board = game == nil ? Board.startingPosition() : game!.getBoard()
      let depth = Int(command.dropFirst("go perft ".count)) ?? 1
      let _ = Perf.perft(board, depth: depth)
    case _ where command.starts(with: "go"):
      handleGoCommand(String(command.dropFirst("go".count)))
    case "stop":
      if game != nil {
        game!.stopSearch()
      }
    default:
      respond("Unknown command")
    }
  }

  private func handlePositionCommand(_ command: String) {
    // FEN or starting position
    switch command {
    case _ where command.starts(with: "fen"):
      do {
        let fen = command.dropFirst("fen ".count)
        let board = try Board.fromFen(String(fen))
        game = Game(board: board)
      } catch {
        respond("Invalid fen string")
        return
      }
    case _ where command.starts(with: "startpos"):
      let board = Board.startingPosition()
      game = Game(board: board)
    default:
      respond("Invalid position command")
      return
    }

    // Moves
    if let movesPos = command.range(of: "moves") {
      let moves = String(command.suffix(from: movesPos.upperBound)).split(separator: " ")
      for moveString in moves {
        let move: Move
        do {
          move = try Move.fromLan(String(moveString))
        } catch {
          respond("Ignoring invalid move \(moveString)")
          continue
        }
        try! game!.move(move)
      }
    }
  }

  private func handleGoCommand(_ command: String) {
    guard let currentGame = game else {
      return
    }

    let timeOptions = parseTimeOptions(turn: currentGame.getBoard().turn, command: command)
    do {
      try currentGame.findBestMove(
        timeOptions: timeOptions,
        callback: { (pv: PrincipalVariation) -> Void in
          if self.game === currentGame {
            let score: String
            if pv.isMate() {
              score = "mate \(pv.score > 0 ? "" : "-")\(pv.getNumMoves())"
            } else {
              score = "cp \(pv.score)"
            }
            self.respond(
              "info depth \(pv.getDepth()) "
                + "score \(score) "
                + "pv \(pv.getPv())")
            self.respond("bestmove \(pv.getFirstMove()!.toLan())")
          }
        })
    } catch Game.GameError.searchInProgress {
      respond("Ignoring, a search is already in progress")
    } catch {
      respond("Internal error")
    }
  }

  private func parseTimeOptions(turn: Player, command: String) -> Game.TimeStatus {
    var moveTime: Int? = nil
    var timeLeft: Int? = nil
    var timeIncrement = 0
    var movesToGo: Int? = nil

    let ourTimeProperty = turn.isWhite() ? "wtime" : "btime"
    let ourIncrementProperty = turn.isWhite() ? "winc" : "binc"
    let options = command.split(separator: " ")
    for (index, option) in options.enumerated() {
      switch option {
      case "movetime":
        moveTime = Int(options[index + 1]) ?? nil
      case ourTimeProperty:
        timeLeft = Int(options[index + 1]) ?? nil
      case ourIncrementProperty:
        timeIncrement = Int(options[index + 1]) ?? 0
      case "movestogo":
        movesToGo = Int(options[index + 1]) ?? nil
      default:
        break  // Ignore
      }
    }
    return Game.TimeStatus(
      moveTime: moveTime, timeLeftMs: timeLeft,
      timeIncrementMs: timeIncrement, movesToGo: movesToGo)
  }

  private func respond(_ value: String) {
    print(value)
    logCommand(">" + value)
  }

  private func logCommand(_ command: String) {
    guard let logFileHandle = logFileHandle else {
      return
    }
    let data = (command + "\n").data(using: String.Encoding.utf8)!
    logFileHandle.write(data)
    logFileHandle.synchronizeFile()
  }

  private func initLogFile() {
    guard let logFilePath = logFilePath else {
      return
    }
    if !FileManager.default.fileExists(atPath: logFilePath) {
      if !FileManager.default.createFile(atPath: logFilePath, contents: nil) {
        print("Error creating file at path \(logFilePath)")
      }
    }
    self.logFileHandle = FileHandle(forWritingAtPath: logFilePath)
    if self.logFileHandle != nil {
      self.logFileHandle!.seekToEndOfFile()
    }
  }
}
