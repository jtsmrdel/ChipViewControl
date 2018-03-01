//
//  ChipTextFieldView.swift
//  ChipViewControl
//
//  Created by JT Smrdel on 2/24/18.
//  Copyright © 2018 JT Smrdel. All rights reserved.
//

import UIKit

public class ChipTextFieldView: UIView {

    public var chipTextField: ChipTextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        addConstraint(NSLayoutConstraint(item: chipTextField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: chipTextField, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: chipTextField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    func configureView(heightForChip: CGFloat, placeholder: String?, font: UIFont?) {
        
        autoresizingMask = [.flexibleWidth]
        
        chipTextField = ChipTextField(frame: CGRect.zero)
        chipTextField.placeholder = placeholder
        chipTextField.borderStyle = .none
        chipTextField.backgroundColor = UIColor.clear
        chipTextField.font = UIFont.systemFont(ofSize: 17.0)
        let textFieldSize = chipTextField.sizeThatFits(CGSize(width: 10.0, height: heightForChip))
        chipTextField.font = font ?? UIFont.systemFont(ofSize: 17.0)
        
        if let chipFont = chipTextField.font, chipFont.pointSize > heightForChip - 10 {
            chipTextField.font = chipFont.withSize(heightForChip - 10)
        }
        
        chipTextField.translatesAutoresizingMaskIntoConstraints = false
        chipTextField.frame = CGRect(x: 0, y: 0, width: textFieldSize.width, height: heightForChip - 10)
        addSubview(chipTextField)
        
        frame = CGRect(x: 0, y: 0, width: chipTextField.frame.width, height: heightForChip)
    }
}
