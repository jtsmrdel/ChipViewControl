//
//  ChipView.swift
//  ChipViewControl
//
//  Created by JT Smrdel on 2/24/18.
//  Copyright © 2018 JT Smrdel. All rights reserved.
//

import UIKit

protocol ChipViewDelegate {
    func chipRemoved(chip: UIView)
}

class ChipView: UIView {

    private var titleLabel: UILabel!
    private var deleteView: CircleXView!
    
    var delegate: ChipViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: titleLabel!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 8.0))
        
        
        addConstraint(NSLayoutConstraint(item: deleteView!, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1.0, constant: 5.0))
        addConstraint(NSLayoutConstraint(item: deleteView!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -5.0))
        
        addConstraint(NSLayoutConstraint(item: deleteView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 5.0))
        addConstraint(NSLayoutConstraint(item: deleteView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -5.0))
        
        addConstraint(NSLayoutConstraint(item: deleteView!, attribute: .width, relatedBy: .equal, toItem: deleteView, attribute: .height, multiplier: 1.0, constant: 0.0))
    }
    
    func configure(chipTitle: String, heightForChip: CGFloat, availableWidth: CGFloat, chipFont: UIFont?, chipFontColor: UIColor?, chipBackgroundColor: UIColor?, deleteViewBackgroundColor: UIColor?, deleteViewXColor: UIColor?, deleteViewHasBorder: Bool?, deleteViewBorderColor: UIColor?) {
        
        backgroundColor = chipBackgroundColor ?? UIColor.groupTableViewBackground
        
        titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.text = chipTitle
        titleLabel.font = UIFont.systemFont(ofSize: 17.0)
        let labelSize = titleLabel.sizeThatFits(CGSize(width: availableWidth, height: heightForChip))
        titleLabel.font = chipFont ?? UIFont.systemFont(ofSize: 17.0)
        titleLabel.textColor = chipFontColor ?? UIColor.black
        titleLabel.baselineAdjustment = .alignCenters
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.25
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.frame = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
        addSubview(titleLabel)
        
        
        deleteView = CircleXView(frame: CGRect.zero)
        deleteView.xColor = deleteViewXColor ?? UIColor.lightGray
        deleteView.hasBorder = deleteViewHasBorder ?? false
        deleteView.borderColor = deleteViewBorderColor ?? UIColor.white
        deleteView.backgroundColor = deleteViewBackgroundColor ?? UIColor.white
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        deleteView.frame = CGRect(x: 0, y: 0, width: heightForChip - 10, height: heightForChip - 10)
        deleteView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeChip)))
        addSubview(deleteView)
        
        frame = CGRect(x: 0, y: 0, width: 8 + titleLabel.frame.width + 5 + deleteView.frame.width + 5, height: heightForChip)
    }
    
    @objc func removeChip() {
        delegate?.chipRemoved(chip: self)
    }
}
