import Foundation


func enableRawMode() {
    var raw:termios = termios()

    tcgetattr(STDIN_FILENO, &raw)
    
}


//var c:Int = 1
var c:Character = "a"

while read(STDIN_FILENO, &c, 1) == 1 && c != "q" {
}
