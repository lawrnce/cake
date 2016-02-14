//
//  CKEditViewController.swift
//  Cake
//
//  Created by lola on 2/4/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import FLAnimatedImage

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

class CKEditViewController: UIViewController {

    @IBOutlet weak var animatedImageView: FLAnimatedImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var duration: Double!
    var framesPerSecond: Int!
    var gifURL: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotifications()
        
        self.saveButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setAnimatedImage:"), name: GIF_FINALIZED, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func setAnimatedImage(notification: NSNotification) {
        self.gifURL = notification.object as! NSURL
        let animatedImage = FLAnimatedImage(animatedGIFData: NSData(contentsOfURL: gifURL))
        self.animatedImageView.animatedImage = animatedImage
        self.animatedImageView.startAnimating()
        
        self.saveButton.enabled = true
        
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

    @IBAction func saveButtonPressed(sender: AnyObject) {
        
//        let backend = BackendManager()
//        backend.saveGif(self.gifURL, withDuration: self.duration, withFPS: self.framesPerSecond) { (task) -> AnyObject? in
//            NSNotificationCenter.defaultCenter().postNotificationName(SAVED_GIF, object: nil)
//            self.dismissViewControllerAnimated(true, completion: { () -> Void in
//                
//            })
//            
//            return nil
//        }
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
