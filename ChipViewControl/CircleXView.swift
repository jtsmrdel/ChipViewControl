//
//  CircleXView.swift
//  ChipViewControl
//
//  Created by JT Smrdel on 2/24/18.
//  Copyright © 2018 JT Smrdel. All rights reserved.
//

import UIKit

class CircleXView: UIView {

    var xColor = UIColor.lightGray
    var hasBorder = false
    var borderColor: UIColor = .white
    
    override func draw(_ rect: CGRect) {
        
        clipsToBounds = true
        layer.cornerRadius = rect.height / 2
        
        if hasBorder {
            layer.borderWidth = 1.5
            layer.borderColor = borderColor.cgColor
        }
        
        let lineOnePath = UIBezierPath()
        lineOnePath.lineWidth = 1.5
        lineOnePath.move(to: CGPoint(x: rect.width * 0.25, y: rect.height * 0.75))
        lineOnePath.addLine(to: CGPoint(x: rect.width * 0.75, y: rect.height * 0.25))
        xColor.setStroke()
        lineOnePath.stroke()
        
        let lineTwoPath = UIBezierPath()
        lineTwoPath.lineWidth = 1.5
        lineTwoPath.move(to: CGPoint(x: rect.width * 0.25, y: rect.height * 0.25))
        lineTwoPath.addLine(to: CGPoint(x: rect.width * 0.75, y: rect.height * 0.75))
        xColor.setStroke()
        lineTwoPath.stroke()
    }
}
