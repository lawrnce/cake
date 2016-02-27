//
//  CKGifsDetailViewController.swift
//  Cake
//
//  Created by lola on 2/17/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import FLAnimatedImage
import RealmSwift

class CKGifsDetailViewController: UIViewController {

    @IBOutlet weak var animatedImageView: FLAnimatedImageView!
    @IBOutlet weak var animatedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var copiedImageView: UIImageView!
    
    var gifURL: NSURL!
    var gifId: String!
    
    private var copyButton: UIButton!
    private var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimatedImageView()
        setupCopyButton()
        setupDeleteButton()
        setupCopiedImageView()
        let data = NSData(contentsOfURL: gifURL)
        print("\nImage in MB: ", Double((data?.length)!) / 1024.0 * 0.001)
        print("Size: ", self.animatedImageView.animatedImage.size)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        layoutAnimatedImageView()
        layoutCopyButton()
        layoutDeleteButton()
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
    
    private func setupCopyButton() {
        self.copyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 88, height: 88))
        self.copyButton.addTarget(self, action: Selector("copyButtonPressed:"), forControlEvents: .TouchUpInside)
        self.copyButton.setImage(UIImage(named: "CopyButtonNormal"), forState: .Normal)
    }
    
    private func setupDeleteButton() {
        self.deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 88, height: 88))
        self.deleteButton.addTarget(self, action: Selector("deleteButtonPressed:"), forControlEvents: .TouchUpInside)
        self.deleteButton.setImage(UIImage(named: "DeleteButtonNormal"), forState: .Normal)
    }
    
    private func setupCopiedImageView() {
        self.copiedImageView.hidden = true
        self.copiedImageView.alpha = 0.0
    }
    
    // MARK: - Layout
    private func layoutAnimatedImageView() {
        animatedImageViewHeightConstraint.constant = kSCREEN_WIDTH
        self.view.layoutIfNeeded()
    }
    
    private func layoutCopyButton() {
        self.copyButton.frame.origin.x = kCopyButtonFrameOriginX
        self.copyButton.center.y = (kSCREEN_WIDTH + kSCREEN_HEIGHT - 64.0) / 2.0
        self.view.addSubview(self.copyButton)
    }
    
    private func layoutDeleteButton() {
        self.deleteButton.frame.origin.x = kDeleteButtonFrameOriginX
        self.deleteButton.center.y = (kSCREEN_WIDTH + kSCREEN_HEIGHT - 64.0) / 2.0
        self.view.addSubview(self.deleteButton)
    }

    private func animateCopyImageView() {
        self.copiedImageView.alpha = 0.0
        self.copiedImageView.hidden = false
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.copiedImageView.alpha = 0.7
            }) { (done) -> Void in
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.copiedImageView.alpha = 0.0
                    
                    }, completion: { (done) -> Void in
                        self.copiedImageView.hidden = true
                })
                
        }
    }
    
    // MARK: - Button Actions
    func copyButtonPressed(sender: UIButton) {
        let gifData = NSData(contentsOfURL: gifURL)!
        UIPasteboard.generalPasteboard().setData(gifData, forPasteboardType: "com.compuserve.gif")
        animateCopyImageView()
    }
    
    func deleteButtonPressed(sender: UIButton) {
        let alert = UIAlertController(title: "Garbage", message: "Permanately delete this gif?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            print("Cancelled Delete")
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
            print("Deleted")
            
            let realm = try! Realm()
            if let user = realm.objects(User).first {
                for gif in user.gifs {
                    if gif.id == self.gifId {
                        
                        CKBackendManager.sharedInstance.deleteGif(gif, completion: { (taks) -> AnyObject? in
                            
                            self.navigationController?.popViewControllerAnimated(true)
                            return nil
                        })
                    }
                }
            }
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
}
