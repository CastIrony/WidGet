//
//  Evaluator.swift
//  SwiftSoup
//
//  Created by Nabil Chatbi on 22/10/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation

/**
 * Evaluates that an element matches the selector.
 */
public class Evaluator {
    init() {}

    /**
     * Test if the element meets the evaluator's requirements.
     *
     * @param root    Root of the matching subtree
     * @param element tested element
     * @return Returns <tt>true</tt> if the requirements are met or
     * <tt>false</tt> otherwise
     */
    open func matches(_: Element, _: Element) throws -> Bool {
        preconditionFailure("self method must be overridden")
    }

    open func toString() -> String {
        preconditionFailure("self method must be overridden")
    }

    /**
     * Evaluator for tag name
     */
    public class Tag: Evaluator {
        private let tagName: String
        private let tagNameNormal: String

        public init(_ tagName: String) {
            self.tagName = tagName
            tagNameNormal = tagName.lowercased()
        }

        override open func matches(_: Element, _ element: Element) throws -> Bool {
            return element.tagNameNormal() == tagNameNormal
        }

        override open func toString() -> String {
            return String(tagName)
        }
    }

    /**
     * Evaluator for tag name that ends with
     */
    public final class TagEndsWith: Evaluator {
        private let tagName: String

        public init(_ tagName: String) {
            self.tagName = tagName
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            return (element.tagName().hasSuffix(tagName))
        }

        override public func toString() -> String {
            return String(tagName)
        }
    }

    /**
     * Evaluator for element id
     */
    public final class Id: Evaluator {
        private let id: String

        public init(_ id: String) {
            self.id = id
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            return (id == element.id())
        }

        override public func toString() -> String {
            return "#\(id)"
        }
    }

    /**
     * Evaluator for element class
     */
    public final class Class: Evaluator {
        private let className: String

        public init(_ className: String) {
            self.className = className
        }

        override public func matches(_: Element, _ element: Element) -> Bool {
            return (element.hasClass(className))
        }

        override public func toString() -> String {
            return ".\(className)"
        }
    }

    /**
     * Evaluator for attribute name matching
     */
    public final class Attribute: Evaluator {
        private let key: String

        public init(_ key: String) {
            self.key = key
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            return element.hasAttr(key)
        }

        override public func toString() -> String {
            return "[\(key)]"
        }
    }

    /**
     * Evaluator for attribute name prefix matching
     */
    public final class AttributeStarting: Evaluator {
        private let keyPrefix: String

        public init(_ keyPrefix: String) throws {
            try Validate.notEmpty(string: keyPrefix)
            self.keyPrefix = keyPrefix.lowercased()
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            if let values = element.getAttributes() {
                for attribute in values where attribute.getKey().lowercased().hasPrefix(keyPrefix) {
                    return true
                }
            }
            return false
        }

        override public func toString() -> String {
            return "[^\(keyPrefix)]"
        }
    }

    /**
     * Evaluator for attribute name/value matching
     */
    public final class AttributeWithValue: AttributeKeyPair {
        override public init(_ key: String, _ value: String) throws {
            try super.init(key, value)
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            if element.hasAttr(key) {
                let string = try element.attr(key)
                return value.equalsIgnoreCase(string: string.trim())
            }
            return false
        }

        override public func toString() -> String {
            return "[\(key)=\(value)]"
        }
    }

    /**
     * Evaluator for attribute name != value matching
     */
    public final class AttributeWithValueNot: AttributeKeyPair {
        override public init(_ key: String, _ value: String) throws {
            try super.init(key, value)
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            let string = try element.attr(key)
            return !value.equalsIgnoreCase(string: string)
        }

        override public func toString() -> String {
            return "[\(key)!=\(value)]"
        }
    }

    /**
     * Evaluator for attribute name/value matching (value prefix)
     */
    public final class AttributeWithValueStarting: AttributeKeyPair {
        override public init(_ key: String, _ value: String) throws {
            try super.init(key, value)
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            if element.hasAttr(key) {
                return try element.attr(key).lowercased().hasPrefix(value) // value is lower case already
            }
            return false
        }

        override public func toString() -> String {
            return "[\(key)^=\(value)]"
        }
    }

    /**
     * Evaluator for attribute name/value matching (value ending)
     */
    public final class AttributeWithValueEnding: AttributeKeyPair {
        override public init(_ key: String, _ value: String) throws {
            try super.init(key, value)
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            if element.hasAttr(key) {
                return try element.attr(key).lowercased().hasSuffix(value) // value is lower case
            }
            return false
        }

        override public func toString() -> String {
            return "[\(key)$=\(value)]"
        }
    }

    /**
     * Evaluator for attribute name/value matching (value containing)
     */
    public final class AttributeWithValueContaining: AttributeKeyPair {
        override public init(_ key: String, _ value: String) throws {
            try super.init(key, value)
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            if element.hasAttr(key) {
                return try element.attr(key).lowercased().contains(value) // value is lower case
            }
            return false
        }

        override public func toString() -> String {
            return "[\(key)*=\(value)]"
        }
    }

