//
//  File.swift
//  
//
//  Created by Gendler, Bob (Fed) on 4/14/22.
//
import Foundation

#if os(Windows)
struct Colors {
    static let reset = ""
    static let black = ""
    static let red = ""
    static let green = ""
    static let yellow = ""
    static let blue = ""
    static let magenta = ""
    static let cyan = ""
    static let white = ""
    static let bold = ""
    static let blink = ""
    static let clearscreen = ""
}

#else
struct Colors {
    static let reset = "\u{001B}[0;0m"
    static let black = "\u{001B}[0;30m"
    static let red = "\u{001B}[0;31m"
    static let green = "\u{001B}[0;32m"
    static let yellow = "\u{001B}[0;33m"
    static let blue = "\u{001B}[0;34m"
    static let magenta = "\u{001B}[0;35m"
    static let cyan = "\u{001B}[0;36m"
    static let white = "\u{001B}[0;37m"
    static let bold = "\u{001B}[0;1m"
    static let blink = "\u{001B}[0;5m"
    static let clearscreen = "\u{001B}[2J"
}
#endif
