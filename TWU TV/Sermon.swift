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
            return URL(string: Constants.URL.BASE.AUDIO + audio!)
        }
    }
    
    var playingURL:URL? {
        get {
            return audioURL
        }
    }

    var sermonID:String? {
        get {
            if (series == nil) {
                print("sermonID: series nil")
            }
            return "\(series!.id)\(Constants.COLON)\(id)"
        }
    }

    func hasCurrentTime() -> Bool
    {
        return (currentTime != nil) && (Float(currentTime!) != nil)
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
    
    var index:Int {
        get {
            return id - series!.startingIndex
        }
    }
    
    override var description : String {
        //This requires that date, service, title, and speaker fields all be non-nil
        
        var sermonString = "Sermon:"
        
        if (series != nil) {
            sermonString = "\(sermonString) \(series!.title ?? "Title")"
        }
        
        sermonString = "\(sermonString) Part:\(index+1)"
        
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
                value = globals.sermonSettings?[self.sermon!.sermonID!]?[key]
                return value
            }
            set {
                guard (newValue != nil) else {
                    print("newValue == nil in Settings!")
                    return
                }
                
                guard (sermon != nil) else {
                    print("sermon == nil in Settings!")
                    return
                }
                
                guard (sermon?.sermonID != nil) else {
                    print("sermon!.sermonID == nil in Settings!")
                    return
                }
                
                if (globals.sermonSettings == nil) {
                    globals.sermonSettings = [String:[String:String]]()
                }
                
                if (globals.sermonSettings?[sermon!.sermonID!] == nil) {
                    globals.sermonSettings?[sermon!.sermonID!] = [String:String]()
                }
                
                //                            print("\(globals.sermonSettings!)")
                //                            print("\(sermon!)")
                //                            print("\(newValue!)")
                
                if (globals.sermonSettings?[sermon!.sermonID!]?[key] != newValue) {
                    globals.sermonSettings?[sermon!.sermonID!]?[key] = newValue
                    
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
