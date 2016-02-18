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

class KeyboardViewController: UIInputViewController {
    
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    var keyboard: UIView!
    
    private var gifs: [GIF]!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isOpenAccessGranted() {
            var config = Realm.Configuration()
            
            // Use the shared container
            config.path = kSHARED_CONTAINER?.URLByAppendingPathComponent("default.realm").path
            // Set this as the configuration used for the default Realm
            Realm.Configuration.defaultConfiguration = config
            loadInterface()
            setupCollectionView()
            loadGifs()
            
        } else {
            
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadGifs()

    }
    
    private func isOpenAccessGranted() -> Bool {
        return UIPasteboard.generalPasteboard().isKindOfClass(UIPasteboard)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func loadInterface() {
        let cakeKeyboardNib = UINib(nibName: "CakeKeyboard", bundle: nil)
        self.keyboard = cakeKeyboardNib.instantiateWithOwner(self, options: nil)[0] as! UIView
        self.keyboard.frame = view.frame
        view.addSubview(self.keyboard)
        view.backgroundColor = self.keyboard.backgroundColor
        
        nextKeyboardButton.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
    }
    
    private func setupCollectionView() {
        self.layout.sectionInset = UIEdgeInsetsZero
        
        let viewNib = UINib(nibName: "CKGifCollectionViewCell", bundle: nil)
        collectionView.registerNib(viewNib, forCellWithReuseIdentifier: gifCellReuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.layout.minimumInteritemSpacing = 0.0
        self.layout.minimumLineSpacing = 0.0
        
        self.keyboard.addSubview(self.collectionView)
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let gif: GIF = self.gifs[indexPath.row] as GIF
        let gifName = gif.id + ".gif"
        let gifURL = kSHARED_GIF_DIRECTORY!.URLByAppendingPathComponent(gifName)
        let gifData = NSData(contentsOfURL: gifURL)!
        
        UIPasteboard.generalPasteboard().setData(gifData, forPasteboardType: "com.compuserve.gif")
    }
    
}

extension KeyboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: collectionView.contentSize.height, height: collectionView.contentSize.height)
    }
}


extension KeyboardViewController: UICollectionViewDelegate {
    
}