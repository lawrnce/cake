//
//  CKEditViewController.swift
//  Cake
//
//  Created by lola on 2/4/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
//import FLAnimatedImage

struct EditableGIF {
    var gifURL: NSURL!
    var duration: Double!
    var fps: Int!
    
    init(url: NSURL, duration: Double, fps: Int) {
        self.gifURL = url
        self.duration = duration
        self.fps = fps
    }
}

enum EditMode {
    case Preview
    case Edit
}

class CKEditViewController: UIViewController {
    
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var carousel: iCarousel!
    
    @IBOutlet weak var framesCollectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var frameSlider: UISlider!
    @IBOutlet weak var framesLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var addTextButton: UIButton!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewGifImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var state: EditMode = .Preview
    var duration: Double!
    var framesPerSecond: Int!
    var gifURL: NSURL!
    
    var rawFrames: [CGImage]!
    var frames: [UIImage] = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveButton.enabled = false
        setupGif()
        setupFramesCollectionView()
        setupFramesLabel()
        setupCarousel()
        setupAddTextButton()
        setupFramesSlider()
    }
    
    private func setupGif() {
        for frame in rawFrames {
            let image = UIImage(CGImage: frame)
            self.frames.append(image)
        }
        let gif = UIImage.animatedImageWithImages(self.frames, duration: NSTimeInterval(self.duration))
        self.previewGifImageView.image = gif
        self.previewGifImageView.startAnimating()
        self.framesCollectionView.reloadData()
    }

    private func setupFramesCollectionView() {
        let viewNib = UINib(nibName: "CKEditCollectionViewCell", bundle: nil)
        self.framesCollectionView.registerNib(viewNib, forCellWithReuseIdentifier: editCollectionCellIdentifier)
        self.framesCollectionView.dataSource = self
        self.framesCollectionView.delegate = self
        
        self.layout.itemSize = CGSize(width: kSCREEN_WIDTH, height: self.framesCollectionView.frame.height)
        self.layout.minimumInteritemSpacing = 0
        self.layout.minimumLineSpacing = 0
    }
    
    private func setupFramesLabel() {
        self.framesLabel.text = "1 of \(self.frames.count)"
    }
    
    private func setupFramesSlider() {
        self.frameSlider.minimumValue = 0.0
        self.frameSlider.maximumValue = 1.0
        self.frameSlider.value = 0.0
    }
    
    private func setupCarousel() {
        self.carousel.type = .CoverFlow
        self.carousel.bounces = false
        self.carousel.reloadData()
        self.carousel.scrollToItemAtIndex(0, animated: false)
    }
    
    private func setupAddTextButton() {
        self.addTextButton.layer.cornerRadius = 4.0
        self.addTextButton.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateState()
    }
    
    func updateState() {
        if self.state == .Preview {
            self.previewView.hidden = false
            self.editView.hidden = true
        } else if self.state == .Edit {
            self.previewView.hidden = true
            self.editView.hidden = false
        }
    }

    func setAnimatedImage(notification: NSNotification) {
        let imageSize: Int = NSData(contentsOfURL: gifURL)!.length
        print("size of image in MB: ", Float(imageSize) / 1024.0 / 1000.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func redoButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }

    // MARK: - Button Actions
    @IBAction func editButtonPressed(sender: AnyObject) {
        self.state = .Edit
        self.previewGifImageView.stopAnimating()
        updateState()
        setNeedsFocusUpdate()
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {

    }
    
    @IBAction func frameSliderValueChanged(sender: AnyObject) {
        let frameIndex = Int(self.frameSlider.value * Float(self.frames.count-1))
        if frameIndex != self.carousel.currentItemIndex {
            updateFramesLabel(frameIndex)
            self.carousel.scrollToItemAtIndex(frameIndex, animated: false)
        }
    }
    
    private func updateFramesLabel(index: Int) {
        self.framesLabel.text = "\(index + 1) of \(self.frames.count)"
    }
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        self.state = .Preview
        self.previewGifImageView.startAnimating()
        updateState()
        setNeedsFocusUpdate()
    }
    
    @IBAction func addTextButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowAddText", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowAddText" {
            let addTextVC = segue.destinationViewController as! CKAddTextViewController
            addTextVC.frames = self.frames
        }
    }

}

extension CKEditViewController: iCarouselDataSource, iCarouselDelegate {
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return self.frames.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var imageView: UIImageView
        
        if (view == nil) {
            imageView = UIImageView(frame: CGRectMake(0, 0, 240, 240))
            imageView.contentMode = .ScaleAspectFit
        } else {
            imageView = view as! UIImageView
        }
        
        imageView.image = self.frames[index]
        
        return imageView
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .Spacing)
        {
            return value * 1.1
        }
        return value
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        let index = carousel.currentItemIndex
        let value = Float(index) / Float(self.frames.count-1)
        self.frameSlider.value = Float(value)
        let frameIndex = Int(self.frameSlider.value * Float(self.frames.count-1))
        updateFramesLabel(frameIndex)
    }
    
//    func carouselDidEndScrollingAnimation(carousel: iCarousel) {
//        let index = carousel.currentItemIndex
//        let value = Float(index) / Float(self.frames.count)
//        self.frameSlider.value = Float(value)
//        frameSliderValueChanged(UISlider())
//    }
}


extension CKEditViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.frames.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(editCollectionCellIdentifier, forIndexPath: indexPath) as! CKEditCollectionViewCell
        let index: Int = indexPath.row
        let image = self.frames[index]
        cell.imageView.image = image
        return cell
    }
}

extension CKEditViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        print("Collection View: ", collectionView.tag, "Index: ", indexPath.row)
//        let index: Int = indexPath.row
//        let gif: GIF = self.gifs[index] as GIF
//        self.gifToDisplayId = gif.id
//        self.performSegueWithIdentifier("ShowDetail", sender: self)
    }
}

extension CKEditViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
}


