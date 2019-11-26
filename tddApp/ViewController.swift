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
    }
    
    
    @IBAction func onCompileClick(_ sender: UIButton) {
    }
    
    @IBAction func onRunClick(_ sender: UIButton) {
    }
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var codeTextView: UITextView!
    
    @IBOutlet weak var outputTextView: UITextView!
    
    
    let codeSamples = [String]()
    
    
    func addBorder(textView: UITextView) {
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 0.5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        // Do any additional setup after loading the view.
        let mdView = MarkdownView()
        let documentation = """
        # Documentation
        ## nam
        Ala a
        ### Parameters:
        | Type | Name | Description |
        | --- | --- | --- |
        | int | a | A value |
        | int | b | B value |
        ## suma
        Function to add two variables
        ### Parameters:
        | Type | Name | Description |
        | --- | --- | --- |
        | int | a | First value to add |
        | int | b | Second value to add |
        ### Returns
        | Type | Description |
        | --- | --- |
        | int | la suma de los dos numeros |
        ## Tests
        - **suma**(2,4) => 6
        - **suma**(120,200) => 320
        ## noReturn
        A void function with no params
        ## noReturnParams
        A void function with params
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

