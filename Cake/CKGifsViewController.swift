//
//  CKGifsViewController.swift
//  Cake
//
//  Created by lola on 2/13/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import RealmSwift
import FLAnimatedImage
import MessageUI

class CKGifsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    private var gifs: [GIF]!
    private var gifToDisplayURL: NSURL!
    private var gifToDisplayId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let viewNib = UINib(nibName: "CKGifCollectionViewCell", bundle: nil)
        self.collectionView.registerNib(viewNib, forCellWithReuseIdentifier: gifCellReuseIdentifier)
    
        layout.itemSize = CGSizeMake(kSCREEN_WIDTH / 2.0, kSCREEN_WIDTH / 2.0)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        loadGifs()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadGifs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    private func loadGifs() {
        
        var localGifs: [GIF]?
        
        let realm = try! Realm()
        if let user = realm.objects(User).first {
            let gifs = user.gifs.map { $0 }
            localGifs = gifs.reverse()
        }
        
        self.gifs = localGifs
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView!.reloadData()
        })
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if segue.identifier == "ShowDetail" {
            let detailVC = segue.destinationViewController as! CKGifsDetailViewController
            detailVC.gifURL = self.gifToDisplayURL
            detailVC.gifId = self.gifToDisplayId
        }
    }

    // MARK: - Actions
    @IBAction func moreButtonPressed(sender: AnyObject) {
        let moreMenu = UIAlertController(title: nil, message: "More", preferredStyle: .ActionSheet)
        
        let feedback = UIAlertAction(title: "Send Feedback", style: .Default, handler:
            {
                (alert: UIAlertAction!) -> Void in
                self.sendEmailButtonTapped()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler:
            {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
        })
        
        moreMenu.addAction(feedback)
        moreMenu.addAction(cancelAction)
        self.presentViewController(moreMenu, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
}

extension CKGifsViewController: MFMailComposeViewControllerDelegate {
    // MARK: - Feedback Methods
    func sendEmailButtonTapped() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["contact@cakegifs.com"])
        mailComposerVC.setSubject("Feedback")
        mailComposerVC.setMessageBody("Hello Cake,\n\t", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CKGifsViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard self.gifs != nil else {
            return 0
        }
        return self.gifs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(gifCellReuseIdentifier, forIndexPath: indexPath) as! CKGifCollectionViewCell
        let index: Int = indexPath.row
        let gif: GIF = self.gifs[index] as GIF
        let gifURL: NSURL!
        
        let gifName = gif.id + ".gif"
        gifURL = kSHARED_GIF_DIRECTORY!.URLByAppendingPathComponent(gifName)
        
        let animatedImage = FLAnimatedImage(GIFData: NSData(contentsOfURL: gifURL))
        cell.animatedImageView.animatedImage = animatedImage
        return cell
    }
}

extension CKGifsViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let gif: GIF = self.gifs[indexPath.row] as GIF
        let gifFileName = gif.id + ".gif"
        let gifURL = kSHARED_GIF_DIRECTORY!.URLByAppendingPathComponent(gifFileName)
        
        self.gifToDisplayId = gif.id
        self.gifToDisplayURL = gifURL
        self.performSegueWithIdentifier("ShowDetail", sender: self)
        
//        let gifData = NSData(contentsOfURL: gifURL)!
//        UIPasteboard.generalPasteboard().setData(gifData, forPasteboardType: "com.compuserve.gif")
        
//        print("COPIED: Collection View: ", collectionView.tag, "Index: ", indexPath.row)
        
//        let index: Int = indexPath.row
//        let gif: GIF = self.gifs[index] as GIF
//        self.gifToDisplayId = gif.id

    }
}

