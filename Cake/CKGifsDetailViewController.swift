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
import Mixpanel

class CKGifsDetailViewController: UIViewController {
    
    var mixpanel: Mixpanel!

    @IBOutlet weak var animatedImageView: FLAnimatedImageView!
    @IBOutlet weak var animatedImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var copiedImageView: UIImageView!
    
    var gifURL: NSURL!
    var gifId: String!
    
    private var copyButton: UIButton!
    private var actionButton: UIButton!
    private var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimatedImageView()
        setupCopyButton()
//        setupActionButton()
        setupDeleteButton()
        setupCopiedImageView()
        let data = NSData(contentsOfURL: gifURL)
        
        self.mixpanel = Mixpanel.sharedInstanceWithToken(MixpanelToken)
        
        print("\nImage in MB: ", Double((data?.length)!) / 1024.0 * 0.001)
        print("Size: ", self.animatedImageView.animatedImage.size)
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        layoutAnimatedImageView()
        layoutCopyButton()
//        layoutActionButton()
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
        self.copyButton = UIButton(frame: CGRect(x: 0, y: 0, width: kDetailButtonWidth, height: kDetailButtonWidth))
        self.copyButton.addTarget(self, action: Selector("copyButtonPressed:"), forControlEvents: .TouchUpInside)
        self.copyButton.setImage(UIImage(named: "CopyButtonNormal"), forState: .Normal)
    }
    
//    private func setupActionButton() {
//        self.actionButton = UIButton(frame: CGRect(x: 0, y: 0, width: kDetailButtonWidth, height: kDetailButtonWidth))
//        self.actionButton.addTarget(self, action: Selector("actionButtonPressed:"), forControlEvents: .TouchUpInside)
//        self.actionButton.setImage(UIImage(named: "ActionButtonNormal"), forState: .Normal)
//    }
    
    private func setupDeleteButton() {
        self.deleteButton = UIButton(frame: CGRect(x: 0, y: 0, width: kDetailButtonWidth, height: kDetailButtonWidth))
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
        self.copyButton.center.y = kDetailButtonCenterY
        self.view.addSubview(self.copyButton)
    }
    
//    private func layoutActionButton() {
//        self.actionButton.frame.origin.x = kActionButtonFrameOriginX
//        self.actionButton.center.y = kDetailButtonCenterY
//        self.view.addSubview(self.actionButton)
//    }
    
    private func layoutDeleteButton() {
        self.deleteButton.frame.origin.x = kDeleteButtonFrameOriginX
        self.deleteButton.center.y = kDetailButtonCenterY
        self.view.addSubview(self.deleteButton)
    }

    private func animateCopyImageView() {
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
    
    // MARK: - Button Actions
    func copyButtonPressed(sender: UIButton) {
        let gifData = NSData(contentsOfURL: gifURL)!
        UIPasteboard.generalPasteboard().setData(gifData, forPasteboardType: "com.compuserve.gif")
        animateCopyImageView()
        
        self.mixpanel.track("Gif Copied From App")
    }
    
//    func actionButtonPressed(sender: UIButton) {
//        
//        let gifData = NSData(contentsOfURL: gifURL)!
//        UIPasteboard.generalPasteboard().setData(gifData, forPasteboardType: "com.compuserve.gif")
//        let data = UIPasteboard.generalPasteboard().dataForPasteboardType("com.compuserve.gif")
//        
//        
//        
//        let activityViewController = UIActivityViewController(activityItems: [gifURL], applicationActivities: nil)
//
//        activityViewController.excludedActivityTypes =  [
//            UIActivityTypePrint,
//            UIActivityTypeAssignToContact,
//            UIActivityTypeAddToReadingList,
//            UIActivityTypePostToVimeo,
//            UIActivityTypePostToTencentWeibo
//        ]
//        
//        self.presentViewController(activityViewController,
//            animated: true,
//            completion: nil)
//        
//    }
    
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
