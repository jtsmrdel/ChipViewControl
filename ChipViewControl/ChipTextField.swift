//
//  ChipTextField.swift
//  ChipViewControl
//
//  Created by JT Smrdel on 2/24/18.
//  Copyright © 2018 JT Smrdel. All rights reserved.
//

import UIKit

public class ChipTextField: UITextField {

    var rawText: String? {
        return super.text
    }
    
    override public var text: String? {
        get {
            return super.text?.replacingOccurrences(of: "\u{200B}", with: "")
        }
        set {
            
            if let newText = newValue, newText == "" {
                
                if let chipViewControl = self.superview?.superview?.superview?.superview as? ChipViewControl, chipViewControl.numberOfChips > 0 {
                    super.text = "\u{200B}"
                }
            }
            else {
                super.text = newValue
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override public func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        
        // Disable zooming
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
            gestureRecognizer.isEnabled = false
        }
        super.addGestureRecognizer(gestureRecognizer)
    }
}