    /**
     * Evaluator for attribute name/value matching (value regex matching)
     */
    public final class AttributeWithValueMatching: Evaluator {
        let key: String
        let pattern: Pattern

        public init(_ key: String, _ pattern: Pattern) {
            self.key = key.trim().lowercased()
            self.pattern = pattern
            super.init()
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            if element.hasAttr(key) {
                let string = try element.attr(key)
                return pattern.matcher(in: string).find()
            }
            return false
        }

        override public func toString() -> String {
            return "[\(key)~=\(pattern.toString())]"
        }
    }

    /**
     * Abstract evaluator for attribute name/value matching
     */
    public class AttributeKeyPair: Evaluator {
        let key: String
        var value: String

        public init(_ key: String, _ value2: String) throws {
            var value2 = value2
            try Validate.notEmpty(string: key)
            try Validate.notEmpty(string: value2)

            self.key = key.trim().lowercased()
            if value2.startsWith("\"") && value2.hasSuffix("\"") || value2.startsWith("'") && value2.hasSuffix("'") {
                value2 = value2.substring(1, value2.count - 2)
            }
            value = value2.trim().lowercased()
        }

        override open func matches(_: Element, _: Element) throws -> Bool {
            preconditionFailure("self method must be overridden")
        }
    }

    /**
     * Evaluator for any / all element matching
     */
    public final class AllElements: Evaluator {
        override public func matches(_: Element, _: Element) throws -> Bool {
            return true
        }

        override public func toString() -> String {
            return "*"
        }
    }

    /**
     * Evaluator for matching by sibling index number (e {@literal <} idx)
     */
    public final class IndexLessThan: IndexEvaluator {
        override public init(_ index: Int) {
            super.init(index)
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            return try element.elementSiblingIndex() < index
        }

        override public func toString() -> String {
            return ":lt(\(index))"
        }
    }

    /**
     * Evaluator for matching by sibling index number (e {@literal >} idx)
     */
    public final class IndexGreaterThan: IndexEvaluator {
        override public init(_ index: Int) {
            super.init(index)
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            return try element.elementSiblingIndex() > index
        }

        override public func toString() -> String {
            return ":gt(\(index))"
        }
    }

    /**
     * Evaluator for matching by sibling index number (e = idx)
     */
    public final class IndexEquals: IndexEvaluator {
        override public init(_ index: Int) {
            super.init(index)
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            return try element.elementSiblingIndex() == index
        }

        override public func toString() -> String {
            return ":eq(\(index))"
        }
    }

    /**
     * Evaluator for matching the last sibling (css :last-child)
     */
    public final class IsLastChild: Evaluator {
        override public func matches(_: Element, _ element: Element) throws -> Bool {
            if let parent = element.parent() {
                let index = try element.elementSiblingIndex()
                return !(parent is Document) && index == (parent.getChildNodes().count - 1)
            }
            return false
        }

        override public func toString() -> String {
            return ":last-child"
        }
    }

    public final class IsFirstOfType: IsNthOfType {
        public init() {
            super.init(0, 1)
        }

        override public func toString() -> String {
            return ":first-of-type"
        }
    }

    public final class IsLastOfType: IsNthLastOfType {
        public init() {
            super.init(0, 1)
        }

        override public func toString() -> String {
            return ":last-of-type"
        }
    }

    public class CssNthEvaluator: Evaluator {
        public let a: Int
        public let b: Int

        public init(_ a: Int, _ b: Int) {
            self.a = a
            self.b = b
        }

        public init(_ b: Int) {
            a = 0
            self.b = b
        }

        override open func matches(_ root: Element, _ element: Element) throws -> Bool {
            let p: Element? = element.parent()
            if p == nil || ((p as? Document) != nil) { return false }

            let pos: Int = try calculatePosition(root, element)
            if a == 0 { return pos == b }

            return (pos - b) * a >= 0 && (pos - b) % a == 0
        }

        override open func toString() -> String {
            if a == 0 {
                return ":\(getPseudoClass())(\(b))"
            }
            if b == 0 {
                return ":\(getPseudoClass())(\(a))"
            }
            return ":\(getPseudoClass())(\(a)\(b))"
        }

        open func getPseudoClass() -> String {
            preconditionFailure("self method must be overridden")
        }

        open func calculatePosition(_: Element, _: Element) throws -> Int {
            preconditionFailure("self method must be overridden")
        }
    }

    /**
     * css-compatible Evaluator for :eq (css :nth-child)
     *
     * @see IndexEquals
     */
    public final class IsNthChild: CssNthEvaluator {
        override public init(_ a: Int, _ b: Int) {
            super.init(a, b)
        }

        override public func calculatePosition(_: Element, _ element: Element) throws -> Int {
            return try element.elementSiblingIndex() + 1
        }

        override public func getPseudoClass() -> String {
            return "nth-child"
        }
    }

    /**
     * css pseudo class :nth-last-child)
     *
     * @see IndexEquals
     */
    public final class IsNthLastChild: CssNthEvaluator {
        override public init(_ a: Int, _ b: Int) {
            super.init(a, b)
        }

        override public func calculatePosition(_: Element, _ element: Element) throws -> Int {
            var i = 0

            if let l = element.parent() {
                i = l.children().array().count
            }
            return i - (try element.elementSiblingIndex())
        }

