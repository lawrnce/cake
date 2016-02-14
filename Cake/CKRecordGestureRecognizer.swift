//
//  CKRecordGestureRecognizer.swift
//  Cake
//
//  Created by musashi on 12/25/15.
//  Copyright © 2015 Cake. All rights reserved.
//

import UIKit
import Foundation
import UIKit.UIGestureRecognizerSubclass

class CKRecordGestureRecognizer: UIGestureRecognizer {

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        if (self.enabled) {
            self.state = .Began
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        if (self.enabled) {
            self.state = .Ended
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        if (self.enabled) {
            self.state = .Ended
        }
    }
}
