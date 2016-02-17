//
//  CKTextEffectAuxiliaryTableViewCell.swift
//  Cake
//
//  Created by lola on 2/16/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import TTRangeSlider

let textEffectAuxiliaryTableViewCellReuse = "textEffectAuxiliaryTableViewCellReuse"

class CKTextEffectAuxiliaryTableViewCell: UITableViewCell {

    var delegate: CKTextEffectAuxiliaryTableViewCellDelegate?
    
    typealias KVOContext = UInt8
    var TextAuxiliaryObservationContext = KVOContext()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rangeSlider: TTRangeSlider!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var viewControllerDataSource: CKTextEffectViewController!
    
    func setDataFromDataSource(vc: CKTextEffectViewController) {
        self.viewControllerDataSource = vc
        self.rangeSlider.minValue = self.viewControllerDataSource.rangeSlider.minValue
        self.rangeSlider.maxValue = self.viewControllerDataSource.rangeSlider.maxValue
        self.rangeSlider.selectedMinimum = self.viewControllerDataSource.rangeSlider.selectedMinimum
        self.rangeSlider.selectedMaximum = self.viewControllerDataSource.rangeSlider.selectedMaximum
        
        self.titleLabel.text = "'\(self.viewControllerDataSource.textView.text)'"
        self.titleLabel.sizeToFit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let options = NSKeyValueObservingOptions([.New, .Old])
        self.rangeSlider.addObserver(self, forKeyPath: "selectedMinimum", options: options, context: &TextAuxiliaryObservationContext)
        self.rangeSlider.addObserver(self, forKeyPath: "selectedMaximum", options: options, context: &TextAuxiliaryObservationContext)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.viewControllerDataSource = nil
    }
    
    // MARK: - Key Value Observing
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard keyPath != nil else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        let old = Int(round(change!["old"] as! Double))
        let new = Int(round(change!["new"] as! Double))
        
        if old == new {
            return
        } else {
            switch (keyPath!, context) {
            case("selectedMinimum", &TextAuxiliaryObservationContext):
                self.delegate?.auxiliaryTableViewCell(self, didUpdateStartIndexTo: new - 1)
            case("selectedMaximum", &TextAuxiliaryObservationContext):
                self.delegate?.auxiliaryTableViewCell(self, didUpdateEndIndexTo: new - 1)
            case(_, &TextAuxiliaryObservationContext):
                assert(false, "unknown key path")
                
            default:
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            }
        }
    }
    
    // MARK: - Button Actions
    @IBAction func openButtonPressed(sender: AnyObject) {
        self.delegate?.didPressOpenButton(self)
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        self.delegate?.didPressDeleteButton(self)
    }
    
}

protocol CKTextEffectAuxiliaryTableViewCellDelegate {
    func didPressDeleteButton(cell: CKTextEffectAuxiliaryTableViewCell)
    func didPressOpenButton(cell: CKTextEffectAuxiliaryTableViewCell)
    func auxiliaryTableViewCell(auxiliaryCell: CKTextEffectAuxiliaryTableViewCell, didUpdateStartIndexTo startIndex: Int)
    func auxiliaryTableViewCell(auxiliaryCell: CKTextEffectAuxiliaryTableViewCell, didUpdateEndIndexTo endIndex: Int)
}
