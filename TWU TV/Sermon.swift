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
    
    var dict:[String:Any]?
    
    var id:String!
    {
        return dict?["mediaCode"] as? String
    }
    
    var part:String!
    {
        return dict?["part"] as? String
    }
    
    var publishDate:String!
    {
        return dict?["publishDate"] as? String
    }
    
    var text:String?
    {
        return dict?["description"] as? String
    }
    
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
            return settings?[Constants.SETTINGS.AT_END] == "YES"
        }
        
        set {
            settings?[Constants.SETTINGS.AT_END] = newValue ? "YES" : "NO"
        }
    }
    
    var audio:String? {
        get {
            return id + Constants.FILE_EXTENSION.MP3 // String(format: Constants.FILENAME_FORMAT, id)
        }
    }

    var audioURL:URL? {
        get {
            guard let audioURL = globals.audioURL else {
                return nil
            }
            
            guard let audio = audio else {
                return nil
            }
            
            return URL(string: audioURL + audio)
            
            //            return URL(string: Constants.URL.BASE.AUDIO + audio)
        }
    }
    
    var audioFileSystemURL:URL? {
        get {
            guard let audio = audio else {
                return nil
            }
            
            return cachesURL()?.appendingPathComponent(audio)
        }
    }
    
    var playingURL:URL? {
        get {
            return audioURL
        }
    }

    var sermonID:String? {
        get {
            guard let series = series else {
                print("sermonID: series nil")
                return nil
            }
            
            return id // "\(series.id)\(Constants.COLON)\(id)"
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
    
    init(series:Series,dict:[String:Any]?) { // id:Int
        self.series = series
        
        switch Constants.JSON.URL {
        case Constants.JSON.URLS.SERIES_JSON:
            self.dict = dict?["program"] as? [String:Any]
            break
            
        default:
            self.dict = dict
            break
        }
        
//        self.id = id
    }
    
//    var index:Int? {
//        get {
//            if let startingIndex = series?.startingIndex {
//                return id - startingIndex
//            } else {
//                return nil
//            }
//        }
//    }
    
    override var description : String
    {
        //This requires that date, service, title, and speaker fields all be non-nil
        
        var sermonString = "Sermon:"
        
        if let title = series?.title {
            sermonString = "\(sermonString) \(title)"
        }
        
//        if let index = index {
//            sermonString = "\(sermonString) Part:\(index+1)"
//        }

        sermonString = "\(sermonString) Part:\(part!)"

        return sermonString
    }
    
    class Settings {
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
