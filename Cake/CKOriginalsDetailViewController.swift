//
//  CKOriginalsDetailViewController.swift
//  Cake
//
//  Created by lola on 3/2/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import FLAnimatedImage
import RealmSwift

class CKOriginalsDetailViewController: UIViewController {

    @IBOutlet weak var animatedImageView: FLAnimatedImageView!
    @IBOutlet weak var animatedImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mashUpsLabel: UILabel!
    @IBOutlet weak var mashUpsCollectionView: UICollectionView!
    @IBOutlet weak var mashUpsLayout: UICollectionViewFlowLayout!
    
    var gifURL: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimatedImageView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        layoutAnimatedImageView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Init Subviews
    private func setupAnimatedImageView() {
        let animatedImage = FLAnimatedImage(GIFData: NSData(contentsOfURL: gifURL))
        self.animatedImageView.animatedImage = animatedImage
    }

    // MARK: - Layout
    private func layoutAnimatedImageView() {
        animatedImageViewHeightConstraint.constant = kSCREEN_WIDTH
        self.view.layoutIfNeeded()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
