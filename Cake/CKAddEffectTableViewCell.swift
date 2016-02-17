//
//  CKAddEffectTableViewCell.swift
//  Cake
//
//  Created by lola on 2/16/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit

let addEffectTableViewCellReuse = "addEffectTableViewCellReuse"

class CKAddEffectTableViewCell: UITableViewCell {
    
    var delegate: CKAddEffectTableViewCellDelegate?
    
    @IBOutlet weak var addEffectButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.addEffectButton.layer.cornerRadius = 4.0
        self.addEffectButton.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addEffectButtonPressed(sender: AnyObject) {
        self.delegate?.didPressAddEffectButton(self)
    }
}

protocol CKAddEffectTableViewCellDelegate {
    func didPressAddEffectButton(cell: CKAddEffectTableViewCell)
}
