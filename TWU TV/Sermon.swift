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
    
    var publishDate:String?
    {
        return dict?["publishDate"] as? String
    }
    
    var partNumber:String!
    {
        return dict?["part"] as? String
    }
    
    var partString:String?
    {
        get {
            if let numberOfSermons = series?.sermons?.count { // , let index = series?.sermons?.index(of: self)
                return "Part\u{00a0}\(partNumber!)\u{00a0}of\u{00a0}\(numberOfSermons)"
            }
            
            return "Part\u{00a0}\(partNumber!)"
        }
    }
    
    var text:String?
    {
        return dict?["description"] as? String
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
            guard let audioURL = Globals.shared.audioURL else {
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
            return id
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

        self.dict = dict?["program"] as? [String:Any]

//        switch Constants.JSON.URL {
//        case Constants.JSON.URLS.SERIES_JSON:
//            self.dict = dict?["program"] as? [String:Any]
//            break
//            
//        default:
//            self.dict = dict
//            break
//        }
    }
    
    override var description : String
    {
        //This requires that date, service, title, and speaker fields all be non-nil
        
        var sermonString = "Sermon:"
        
        if let title = series?.title {
            sermonString = "\(sermonString) \(title)"
        }
 
        if let partNumber = partNumber {
            sermonString = "\(sermonString) Part:\(partNumber)"
        }

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
                    value = Globals.shared.sermonSettings?[sermonID]?[key]
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
                
                if (Globals.shared.sermonSettings == nil) {
                    Globals.shared.sermonSettings = [String:[String:String]]()
                }
                
                if (Globals.shared.sermonSettings?[sermonID] == nil) {
                    Globals.shared.sermonSettings?[sermonID] = [String:String]()
                }
                
                if (Globals.shared.sermonSettings?[sermonID]?[key] != newValue) {
                    Globals.shared.sermonSettings?[sermonID]?[key] = newValue
                    
                    // For a high volume of activity this can be very expensive.
                    Globals.shared.saveSettingsBackground()
                }
            }
        }
    }
    
    lazy var settings:Settings? = {
        return Settings(sermon:self)
    }()
}
