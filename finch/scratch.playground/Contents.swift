import Cocoa
import finch

let sep: String = "; -> "
var v = [Double](repeating: 8, count: 11)
var rex: String = "[[[["
print(v, separator: "<><>,,", terminator: sep, to: &rex)

print(rex)





