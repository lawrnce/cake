

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
    
    @IBOutlet weak var copiedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.copiedImageView.hidden = true
        self.copiedImageView.alpha = 0.0
    }

    override func prepareForReuse() {
        self.animatedImageView.animatedImage = nil
        self.backgroundColor = UIColor.clearColor()
        self.copiedImageView.hidden = true
        self.copiedImageView.alpha = 0.0
    }
    
    func animateCopiedImageView() {
        self.copiedImageView.alpha = 0.0
        self.copiedImageView.hidden = false
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.copiedImageView.alpha = 1.0
            }) { (done) -> Void in
                
                let seconds = 0.5
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        self.copiedImageView.alpha = 0.0
                        
                        }, completion: { (done) -> Void in
                            self.copiedImageView.hidden = true
                    })
                    
                })

        }
        
    }
}
