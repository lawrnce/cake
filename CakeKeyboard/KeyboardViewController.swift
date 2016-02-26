//
//  KeyboardViewController.swift
//  CakeKeyboard
//
//  Created by lola on 2/13/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import RealmSwift
import FLAnimatedImage
import Mixpanel

let kCollectionViewHeightPotrait = CGFloat(182.0)
let kCollectionViewHeightLandscape = CGFloat(118.0)

class KeyboardViewController: UIInputViewController {
    
    @IBOutlet weak var allowAccessView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    var mixpanel: Mixpanel!
    var keyboard: UIView!
    var heightConstraint:NSLayoutConstraint!
    
    private var gifs: [GIF]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterface()
        loadMixPanel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isOpenAccessGranted() {
            var config = Realm.Configuration()
            // Use the shared container
            config.path = kSHARED_CONTAINER?.URLByAppendingPathComponent("default.realm").path
            // Set this as the configuration used for the default Realm
            Realm.Configuration.defaultConfiguration = config
            loadGifs()
            self.collectionView.hidden = false
            self.allowAccessView.hidden = true
        } else {
            // Show allow text
            self.collectionView.hidden = true
            self.allowAccessView.hidden = false
        }
        self.inputView?.layoutIfNeeded()
        self.keyboard.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        inputView?.addConstraint(heightConstraint)
    }
    
    // MARK: - Constraints
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
        // Add custom view sizing constraints here
        if (inputView?.frame.size.width == 0 ||
            inputView?.frame.size.height == 0) {
                return
        }
        setUpHeightConstraint()
    }
    
    func setUpHeightConstraint() {
        let customHeight: CGFloat!
        if self.inputView?.frame.size.width < 420.0 {
            print("Portrait")
            customHeight = UIScreen.mainScreen().bounds.height / 2.75
        } else {
            print("Landscape")
            customHeight = UIScreen.mainScreen().bounds.height / 2.0
        }
        if heightConstraint == nil {
            heightConstraint = NSLayoutConstraint(
                item: self.view,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1,
                constant: customHeight
            )
            heightConstraint.priority = UILayoutPriority(999)
        } else {
            heightConstraint.constant = customHeight
        }
        self.collectionView.reloadData()
    }
    
    // MARK: - Mix Panel
    private func loadMixPanel() {
        self.mixpanel = Mixpanel.sharedInstanceWithToken(MixpanelToken)
        self.mixpanel.track("Keyboard Opened")
    }

    // MARK: - Init Subviews
    private func loadInterface() {
        let cakeKeyboardNib = UINib(nibName: "CakeKeyboard", bundle: nil)
        self.keyboard = cakeKeyboardNib.instantiateWithOwner(self, options: nil)[0] as! UIView
        self.keyboard.frame = view.frame
        inputView?.addSubview(self.keyboard)
        nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
        setupCollectionView()
        setupBottomBarView()
    }
    
    private func setupBottomBarView() {
        self.bottomBarView.layer.shadowOpacity = 0.6
        self.bottomBarView.layer.shadowRadius = 1.0
        self.bottomBarView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.keyboard.addSubview(bottomBarView)
    }
    
    private func setupCollectionView() {
        let viewNib = UINib(nibName: "CKGifCollectionViewCell", bundle: nil)
        collectionView.registerNib(viewNib, forCellWithReuseIdentifier: gifCellReuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.keyboard.addSubview(self.collectionView)
    }
    
    // MARK: - State Methods
    private func isOpenAccessGranted() -> Bool {
        return UIPasteboard.generalPasteboard().isKindOfClass(UIPasteboard)
    }
    
    private func loadGifs() {
        var localGifs: [GIF]?
        let realm = try! Realm()
        if let user = realm.objects(User).first {
            let gifs = user.gifs.map { $0 }
            localGifs = gifs.reverse()
        }
        if self.gifs == nil || (self.gifs != nil && self.gifs != localGifs!)  {
            self.gifs = localGifs
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView!.reloadData()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(textInput: UITextInput?) {

    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        self.textDocumentProxy.deleteBackward()
    }
}

extension KeyboardViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard self.gifs != nil else {
            return 0
        }
        return self.gifs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Get cell to reuse
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(gifCellReuseIdentifier, forIndexPath: indexPath) as! CKGifCollectionViewCell
        // Cast indexPath as String for List<> key
        let index: Int = indexPath.row
        // Get gif for indexPath
        let gif: GIF = self.gifs[index] as GIF
        
        let gifName = gif.id + ".gif"
        let gifURL = kSHARED_GIF_DIRECTORY!.URLByAppendingPathComponent(gifName)
        let animatedImage = FLAnimatedImage(GIFData: NSData(contentsOfURL: gifURL))
        cell.animatedImageView.animatedImage = animatedImage
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if collectionView.dragging || collectionView.decelerating {
            return false
        } else {
            return true
        }
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        
//        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
//            let center = cell.center
//            let transform = CGAffineTransformMakeScale(0.8, 0.8)
//            UIView.animateWithDuration(0.1, animations: { () -> Void in
//                cell.transform = transform
//                cell.center = center
//                }) { (done) -> Void in
//                    
//            }
//        }
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        
        

    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let gif: GIF = self.gifs[indexPath.row] as GIF
        let gifName = gif.id + ".gif"
        let gifURL = kSHARED_GIF_DIRECTORY!.URLByAppendingPathComponent(gifName)
        let gifData = NSData(contentsOfURL: gifURL)!
        
        UIPasteboard.generalPasteboard().setData(gifData, forPasteboardType: "com.compuserve.gif")
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CKGifCollectionViewCell
        cell.animateCopiedImageView()
        
        self.mixpanel.track("Gif Copied")
        
//        let center = cell.center
//        let transform = CGAffineTransformMakeScale(1.0, 1.0)
//        
//        UIView.animateWithDuration(0.1, animations: { () -> Void in
//                cell.transform = transform
//                cell.center = center
//                }) { (done) -> Void in
//                    cell.animateCopyLabel()
//        }
    }
    
}

extension KeyboardViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
}


extension KeyboardViewController: UICollectionViewDelegate {
    
}