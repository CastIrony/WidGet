//
//  CombiningEvaluator.swift
//  SwiftSoup
//
//  Created by Nabil Chatbi on 23/10/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation

/**
 * Base combining (and, or) evaluator.
 */
public class CombiningEvaluator: Evaluator {
    public private(set) var evaluators: [Evaluator]
    var num: Int = 0

    override public init() {
        evaluators = [Evaluator]()
        super.init()
    }

    public init(_ evaluators: [Evaluator]) {
        self.evaluators = evaluators
        super.init()
        updateNumEvaluators()
    }

    public init(_ evaluators: Evaluator...) {
        self.evaluators = evaluators
        super.init()
        updateNumEvaluators()
    }

    func rightMostEvaluator() -> Evaluator? {
        return num > 0 && evaluators.count > 0 ? evaluators[num - 1] : nil
    }

    func replaceRightMostEvaluator(_ replacement: Evaluator) {
        evaluators[num - 1] = replacement
    }

    func updateNumEvaluators() {
        // used so we don't need to bash on size() for every match test
        num = evaluators.count
    }

    public final class And: CombiningEvaluator {
        override public init(_ evaluators: [Evaluator]) {
            super.init(evaluators)
        }

        override public init(_ evaluators: Evaluator...) {
            super.init(evaluators)
        }

        override public func matches(_ root: Element, _ node: Element) -> Bool {
            for index in 0 ..< num {
                let evaluator = evaluators[index]
                do {
                    if try !evaluator.matches(root, node) {
                        return false
                    }
                } catch {}
            }

            return true
        }

        override public func toString() -> String {
            let array: [String] = evaluators.map { String($0.toString()) }
            return StringUtil.join(array, sep: " ")
        }
    }

    public final class Or: CombiningEvaluator {
        /**
         * Create a new Or evaluator. The initial evaluators are ANDed together and used as the first clause of the OR.
         * @param evaluators initial OR clause (these are wrapped into an AND evaluator).
         */
        override public init(_ evaluators: [Evaluator]) {
            super.init()
            if num > 1 {
                self.evaluators.append(And(evaluators))
            } else { // 0 or 1
                self.evaluators.append(contentsOf: evaluators)
            }
            updateNumEvaluators()
        }

        override init(_ evaluators: Evaluator...) {
            super.init()
            if num > 1 {
                self.evaluators.append(And(evaluators))
            } else { // 0 or 1
                self.evaluators.append(contentsOf: evaluators)
            }
            updateNumEvaluators()
        }

        override init() {
            super.init()
        }

        public func add(_ evaluator: Evaluator) {
            evaluators.append(evaluator)
            updateNumEvaluators()
        }

        override public func matches(_ root: Element, _ node: Element) -> Bool {
            for index in 0 ..< num {
                let evaluator: Evaluator = evaluators[index]
                do {
                    if try evaluator.matches(root, node) {
                        return true
                    }
                } catch {}
            }
            return false
        }

        override public func toString() -> String {
            return ":or\(evaluators.map { String($0.toString()) })"
        }
    }
}
