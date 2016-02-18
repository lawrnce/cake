//
//  CKBackendManager.swift
//  Cake
//
//  Created by lola on 2/16/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import RealmSwift
import Bolts


class CKBackendManager: NSObject {
    
    static let sharedInstance = CKBackendManager()
    
    override init() {
        super.init()
        setupDirectory()
        setupRealm()
    }
    
    // MARK: - Saving and Uploading
    // Saves gif to disk then uploads and updates cloud
    func saveGif(tmpGIFURL: NSURL, withDuration duration: Double, completionBlock: BFContinuationBlock) {
        self.saveToDisk(tmpGIFURL, withDuration: duration, withId: self.generateGifId()).continueWithBlock { (task) -> AnyObject? in
            if ((task.error) != nil) {
                print("The request failed. Error: ", task.error)
            }
            if ((task.exception) != nil) {
                print("The request failed. Exception: ", task.exception)
            }
            // Succesfully saved to disk
            if ((task.result) != nil) {
                let _gif = task.result as! ThreadableGIF
                // Update realm
                self.appendGifToRealm(_gif)
            }
            return nil
            }.continueWithBlock(completionBlock)
    }
    
    // Writes a tmp gif to shared directory
    private func saveToDisk(tmpGIFURL: NSURL, withDuration duration: Double, withId id: String) -> BFTask {
        print("Init saving \(id) to disk...")
        let data = NSData(contentsOfURL: tmpGIFURL)!
        
        let task = BFTaskCompletionSource()
        
        let gifFileName = id + ".gif"
        let fileURL = kSHARED_GIF_DIRECTORY!.URLByAppendingPathComponent(gifFileName)
        
        if data.writeToURL(fileURL, atomically: true) {
            // Successfully written to disk
            let _gif = ThreadableGIF(id: id,
                date: NSDate.ISOStringFromDate(NSDate()),
                duration: duration)
            task.setResult(_gif)
            self.clearTmpData(tmpGIFURL)
        } else {
            let error = NSError(domain: "Failed to write to disk", code: 1, userInfo: nil)
            task.setError(error)
        }
        return task.task
    }

    
    // MARK: - Deleting
    // Deletes gif
    func deleteGif(gif: GIF, completion: BFContinuationBlock) {
        // Unwrap gif to thread safe gif
        let _gif = ThreadableGIF(gif: gif)
        self.deleteGifFromDisk(_gif).continueWithSuccessBlock(completion)
    }
    // Removes gif from disk
    private func deleteGifFromDisk(_gif: ThreadableGIF) -> BFTask {
        let task = BFTaskCompletionSource()
        
        let gifName = _gif.id + ".gif"
        let gifURL = kSHARED_GIF_DIRECTORY?.URLByAppendingPathComponent(gifName)
        
        do {
            try NSFileManager.defaultManager().removeItemAtURL(gifURL!)
            self.removeGifFromRealm(_gif, task: task)
        } catch let error as NSError {
            task.setError(error)
            print(error.localizedDescription)
        }
        return task.task
    }
    
    // Creates a unique id for gif
    private func generateGifId() -> String {
        let uuid = NSUUID().UUIDString
        return uuid
    }
    
    // MARK: - Realm
    // Get Latest Gif{
    func getLatestGif() -> GIF? {
        let realm = try! Realm()
        if let user = realm.objects(User).first {
            if user.gifs.isEmpty {
                return nil
            } else {
                let gifs = user.gifs.map { $0 }
                return gifs.last
            }
        }
        return nil
    }
    
    // Get User Gifs
    func getUserGifs() -> [GIF]? {
        let realm = try! Realm()
        if let user = realm.objects(User).first {
            if user.gifs.isEmpty {
                return nil
            } else {
                let gifs = user.gifs.map { $0 }
                let gifsReversed = gifs.reverse() as [GIF]
                return gifsReversed
            }
        }
        return nil
    }
    // Setups Realm
    private func setupRealm() {
        // Realm should not be empty, but if it is check if user is logged in
        let realm = try! Realm()
        guard realm.objects(User).first != nil else {
            let user = User()
            // Write to realm
            try! realm.write({ () -> Void in
                realm.add(user)
            })
            return
        }
    }
    // Adds gif to local database
    private func appendGifToRealm(_gif: ThreadableGIF) {
        let realm = try! Realm()
        try! realm.write({ () -> Void in
            let user = realm.objects(User).first!
            user.gifs.append(_gif.asGIF())
            realm.add(user)
            print(user)
        })
    }
    // Removes gif data from realm
    private func removeGifFromRealm(_gif: ThreadableGIF, task: BFTaskCompletionSource) {
        let realm = try! Realm()
        try! realm.write({ () -> Void in
            let user = realm.objects(User).first!
            if let gif = try! Realm().objectForPrimaryKey(GIF.self, key: _gif.id) {
                if let index = user.gifs.indexOf(gif) {
                    user.gifs.removeAtIndex(index)
                    task.setResult("Success")
                    print("Successfully deleted: ", _gif.id)
                }
            }
        })
    }

    
    // MARK: - Directory
    // Creates the gifs directory
    private func setupDirectory() {
        if (NSFileManager.defaultManager().fileExistsAtPath(kSHARED_GIF_DIRECTORY!.path!) as Bool == false) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(kSHARED_GIF_DIRECTORY!.path!, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
    }
    // Clears temporary data
    private func clearTmpData(url: NSURL) {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(url)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
