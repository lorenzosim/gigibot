import Foundation

import class gigi.CommandHandler

// Disable stdout buffering, we need to reply to commands right away.
setbuf(stdout, nil)
CommandHandler().start()
