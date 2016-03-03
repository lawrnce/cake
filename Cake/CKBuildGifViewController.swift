//
//  CKBuildGifViewController.swift
//  Cake
//
//  Created by lola on 3/2/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit

class CKBuildGifViewController: UIViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    @IBOutlet weak var gifsCollectionView: UICollectionView!
    @IBOutlet weak var gifsCollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var gifsLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var dashedBorderView: CKDashedBorder!
    @IBOutlet weak var framesCollectionView: UICollectionView!
    @IBOutlet weak var framesLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var expandButton: UIBarButtonItem!
    @IBOutlet weak var framesCountLabel: NSLayoutConstraint!
    @IBOutlet weak var playButton: UIBarButtonItem!
    
    private var isExpanded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGifsCollectionView()
        setupFramesCollectionView()
        setupFramesCountLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Init Subviews
    private func setupGifsCollectionView() {
        gifsCollectionHeightConstraint.constant = kGIFS_COLLECTION_VIEW_HEIGHT
        self.view.layoutIfNeeded()
    }

    private func setupFramesCollectionView() {
        
    }
    
    private func setupFramesCountLabel() {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Actions
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    @IBAction func expandButtonPressed(sender: AnyObject) {
        
        if self.isExpanded == false {
            gifsCollectionHeightConstraint.constant = 0.0
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                
                self.view.layoutIfNeeded()
            })

            
            self.isExpanded = true
        } else if self.isExpanded == true {
            gifsCollectionHeightConstraint.constant = kGIFS_COLLECTION_VIEW_HEIGHT

            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.navigationController?.setNavigationBarHidden(false, animated: true)

                
                self.view.layoutIfNeeded()
            })
            
            self.isExpanded = false
        }
    }
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        
    }
}
