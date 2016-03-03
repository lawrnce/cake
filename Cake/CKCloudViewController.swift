//
//  CKCloudViewController.swift
//  Cake
//
//  Created by lola on 3/2/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit

class CKCloudViewController: UIViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var buildButton: UIBarButtonItem!
    @IBOutlet weak var containerView: UIView!
    
    var viewControllersByIdentifier: Dictionary<String, UIViewController>!
    var oldViewController: UIViewController!
    var destinationViewController: UIViewController!
    var destinationIdentifier: String!
    
    private var buildNavigationController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllersByIdentifier = Dictionary()
        setupNotifications()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (self.childViewControllers.count < 1) {
            self.performSegueWithIdentifier("ShowOriginals", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notifications
    private func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showOriginalDetail:"), name: ShowOriginalDetail, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showMashUpDetail:"), name: ShowMashUpDetail, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowOriginalDetail" {
            let gifURL = sender as! NSURL
            let originalDetailVC = segue.destinationViewController as! CKOriginalsDetailViewController
            originalDetailVC.gifURL = gifURL
            return
        } else if segue.identifier == "ShowMashUpDetail" {
            let gifURL = sender as! NSURL
            let mashUpDetailVC = segue.destinationViewController as! CKMashUpDetailViewController
            mashUpDetailVC.gifURL = gifURL
            return
        }
        
        if !segue.isKindOfClass(CKTabBarSegue.self) {
            super.prepareForSegue(segue, sender: sender)
            return
        }
        self.oldViewController = self.destinationViewController
        if self.viewControllersByIdentifier[segue.identifier!] == nil {
            self.viewControllersByIdentifier[segue.identifier!] = segue.destinationViewController
        }
        self.destinationIdentifier = segue.identifier
        self.destinationViewController = self.viewControllersByIdentifier[self.destinationIdentifier]!
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if self.destinationIdentifier == identifier {
            return false
        }
        return true
    }
    
    func showOriginalDetail(notification: NSNotification) {
        let gifURL = notification.object as! NSURL
        performSegueWithIdentifier("ShowOriginalDetail", sender: gifURL)
    }
    
    func showMashUpDetail(notification: NSNotification) {
        let gifURL = notification.object as! NSURL
        performSegueWithIdentifier("ShowMashUpDetail", sender: gifURL)
    }
    
    // MARK: - Actions
    @IBAction func closeButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
        if self.segmentedControl.selectedSegmentIndex == 0 {
            performSegueWithIdentifier("ShowOriginals", sender: self)
        } else if self.segmentedControl.selectedSegmentIndex == 1 {
            performSegueWithIdentifier("ShowMashUps", sender: self)
        }
    }
    
    @IBAction func buildButtonPressed(sender: AnyObject) {
        if self.buildNavigationController == nil {
            let storyboard = UIStoryboard(name: "Cloud", bundle: nil)
            self.buildNavigationController = storyboard.instantiateViewControllerWithIdentifier("BuildNC") as! UINavigationController
        }
        presentViewController(self.buildNavigationController, animated: true) { () -> Void in
            
        }
    }
}
