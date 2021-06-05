//
//  UnicodeScalar.swift
//  SwiftSoup
//
//  Created by Nabil Chatbi on 14/11/16.
//  Copyright © 2016 Nabil Chatbi. All rights reserved.
//

import Foundation

private let uppercaseSet = CharacterSet.uppercaseLetters
private let lowercaseSet = CharacterSet.lowercaseLetters
private let alphaSet = CharacterSet.letters
private let alphaNumericSet = CharacterSet.alphanumerics
private let symbolSet = CharacterSet.symbols
private let digitSet = CharacterSet.decimalDigits

public extension UnicodeScalar {
    static let Ampersand: UnicodeScalar = "&"
    static let LessThan: UnicodeScalar = "<"
    static let GreaterThan: UnicodeScalar = ">"

    static let Space: UnicodeScalar = " "
    static let BackslashF = UnicodeScalar(12)
    static let BackslashT: UnicodeScalar = "\t"
    static let BackslashN: UnicodeScalar = "\n"
    static let BackslashR: UnicodeScalar = "\r"
    static let Slash: UnicodeScalar = "/"

    static let FormFeed: UnicodeScalar = "\u{000B}" // Form Feed
    static let VerticalTab: UnicodeScalar = "\u{000C}" // vertical tab

    internal func isMemberOfCharacterSet(_ set: CharacterSet) -> Bool {
        return set.contains(self)
    }

    /// True for any space character, and the control characters \t, \n, \r, \f, \v.
    internal var isWhitespace: Bool {
        switch self {
        case UnicodeScalar.Space, UnicodeScalar.BackslashT, UnicodeScalar.BackslashN, UnicodeScalar.BackslashR, UnicodeScalar.BackslashF: return true

        case UnicodeScalar.FormFeed, UnicodeScalar.VerticalTab: return true // Form Feed, vertical tab

        default: return false
        }
    }

    /// `true` if `self` normalized contains a single code unit that is in the categories of Uppercase and Titlecase Letters.
    internal var isUppercase: Bool {
        return isMemberOfCharacterSet(uppercaseSet)
    }

    /// `true` if `self` normalized contains a single code unit that is in the category of Lowercase Letters.
    internal var isLowercase: Bool {
        return isMemberOfCharacterSet(lowercaseSet)
    }

    internal var uppercase: UnicodeScalar {
        let str = String(self).uppercased()
        return str.unicodeScalar(0)
    }
}
