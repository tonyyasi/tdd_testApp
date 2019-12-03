//
//  ViewController.swift
//  tddApp
//
//  Created by Tony Toussaint on 11/26/19.
//  Copyright © 2019 Tony Toussaint. All rights reserved.
//

import UIKit
import MarkdownView

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return examples.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return examples[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Interact with selected row
        codeTextView.text = examples[row].code
        mdView.load(markdown: "## Compile the code to see the generated documentation!")
        
    }
    
    
    @IBAction func onCompileClick(_ sender: UIButton) {
        
    }
    
    @IBAction func onRunClick(_ sender: UIButton) {
        input = []
        let basictext = inputTextView.text
        if basictext != "" {
        let splitText = basictext?.components(separatedBy: "\n")
        
        input = splitText ?? []
        }
    
        compInstance.run(code: self.codeTextView.text, viewController: self)
        
    }
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var testSwitch: UISwitch!
    @IBOutlet weak var codeTextView: UITextView!
    @IBAction func changeSwitch(_ sender: UISwitch) {
        self.isOn = sender.isOn
        print("Changing is On")
    }
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var outputTextView: UITextView!
    
    
    let codeSamples = [String]()
    public var mdView: MarkdownView!
    let compInstance = CompilerInstance()
    
    func addBorder(textView: UITextView) {
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 0.5
    }
    
    public func changeDoc(doc: String) {
        
    }
    
    public var isOn : Bool = true
    public var input : [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        isOn = testSwitch.isOn
        addBorder(textView: inputTextView)
        // Do any additional setup after loading the view.
         mdView = MarkdownView()
        let documentation = """
        ## Compile the code to see the generated documentation!
        """
        addBorder(textView: codeTextView)
        addBorder(textView: outputTextView)
        view.addSubview(mdView)
        mdView.translatesAutoresizingMaskIntoConstraints = false
        mdView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mdView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mdView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mdView.bottomAnchor.constraint(equalTo: codeTextView.topAnchor).isActive = true
        mdView.load(markdown: documentation)
        codeTextView.text = examples[0].code
        outputTextView.text = ""
        
    }


}

