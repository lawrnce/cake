//
//  CKColorPickerViewController.swift
//  Cake
//
//  Created by lola on 2/19/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import Color_Picker_for_iOS

class CKColorPickerViewController: UIViewController {

    @IBOutlet weak var colorPickerView: HRColorPickerView!
    @IBOutlet weak var selectColorButton: UIButton!
    
    var delegate: CKColorPickerViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSelectColorButton()
        self.colorPickerView.color = UIColor.whiteColor()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup subivews
    private func setupSelectColorButton() {
        self.selectColorButton.layer.cornerRadius = 4.0
        self.selectColorButton.clipsToBounds = true
    }
    

    
    // MARK: - Button Actions
    @IBAction func selectColorButtonPressed(sender: AnyObject) {
        
        delegate?.updateColor(self.colorPickerView.color)
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
}

protocol CKColorPickerViewDelegate {
    func updateColor(color: UIColor)
}
