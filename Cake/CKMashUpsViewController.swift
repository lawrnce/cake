//
//  CKMashUpsViewController.swift
//  Cake
//
//  Created by lola on 3/2/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import RealmSwift
import FLAnimatedImage

class CKMashUpsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    private var gifs: [GIF]!
    private var gifToDisplayURL: NSURL!
    private var gifToDisplayId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let viewNib = UINib(nibName: "CKGifCollectionViewCell", bundle: nil)
        self.collectionView.registerNib(viewNib, forCellWithReuseIdentifier: gifCellReuseIdentifier)
        
        layout.itemSize = CGSizeMake(kSCREEN_WIDTH / 2.0, kSCREEN_WIDTH / 2.0)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        loadGifs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadGifs() {
        
        var localGifs: [GIF]?
        
        let realm = try! Realm()
        if let user = realm.objects(User).first {
            localGifs = user.gifs.map { $0 }
//            localGifs = gifs.reverse()
        }
        
        self.gifs = localGifs
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.collectionView!.reloadData()
        })
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

extension CKMashUpsViewController: UICollectionViewDataSource {
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

extension CKMashUpsViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let gif: GIF = self.gifs[indexPath.row] as GIF
        let gifFileName = gif.id + ".gif"
        let gifURL = kSHARED_GIF_DIRECTORY!.URLByAppendingPathComponent(gifFileName)
        
        self.gifToDisplayId = gif.id
        self.gifToDisplayURL = gifURL

        NSNotificationCenter.defaultCenter().postNotificationName(ShowMashUpDetail, object: gifURL)
        
    }
}