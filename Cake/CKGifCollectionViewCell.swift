

//
//  CKGifCollectionViewCell.swift
//  Cake
//
//  Created by lola on 2/5/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import FLAnimatedImage

let gifCellReuseIdentifier = "GifCellReuse"

class CKGifCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var animatedImageView: FLAnimatedImageView!
    @IBOutlet weak var copiedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.copiedLabel.hidden = true
        self.copiedLabel.alpha = 0.0
        
        self.copiedLabel.layer.cornerRadius = 4.0
        self.copiedLabel.clipsToBounds = true
    }

    override func prepareForReuse() {
        self.animatedImageView.animatedImage = nil
        self.backgroundColor = UIColor.clearColor()
        self.copiedLabel.hidden = true
        self.copiedLabel.alpha = 0.0
    }
    
    func animateCopyLabel() {
        self.copiedLabel.adjustsFontSizeToFitWidth = true
        self.copiedLabel.alpha = 0.0
        self.copiedLabel.hidden = false
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.copiedLabel.alpha = 0.7
            }) { (done) -> Void in
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    
                    self.copiedLabel.alpha = 0.0
                    
                    }, completion: { (done) -> Void in
                        self.copiedLabel.hidden = true
                })
                
        }
        
    }
}
