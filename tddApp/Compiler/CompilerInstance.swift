//
//  CompilerInstance.swift
//  tddApp
//
//  Created by Tony Toussaint on 11/27/19.
//  Copyright © 2019 Tony Toussaint. All rights reserved.
//

import Foundation
import UIKit
import Antlr4

class CompilerInstance {
    
    func run(code: String, viewController: ViewController) {
        do {
            let lexer = tddLexer(ANTLRInputStream(code))
            let tokens = CommonTokenStream(lexer)
            let parser = try tddParser(tokens)
            let tree = try parser.program()
            let walker = ParseTreeWalker()
            let tddBaseListenerInstance = tddBaseListener.init()
            tddBaseListenerInstance.runTests = viewController.isOn
            tddBaseListenerInstance.inputs = viewController.input
            try walker.walk(tddBaseListenerInstance, tree)
            viewController.mdView.load(markdown: tddBaseListenerInstance.documentation)
            viewController.outputTextView.text = tddBaseListenerInstance.outputs
        } catch {
            print("Parse error: \(error.localizedDescription)")
        }

    }
    
    
}