        override public func getPseudoClass() -> String {
            return "nth-last-child"
        }
    }

    /**
     * css pseudo class nth-of-type
     *
     */
    public class IsNthOfType: CssNthEvaluator {
        override public init(_ a: Int, _ b: Int) {
            super.init(a, b)
        }

        override open func calculatePosition(_: Element, _ element: Element) -> Int {
            var pos = 0
            let family: Elements? = element.parent()?.children()
            if let array = family?.array() {
                for el in array {
                    if el.tag() == element.tag() { pos += 1 }
                    if el === element { break }
                }
            }

            return pos
        }

        override open func getPseudoClass() -> String {
            return "nth-of-type"
        }
    }

    public class IsNthLastOfType: CssNthEvaluator {
        override public init(_ a: Int, _ b: Int) {
            super.init(a, b)
        }

        override open func calculatePosition(_: Element, _ element: Element) throws -> Int {
            var pos = 0
            if let family = element.parent()?.children() {
                let x = try element.elementSiblingIndex()
                for i in x ..< family.array().count {
                    if family.get(i).tag() == element.tag() {
                        pos += 1
                    }
                }
            }

            return pos
        }

        override open func getPseudoClass() -> String {
            return "nth-last-of-type"
        }
    }

    /**
     * Evaluator for matching the first sibling (css :first-child)
     */
    public final class IsFirstChild: Evaluator {
        override public func matches(_: Element, _ element: Element) throws -> Bool {
            let p = element.parent()
            if p != nil, !((p as? Document) != nil) {
                return (try element.elementSiblingIndex()) == 0
            }
            return false
        }

        override public func toString() -> String {
            return ":first-child"
        }
    }

    /**
     * css3 pseudo-class :root
     * @see <a href="http://www.w3.org/TR/selectors/#root-pseudo">:root selector</a>
     *
     */
    public final class IsRoot: Evaluator {
        override public func matches(_ root: Element, _ element: Element) throws -> Bool {
            let r: Element = ((root as? Document) != nil) ? root.child(0) : root
            return element === r
        }

        override public func toString() -> String {
            return ":root"
        }
    }

    public final class IsOnlyChild: Evaluator {
        override public func matches(_: Element, _ element: Element) throws -> Bool {
            let p = element.parent()
            return p != nil && !((p as? Document) != nil) && element.siblingElements().array().count == 0
        }

        override public func toString() -> String {
            return ":only-child"
        }
    }

    public final class IsOnlyOfType: Evaluator {
        override public func matches(_: Element, _ element: Element) throws -> Bool {
            let p = element.parent()
            if p == nil || (p as? Document) != nil { return false }

            var pos = 0
            if let family = p?.children().array() {
                for el in family {
                    if el.tag() == element.tag() { pos += 1 }
                }
            }
            return pos == 1
        }

        override public func toString() -> String {
            return ":only-of-type"
        }
    }

    public final class IsEmpty: Evaluator {
        override public func matches(_: Element, _ element: Element) throws -> Bool {
            let family: [Node] = element.getChildNodes()
            for n in family {
                if !((n as? Comment) != nil || (n as? XmlDeclaration) != nil || (n as? DocumentType) != nil) { return false }
            }
            return true
        }

        override public func toString() -> String {
            return ":empty"
        }
    }

    /**
     * Abstract evaluator for sibling index matching
     *
     * @author ant
     */
    public class IndexEvaluator: Evaluator {
        let index: Int

        public init(_ index: Int) {
            self.index = index
        }
    }

    /**
     * Evaluator for matching Element (and its descendants) text
     */
    public final class ContainsText: Evaluator {
        private let searchText: String

        public init(_ searchText: String) {
            self.searchText = searchText.lowercased()
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            return (try element.text().lowercased().contains(searchText))
        }

        override public func toString() -> String {
            return ":contains(\(searchText)"
        }
    }

    /**
     * Evaluator for matching Element's own text
     */
    public final class ContainsOwnText: Evaluator {
        private let searchText: String

        public init(_ searchText: String) {
            self.searchText = searchText.lowercased()
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            return (element.ownText().lowercased().contains(searchText))
        }

        override public func toString() -> String {
            return ":containsOwn(\(searchText)"
        }
    }

    /**
     * Evaluator for matching Element (and its descendants) text with regex
     */
    public final class Matches: Evaluator {
        private let pattern: Pattern

        public init(_ pattern: Pattern) {
            self.pattern = pattern
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            let m = try pattern.matcher(in: element.text())
            return m.find()
        }

        override public func toString() -> String {
            return ":matches(\(pattern)"
        }
    }

    /**
     * Evaluator for matching Element's own text with regex
     */
    public final class MatchesOwn: Evaluator {
        private let pattern: Pattern

        public init(_ pattern: Pattern) {
            self.pattern = pattern
        }

        override public func matches(_: Element, _ element: Element) throws -> Bool {
            let m = pattern.matcher(in: element.ownText())
            return m.find()
        }

        override public func toString() -> String {
            return ":matchesOwn(\(pattern.toString())"
        }
    }
}
