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
    
    var mixpanel: Mixpanel!
    
    @IBOutlet weak var allowAccessView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    
    var keyboard: UIView!
    
    var heightConstraint:NSLayoutConstraint!
    
    private var gifs: [GIF]!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInterface()
        loadMixPanel()
    }
    
    // MARK: - Mix Panel
    private func loadMixPanel() {
        self.mixpanel = Mixpanel.sharedInstanceWithToken(MixpanelToken)
        self.mixpanel.track("Keyboard Opened")
    }
    
    // MARK: - Constraints
    func setUpHeightConstraint() {
        
        let customHeight: CGFloat!
        
        if self.view.frame.size.width < 420.0 {
            customHeight = UIScreen.mainScreen().bounds.height / 2.75
        } else {
            customHeight = UIScreen.mainScreen().bounds.height / 2
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
            
            view.addConstraint(heightConstraint)
        } else {
            heightConstraint.constant = customHeight
        }
    }
    
    // MARK: - Init Subviews
    private func loadInterface() {
        let cakeKeyboardNib = UINib(nibName: "CakeKeyboard", bundle: nil)
        self.keyboard = cakeKeyboardNib.instantiateWithOwner(self, options: nil)[0] as! UIView
        self.keyboard.frame = view.frame
        
        view.addSubview(self.keyboard)
        view.backgroundColor = self.keyboard.backgroundColor
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isOpenAccessGranted() {
            var config = Realm.Configuration()
            // Use the shared container
            config.path = kSHARED_CONTAINER?.URLByAppendingPathComponent("default.realm").path
            // Set this as the configuration used for the default Realm
            Realm.Configuration.defaultConfiguration = config
            
            
            
            self.layout.itemSize = CGSize(width: self.collectionView.frame.height, height: self.collectionView.frame.height)
            loadGifs()
            self.collectionView.hidden = false
            self.allowAccessView.hidden = true
        } else {
            // Show allow text
            self.collectionView.hidden = true
            self.allowAccessView.hidden = false
        }
        setUpHeightConstraint()
        
        self.view.layoutIfNeeded()
        self.keyboard.layoutIfNeeded()
        
        
    }
    
    private func isOpenAccessGranted() -> Bool {
        return UIPasteboard.generalPasteboard().isKindOfClass(UIPasteboard)
    }
    
    
    // MARK: - Orientation
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        if size.width < 420.0 {
            self.heightConstraint.constant = UIScreen.mainScreen().bounds.height / 2.75
            print("\nCONSTRAINT: ", UIScreen.mainScreen().bounds.height / 2.75 )
            self.view.updateConstraints()
            self.view.layoutSubviews()
//            self.collectionView.layoutSubviews()
//            self.collectionView.reloadData()
        } else {
            self.heightConstraint.constant = UIScreen.mainScreen().bounds.height / 2
            
            print("\nCONSTRAINT: ", UIScreen.mainScreen().bounds.height / 2 )
            
            self.view.updateConstraints()
            self.view.layoutSubviews()
//            self.collectionView.layoutSubviews()
//            self.collectionView.reloadData()
        }
        
        self.layout.itemSize = CGSize(width: self.collectionView.frame.height, height: self.collectionView.frame.height)
        
        print("SIZE: ", size)
        print("COLLECTION!!!!!: ", self.collectionView.frame)
        print("COLLECTION SIZEEEEEEE: ", self.layout.itemSize, "\n")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

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

//extension KeyboardViewController: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        return UIEdgeInsetsZero
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 0.0
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
//        return 0.0
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSizeZero
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSizeZero
//    }
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        
//        print("View Frame: ", self.view.frame)
//        print("Keyboard Frame: ", self.keyboard.frame)
//        print("Collection Frame: ", collectionView.frame)
//        print("Collection Content Size: ", collectionView.contentSize)
//        print("Bottom bar: ", self.bottomBarView.frame)
//
//        
//        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
//    }
//}


extension KeyboardViewController: UICollectionViewDelegate {
    
}