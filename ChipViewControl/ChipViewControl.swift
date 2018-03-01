//
//  ChipViewControl.swift
//  ChipViewControl
//
//  Created by JT Smrdel on 2/24/18.
//  Copyright © 2018 JT Smrdel. All rights reserved.
//

import UIKit

@objc public protocol ChipViewControlDataSource: class, NSObjectProtocol {
    
    func numberOfChips(in chipViewControl: ChipViewControl) -> Int
    func chipViewTitle(for index: Int) -> String
    func chipViewControlHeightConstraint(chipViewControl: ChipViewControl) -> NSLayoutConstraint
    func heightForChipView(in chipViewControl: ChipViewControl) -> CGFloat
    @objc optional func customize(chipViewControl: ChipViewControl)
}

@objc public protocol ChipViewControlDelegate: class, NSObjectProtocol {
    
    @objc func chipViewControl(chipViewControl: ChipViewControl, didRemoveChipViewAtIndex index: Int)
    @objc optional func chipViewControl(chipViewControl: ChipViewControl, didReturnWithText text: String?)
    @objc optional func chipViewControl(chipViewControl: ChipViewControl, textDidChange text: String)
    @objc optional func chipViewControlDidBeginEditing(chipViewControl: ChipViewControl)
    @objc optional func chipViewControlShouldEndEditing(chipViewControl: ChipViewControl) -> Bool
    @objc optional func chipViewControlDidEndEditing(chipViewControl: ChipViewControl)
}

