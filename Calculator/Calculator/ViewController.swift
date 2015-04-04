//
//  ViewController.swift
//  Calculator
//
//  Created by Иван on 05.03.15.
//  Copyright (c) 2015 KKK. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var stat: UILabel!
    
    var userIsInTheMiddleOfTypingANumber: Bool = false
    var userEnteredDot = false
    var brain = CalculatorBrain()
    var wasCleared = false
    
    
    @IBAction func clearScreen(sender: UIButton) {
        display.text = "0"
        stat.text = " "
        brain.clearStack()
        wasCleared = true
    }
    
    @IBAction func bSpace(sender: UIButton) {
        if countElements(display.text!) <= 1
        {
            display.text = "0"
        }
        else
        {
            display.text = dropLast(display.text!)
        }
    }
    
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber{
            if digit == "."
            {
                userEnteredDot = true
            }
            if !userEnteredDot
            {
                display.text = display.text! + digit
            }
            else
            {
                display.text = "err"
            }
        }
        else
        {
            if digit == "."
            {
                display.text = "0."
                userEnteredDot = true
            }
            else{
                display.text = digit
            }
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber
        {
            enter()
        }
        if let operation = sender.currentTitle
        {
            if let result = brain.performOperation(operation){
                displayValue = result
                stat.text = stat.text! + brain.descriprion
            }
            else {
                displayValue = nil
                display.text = "0"
            }
        }
        
    }
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue){
            displayValue = result
            
        }
        else {
            displayValue = nil
            display.text = "0"
        }
    }
    
    var displayValue: Double! {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}

