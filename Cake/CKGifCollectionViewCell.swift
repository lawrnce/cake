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
    
//    var loadingGif: FLAnimatedImage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let dataAsset = NSDataAsset(name: "Loading")
//        self.loadingGif = FLAnimatedImage(GIFData: dataAsset?.data)
//        self.animatedImageView.animatedImage = self.loadingGif
    }

    override func prepareForReuse() {
        self.animatedImageView.animatedImage = nil
//        self.animatedImageView.animatedImage = self.loadingGif
        self.backgroundColor = UIColor.clearColor()
    }
}
