//
//  Models.swift
//  Cake
//
//  Created by lola on 2/16/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    let gifs = List<GIF>()
}

class GIF: Object, Equatable, Hashable {
    dynamic var id = ""
    dynamic var date = ""
    dynamic var duration = 0.0
    
    override class func primaryKey() -> String {
        return "id"
    }
    
    override var hashValue: Int {
        get {
            return id.hashValue
        }
    }
    
    override static func ignoredProperties() -> [String] {
        return ["hashValue"]
    }
}

// MARK: - Equatable
func ==(lhs: GIF, rhs: GIF) -> Bool {
    return lhs.id == rhs.id &&
        lhs.date == rhs.date &&
        lhs.duration == rhs.duration
}

// Realm objects cannot be passed away from the thread from which it was created
// ThreadSafeGif stores that data to be passed to another thread
class ThreadableGIF: NSObject {
    var id: String
    var date: String
    var duration: Double
    
    init(id: String, date: String, duration: Double){
        self.id = id
        self.date = date
        self.duration = duration
    }
    
    init(gif: GIF) {
        self.id = gif.id
        self.date = gif.date
        self.duration = gif.duration
    }
    
    func asGIF() -> GIF {
        let gif = GIF()
        gif.id = self.id
        gif.date = self.date
        gif.duration = self.duration
        
        return gif
    }
}