public class ChipViewControl: UIControl, UITextFieldDelegate, ChipViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak private var dataSource: ChipViewControlDataSource?
    @IBOutlet weak private var delegate: ChipViewControlDelegate?
    
    private var chipScrollView: UIScrollView!
    private var innerChipContainerView: UIView!
    private var innerChipContainerViewHeightConstraint: NSLayoutConstraint!
    private var tempTextFieldText: String?
    private var chipViews = NSMutableArray()
    private var chipContainerViewHeightConstraint: NSLayoutConstraint!
    private var originalChipContainerViewHeightConstant: CGFloat = 0.0
    private var heightForChip: CGFloat!
    private var margin: CGFloat!
    private var rowRemoved = false
    public var chipTextFieldView: ChipTextFieldView!
    
    public var _placeholderText: String? = nil
    public var _textFieldFont: UIFont? = UIFont.systemFont(ofSize: 17.0)
    public var _chipFont: UIFont? = UIFont.systemFont(ofSize: 17.0)
    public var _chipFontColor: UIColor? = UIColor.black
    public var _chipBackgroundColor: UIColor? = UIColor.groupTableViewBackground
    public var _deleteButtonBackgroundColor: UIColor? = UIColor.white
    public var _deleteButtonXColor: UIColor? = UIColor.lightGray
    
    var numberOfChips: Int {
        
        // The last chip view is always the chip text field
        return chipViews.count - 1
    }
    
    private var numberOfRows: Int {
        return Int(intrinsicContentSize.height / heightForChip)
    }
    
    override public var intrinsicContentSize: CGSize {
        get {
            if chipViews.count == 0 {
                return .zero
            }
            
            var totalRect = CGRect.null
            enumerateChipRects { (chipRect) in
                totalRect = chipRect.union(totalRect)
            }
            return totalRect.size
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let chipViewEnumerator = chipViews.objectEnumerator()
        enumerateChipRects { (chipRect) in
            if let chipView = chipViewEnumerator.nextObject() as? UIView {
                chipView.frame = chipRect
            }
        }
        
        
        // Expands the parent container view to double it's initial height when there's two rows of chips
        // When the content size exceeds two rows, the scroll view and inner container view will expand
        var heightToExpand: CGFloat = 0.0
        if intrinsicContentSize.height > heightForChip + margin {
            heightToExpand = heightForChip + margin
        }
        chipContainerViewHeightConstraint.constant = originalChipContainerViewHeightConstant + heightToExpand
        
        
        // Only allow scrolling if content height is greater than 2 rows
        chipScrollView.isScrollEnabled = numberOfRows > 2
        
        
        // If there are more than 2 rows, scroll to the bottom
        // If there are more than 2 rows and a row was removed, scrolling up will complete before
        // layoutSubViews is executed
        if numberOfRows > 2 {
            chipScrollView.setContentOffset(CGPoint(x: 0, y: intrinsicContentSize.height - frame.height + (margin * 2)), animated: true)
        }
        
        
        // When a chip is added or removed, the inner container view height will hug the chips + the margin above the top row
        // and below the bottom row
        innerChipContainerViewHeightConstraint.constant = intrinsicContentSize.height + (margin * 2)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        // This delegate function is used to animate the scroll view when removing rows
        // before the subviews are layed out
        if rowRemoved {
            layoutSubviews()
        }
    }
    
    // If the number of rows is > 1, expand/ animate the parent view so that the second row of chips are visible
    // When adding new chips, scroll the scroll view to the last row
    
    private func setup() {
        
        guard let dataSource = dataSource else { return }
        chipContainerViewHeightConstraint = dataSource.chipViewControlHeightConstraint(chipViewControl: self)
        originalChipContainerViewHeightConstant = chipContainerViewHeightConstraint.constant
        heightForChip = dataSource.heightForChipView(in: self)
        
        
        // Don't allow the chip height to be greater than the container view height
        if heightForChip > frame.height {
            heightForChip = frame.height
        }
        
        margin = (frame.height - heightForChip) / 2
        
        
        // Optional customization
        if dataSource.responds(to: #selector(ChipViewControlDataSource.customize(chipViewControl:))) {
            dataSource.customize!(chipViewControl: self)
        }
        
        // Configure scroll view
        chipScrollView = UIScrollView()
        chipScrollView.backgroundColor = UIColor.clear
        chipScrollView.delegate = self
        chipScrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chipScrollView)
        
        addConstraint(NSLayoutConstraint(item: chipScrollView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: chipScrollView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: chipScrollView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: chipScrollView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        // Configure chip container view
        innerChipContainerView = UIView()
        innerChipContainerView.backgroundColor = UIColor.clear
        innerChipContainerView.translatesAutoresizingMaskIntoConstraints = false
        chipScrollView.addSubview(innerChipContainerView)
        
        addConstraint(NSLayoutConstraint(item: innerChipContainerView, attribute: .top, relatedBy: .equal, toItem: chipScrollView, attribute: .top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: innerChipContainerView, attribute: .leading, relatedBy: .equal, toItem: chipScrollView, attribute: .leading, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: innerChipContainerView, attribute: .trailing, relatedBy: .equal, toItem: chipScrollView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: innerChipContainerView, attribute: .bottom, relatedBy: .equal, toItem: chipScrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: innerChipContainerView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0.0))
        
        innerChipContainerViewHeightConstraint = NSLayoutConstraint(item: innerChipContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: intrinsicContentSize.height)
        addConstraint(innerChipContainerViewHeightConstraint)
        
        
        clipsToBounds = true
        innerChipContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusOnTextField)))
        reloadData()
    }
    
    // Redraw the chips in the chip view control
    public func reloadData() {
        
        // Keep track of whether or not the chip text field is the first responder
        // since it's removed, re-configured, and re-added to the view
        var chipTextFieldIsFirstResponder = false
        if chipTextFieldView != nil && chipViews.contains(chipTextFieldView) {
            chipTextFieldIsFirstResponder = chipTextFieldView.chipTextField.isFirstResponder
        }
        
        guard let dataSource = dataSource else { return }
        
        for view in chipViews {
            (view as AnyObject).removeFromSuperview()
        }
        chipViews = NSMutableArray()
        
        let chipCount = dataSource.numberOfChips(in: self)
        
        for i in 0..<chipCount {
            
            let chipTitle = dataSource.chipViewTitle(for: i)
            
            let chip = ChipView(frame: CGRect(x: 0, y: 0, width: innerChipContainerView.frame.width, height: heightForChip))
            chip.delegate = self
            chip.configure(chipTitle: chipTitle, heightForChip: heightForChip, availableWidth: innerChipContainerView.frame.width - margin, chipFont: _chipFont, chipFontColor: _chipFontColor, chipBackgroundColor: _chipBackgroundColor, deleteViewBackgroundColor: _deleteButtonBackgroundColor, deleteViewXColor: _deleteButtonXColor)
            innerChipContainerView.addSubview(chip)
            chipViews.add(chip)
        }
        
        configureChipTextFieldView(textFieldIsFirstResponder: chipTextFieldIsFirstResponder)
        
        setNeedsLayout()
        chipTextFieldView.chipTextField.text = ""
    }
    
    private func configureChipTextFieldView(textFieldIsFirstResponder: Bool = false) {
        
        let placeholder = numberOfChips > 0 ? nil : _placeholderText
        
        if chipTextFieldView != nil && chipViews.contains(chipTextFieldView) {
            
            chipTextFieldView.removeFromSuperview()
            chipViews.remove(chipTextFieldView)
        }
        
        chipTextFieldView = ChipTextFieldView()
        chipTextFieldView.configureView(heightForChip: heightForChip, placeholder: placeholder, font: _textFieldFont)
        chipTextFieldView.chipTextField.delegate = self
        chipTextFieldView.chipTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        innerChipContainerView.addSubview(chipTextFieldView)
        chipViews.add(chipTextFieldView)
        
        if textFieldIsFirstResponder {
            chipTextFieldView.chipTextField.becomeFirstResponder()
        }
    }
    
    private func enumerateChipRects(completion: @escaping(_ chipRect: CGRect) -> Void) {
        
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        for chipView in chipViews {
            
            let chipContainerViewWidth = max(innerChipContainerView.bounds.width - margin, (chipView as AnyObject).frame.width)
            let chipWidth = min(innerChipContainerView.bounds.width, (chipView as AnyObject).frame.width)
            
            if x > (chipContainerViewWidth - chipWidth) {
                y += heightForChip + margin
                x = 0.0
            }
            
            if x == 0.0 {
                x = margin
            }
            
            if y == 0.0 {
                y = margin
            }
            
            if let chipTextFieldView = chipView as? ChipTextFieldView {
                
                var size = chipTextFieldView.chipTextField.sizeThatFits(CGSize(width: innerChipContainerView.bounds.height, height: heightForChip))
                if size.width > innerChipContainerView.bounds.width {
                    size.width = innerChipContainerView.bounds.width
                }
                chipTextFieldView.frame = CGRect(x: x, y: y, width: size.width, height: heightForChip)
            }
            
            completion(CGRect(x: x, y: y, width: chipWidth, height: heightForChip))
            x += chipWidth + margin
        }
    }
    
    
    func indexOfChipView(view: UIView) -> Int {
        return chipViews.index(of: view)
    }
    
    
    @objc func focusOnTextField() {
        chipTextFieldView.chipTextField.becomeFirstResponder()
    }
    
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if let textField = textField as? ChipTextField {
            tempTextFieldText = textField.rawText
        }
        
        guard let delegate = delegate else { return }
        
        if delegate.responds(to: #selector(ChipViewControlDelegate.chipViewControlDidBeginEditing(chipViewControl:))) {
            delegate.chipViewControlDidBeginEditing!(chipViewControl: self)
        }
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        guard let delegate = delegate else { return true }
        
        if delegate.responds(to: #selector(ChipViewControlDelegate.chipViewControlShouldEndEditing(chipViewControl:))) {
            return delegate.chipViewControlShouldEndEditing!(chipViewControl: self)
        }
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let delegate = delegate else { return }
        
        if delegate.responds(to: #selector(ChipViewControlDelegate.chipViewControlDidEndEditing(chipViewControl:))) {
            delegate.chipViewControlDidEndEditing!(chipViewControl: self)
        }
    }
    
    @objc func textFieldDidChange(textField: ChipTextField) {
        
        // If text is empty and there aren't any chips, display placeholder by returning
        if textField.rawText == "" && numberOfChips == 0 {
            return
        }
        
        if textField.rawText == "" {
            textField.text = "\u{200B}"
            
            if tempTextFieldText == "\u{200B}" {
                if chipViews.count > 1 {
                    
                    let removeIndex = chipViews.count - 2
                    
                    (chipViews[removeIndex] as! UIView).removeFromSuperview()
                    chipViews.removeObject(at: removeIndex)
                    
                    textField.text = ""
                    
                    if let delegate = delegate {
                        delegate.chipViewControl(chipViewControl: self, didRemoveChipViewAtIndex: removeIndex)
                    }
                    
                    // After deleting all of the chips, re-configure chip text field to show placeholder
                    if numberOfChips == 0 {
                        configureChipTextFieldView(textFieldIsFirstResponder: chipTextFieldView.chipTextField.isFirstResponder)
                    }
                }
            }
        }
        
        tempTextFieldText = textField.rawText
        layoutSubviews()
        
        if let delegate = delegate {
            if delegate.responds(to: #selector(ChipViewControlDelegate.chipViewControl(chipViewControl:textDidChange:))) {
                delegate.chipViewControl!(chipViewControl: self, textDidChange: textField.text ?? "")
            }
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let delegate = delegate else { return true }
        
        if delegate.responds(to: #selector(ChipViewControlDelegate.chipViewControl(chipViewControl:didReturnWithText:))) {
            delegate.chipViewControl!(chipViewControl: self, didReturnWithText: textField.text ?? "")
        }
        return true
    }
    
    //MARK: - ChipDelegate
    
    func chipRemoved(chip: UIView) {
        
        let oldIntrinsicContentSizeHeight = intrinsicContentSize.height
        
        let index = indexOfChipView(view: chip)
        (chipViews[index] as! UIView).removeFromSuperview()
        chipViews.removeObject(at: index)
        
        if let delegate = delegate {
            delegate.chipViewControl(chipViewControl: self, didRemoveChipViewAtIndex: index)
        }
        
        // After deleting all of the chips, re-configure chip text field to show placeholder
        if numberOfChips == 0 {
            configureChipTextFieldView(textFieldIsFirstResponder: chipTextFieldView.chipTextField.isFirstResponder)
        }
        
        if oldIntrinsicContentSizeHeight > intrinsicContentSize.height && numberOfRows >= 2 {
            
            // Row removed, scroll up
            rowRemoved = true
            chipScrollView.setContentOffset(CGPoint(x: 0, y: intrinsicContentSize.height - frame.height + (margin * 2)), animated: true)
        }
        else {
            
            // The number of rows are the same, layout chips
            layoutSubviews()
        }
    }
}
