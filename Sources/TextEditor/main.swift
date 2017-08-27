import Foundation // Using Foundation contains all the C libraies needed (alternative could be Darwin.c)

var orig_termios = termios()

func disableRawMode() {
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios)
}

func enableRawMode() {
    tcgetattr(STDIN_FILENO, &orig_termios)
    atexit { disableRawMode() }
    
    var raw = orig_termios

    //ECHO: prints key pressed into terminal
    //ICANON: Turns off canonical mode changing input from byte to byte to line to line
    //ISIG: Turns off Ctrl-C and Ctrl-Z from sending there signals
    //IEXTEN: Turns off Ctrl-V from sending it's signal
    let lflag = raw.c_lflag & ~UInt(ECHO | ICANON | ISIG | IEXTEN)
    raw.c_lflag = lflag
    //IXON: Turns off Ctrl-S and Ctrl-Q from sending there signals
    //ICRNL: Fixes Ctrl-M to sent 13 instead of 10
    //BRKINT: Flag is mostlikly irelevent for modern terminal emu but is considered for raw mode
    //INPCK: Flag is mostlikly irelevent for modern terminal emu but is considered for raw mode
    //ISTRIP: Flag is mostlikly irelevent for modern terminal emu but is considered for raw mode
    let iflag = raw.c_iflag & ~UInt(IXON | ICRNL | BRKINT | INPCK | ISTRIP)
    raw.c_iflag = iflag
    //OPOST: Turns off translating \n from enter to \r\n
    let oflag = raw.c_oflag & ~UInt(OPOST)
    raw.c_oflag = oflag
    //CS8: Flag is mostlikly irelevent for modern terminal emu but is considered for raw mode
    let cflag = raw.c_cflag & ~UInt(CS8)
    raw.c_cflag = cflag
    
    //VTIME = 17
    //VMIN = 16
    raw.c_cc.17 = 1
    raw.c_cc.16 = 0
    
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw)
}

// -------------------
// Program begins here
// -------------------
enableRawMode()

var c:Int32 = 0
// loops until q is entered
while true {
    // displays value of key pressed
    read(STDIN_FILENO, &c, 1)
    if iscntrl(c) == 1 {
//        print(c)
        print(c, terminator: "\r\n")
    } else {
//        print("\(c) {\(Character(UnicodeScalar(Int(c))!))}")
        print("\(c) {\(Character(UnicodeScalar(Int(c))!))}", terminator: "\r\n")
    }
    if c == 113 { break }
}
