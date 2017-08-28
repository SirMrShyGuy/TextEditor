import Foundation // Using Foundation contains all the C libraies needed (alternative could be Darwin.c)

// -----------------------
// Setup code for raw mode
// -----------------------
var orig_termios = termios()

func die(str:UnsafePointer<Int8>!) {
    perror(str)
    exit(1)
}

func disableRawMode() {
    if tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios) == -1 {
        die(str: "tcsetattr")
    }
}

func enableRawMode() {
    if tcgetattr(STDIN_FILENO, &orig_termios) == -1 { die(str: "tcsetattr") }
    atexit { disableRawMode() }
    
    // creating a copy that can be modified so the program can revert to the original on exit
    var raw = orig_termios

    //ECHO: prints key pressed into terminal
    //ICANON: Turns off canonical mode changing input from byte to byte to line to line
    //ISIG: Turns off Ctrl-C and Ctrl-Z from sending there signals
    //IEXTEN: Turns off Ctrl-V from sending it's signal
    raw.c_lflag = raw.c_lflag & ~UInt(ECHO | ICANON | ISIG | IEXTEN)
    //IXON: Turns off Ctrl-S and Ctrl-Q from sending there signals
    //ICRNL: Fixes Ctrl-M to sent 13 instead of 10
    //BRKINT: Flag is mostlikly irelevent for modern terminal emu but is considered for raw mode
    //INPCK: Flag is mostlikly irelevent for modern terminal emu but is considered for raw mode
    //ISTRIP: Flag is mostlikly irelevent for modern terminal emu but is considered for raw mode
    raw.c_iflag = raw.c_iflag & ~UInt(IXON | ICRNL | BRKINT | INPCK | ISTRIP)
    //OPOST: Turns off translating \n from enter to \r\n
    raw.c_oflag = raw.c_oflag & ~UInt(OPOST)
    //CS8: Flag is mostlikly irelevent for modern terminal emu but is considered for raw mode
    raw.c_cflag = raw.c_cflag & ~UInt(CS8)
    
    // Using numbers beacuase raw.c_cc is a tuple
    //VTIME = 17
    //VMIN = 16
    raw.c_cc.17 = 1
    raw.c_cc.16 = 0
    
    if tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) == -1 { die(str: "tcsetattr") }
}

// -------------------
// Code for user input/output
// -------------------


func editorReadKey() -> Int32 {
    var c:Int32 = 0
    var nread:Int = 0
    while nread != 1 {
        nread = read(STDIN_FILENO, &c, 1)
        if nread == -1 && errno != EAGAIN { die(str: "Read") }
    }
    return c
}

func editorProcessKeypress() {
    let c = editorReadKey()
    
    switch c {
    case 17:
        exit(0)
    default:
        break
    }
}

func editorRefreshScreen() {
    // \u{1b} is used instead of \x1b due to \x not being valid in swift
    // \u{1b}[2J clears and refreshed the terminal
//    write(STDOUT_FILENO, "\u{1b}[2J", 4)
    // print will work but need an update (such as newline) to be seen
    // still test functionality
    print("\u{1b}[2J", terminator: "")
    print("t", terminator: "")
    
}

// -------------------
// Program begins here
// -------------------
enableRawMode()

while true {
    editorRefreshScreen()
    editorProcessKeypress()
}
