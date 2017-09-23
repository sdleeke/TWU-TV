//
//  Sermon.swift
//  TWU
//
//  Created by Steve Leeke on 11/4/15.
//  Copyright © 2015 Steve Leeke. All rights reserved.
//

import Foundation
import UIKit

var debug = false

class Sermon : NSObject {
    var series:Series?
    
    var id:Int
    
    var title:String?
    {
        get {
            if let numberOfSermons = series?.numberOfSermons, let index = series?.sermons?.index(of: self) {
                return "Part\u{00a0}\(index+1)\u{00a0}of\u{00a0}\(numberOfSermons)"
            }
            
            return series?.title
        }
    }
    
    var atEnd:Bool {
        get {
            return settings![Constants.SETTINGS.AT_END] == "YES"
        }
        
        set {
            settings?[Constants.SETTINGS.AT_END] = newValue ? "YES" : "NO"
        }
    }
    
    var audio:String? {
        get {
            return String(format: Constants.FILENAME_FORMAT, id)
        }
    }

    var audioURL:URL? {
        get {
            if let audio = audio {
                return URL(string: Constants.URL.BASE.AUDIO + audio)
            } else {
                return nil
            }
        }
    }
    
    var playingURL:URL? {
        get {
            return audioURL
        }
    }

    var sermonID:String? {
        get {
            if let seriesID = series?.id {
                return "\(seriesID)\(Constants.COLON)\(id)"
            } else {
                print("sermonID: series nil")
                return nil
            }
        }
    }

    var hasCurrentTime : Bool
    {
        get {
            guard let currentTime = currentTime else {
                return false
            }
            
            return (Float(currentTime) != nil)
        }
    }
    
    // this supports settings values that are saved in defaults between sessions
    var currentTime:String? {
        get {
            if (settings?[Constants.CURRENT_TIME] == nil) {
                settings?[Constants.CURRENT_TIME] = Constants.ZERO
            }
            return settings?[Constants.CURRENT_TIME]
        }
        
        set {
            if (settings?[Constants.CURRENT_TIME] != newValue) {
                settings?[Constants.CURRENT_TIME] = newValue
            }
        }
    }
    
    init(series:Series,id:Int) {
        self.series = series
        self.id = id
    }
    
    var index:Int? {
        get {
            if let startingIndex = series?.startingIndex {
                return id - startingIndex
            } else {
                return nil
            }
        }
    }
    
    override var description : String
    {
        //This requires that date, service, title, and speaker fields all be non-nil
        
        var sermonString = "Sermon:"
        
        if let title = series?.title {
            sermonString = "\(sermonString) \(title)"
        }
        
        if let index = index {
            sermonString = "\(sermonString) Part:\(index+1)"
        }
        
        return sermonString
    }
    
    struct Settings {
        weak var sermon:Sermon?
        
        init(sermon:Sermon?) {
            if (sermon == nil) {
                print("nil sermon in Settings init!")
            }
            self.sermon = sermon
        }
        
        subscript(key:String) -> String? {
            get {
                var value:String?
                if let sermonID = sermon?.sermonID {
                    value = globals.sermonSettings?[sermonID]?[key]
                }
                return value
            }
            set {
                guard (newValue != nil) else {
                    print("newValue == nil in Settings!")
                    return
                }
                
                guard let sermon = sermon else {
                    print("sermon == nil in Settings!")
                    return
                }
                
                guard let sermonID = sermon.sermonID else {
                    print("sermon!.sermonID == nil in Settings!")
                    return
                }
                
                if (globals.sermonSettings == nil) {
                    globals.sermonSettings = [String:[String:String]]()
                }
                
                if (globals.sermonSettings?[sermonID] == nil) {
                    globals.sermonSettings?[sermonID] = [String:String]()
                }
                
                //                            print("\(globals.sermonSettings!)")
                //                            print("\(sermon!)")
                //                            print("\(newValue!)")
                
                if (globals.sermonSettings?[sermonID]?[key] != newValue) {
                    globals.sermonSettings?[sermonID]?[key] = newValue
                    
                    // For a high volume of activity this can be very expensive.
                    globals.saveSettingsBackground()
                }
            }
        }
    }
    
    lazy var settings:Settings? = {
        return Settings(sermon:self)
    }()
}
