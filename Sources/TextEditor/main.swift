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
    let lflag = raw.c_lflag & ~UInt(ECHO | ICANON)
    raw.c_lflag = lflag
    
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw)
}

// -------------------
// Program begins here
// -------------------
enableRawMode()

var c:Int32 = 0
// loops until q is entered
while read(STDIN_FILENO, &c, 1) == 1 && c != 113 {
    // displays value of key pressed
    if iscntrl(c) == 1 {
        print(c)
    } else {
        print("\(c) {\(Character(UnicodeScalar(Int(c))!))}")
    }
}
