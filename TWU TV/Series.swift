//
//  Series.swift
//  TWU
//
//  Created by Steve Leeke on 11/4/15.
//  Copyright © 2015 Steve Leeke. All rights reserved.
//

import Foundation
import UIKit

func == (lhs:Series,rhs:Series) -> Bool
{
    return (lhs.name == rhs.name) // && (lhs.id == rhs.id)
}

func != (lhs:Series,rhs:Series) -> Bool
{
    return (lhs.name != rhs.name) // || (lhs.id != rhs.id)
}

class Settings
{
    weak var series:Series?
    
    init(series:Series?) {
        if (series == nil) {
            print("nil series in Settings init!")
        }
        self.series = series
    }
    
    subscript(key:String) -> String? {
        get {
            var value:String?
            if let name = self.series?.name {
                value = Globals.shared.seriesSettings?[name]?[key]
            }
            return value
        }
        set {
            guard (newValue != nil) else {
                print("newValue == nil in Settings!")
                return
            }
            
            guard let series = series else {
                print("series == nil in Settings!")
                return
            }
            
            guard let name = series.name else {
                print("series!.name == nil in Settings!")
                return
            }
            
            if (Globals.shared.seriesSettings == nil) {
                Globals.shared.seriesSettings = [String:[String:String]]()
            }
            
            if (Globals.shared.seriesSettings?[name] == nil) {
                Globals.shared.seriesSettings?[name] = [String:String]()
            }
            
            Globals.shared.seriesSettings?[name]?[key] = newValue
            
            // For a high volume of activity this can be very expensive.
            Globals.shared.saveSettingsBackground()
        }
    }
}

class Series : Equatable, CustomStringConvertible
{
    var dict:[String:Any]?
    
    init(seriesDict:[String:Any]?)
    {
        dict = seriesDict

        if let programs = dict?["programs"] as? [[String:Any]] {
            for program in programs {
                let sermon = Sermon(series: self,dict:program) // ,id:startingIndex+i
                if sermons == nil {
                    sermons = [sermon]
                } else {
                    sermons?.append(sermon)
                }
            }
        }

//        switch Constants.JSON.URL {
//        case Constants.JSON.URLS.MEDIALIST_PHP:
//            fallthrough
//
//        case Constants.JSON.URLS.MEDIALIST_JSON:
//            guard show > 0 else {
//                break
//            }
//
//            for i in 0..<show {
//                let sermon = Sermon(series: self, dict: ["part":"\(i+1)","mediaCode":"twu\(String(format: Constants.FILENAME_FORMAT, startingIndex+i))"])
//                if sermons == nil {
//                    sermons = [sermon]
//                } else {
//                    sermons?.append(sermon)
//                }
//            }
//            break
//
//        case Constants.JSON.URLS.SERIES_JSON:
//            if let programs = dict?["programs"] as? [[String:Any]] {
//                for program in programs {
//                    let sermon = Sermon(series: self,dict:program) // ,id:startingIndex+i
//                    if sermons == nil {
//                        sermons = [sermon]
//                    } else {
//                        sermons?.append(sermon)
//                    }
//                }
//            }
//            break
//
//        default:
//            break
//        }
    }
    
//    var id:Int!
//    {
//        get {
//            guard Constants.JSON.URL == Constants.JSON.URLS.MEDIALIST_PHP else {
//                return nil
//            }
//
//            guard let seriesID = seriesID else {
//                return nil
//            }
//
//            if let num = Int(seriesID) {
//                return num
//            } else {
//                return nil
//            }
//        }
//    }

    var seriesID:String!
    {
        get {
            return name
//            switch Constants.JSON.URL {
//            case Constants.JSON.URLS.MEDIALIST_PHP:
//                return dict?[Constants.FIELDS.ID] as? String
//
//            case Constants.JSON.URLS.MEDIALIST_JSON:
//                fallthrough
//
//            case Constants.JSON.URLS.SERIES_JSON:
//                return name
//
//            default:
//                return nil
//            }
        }
    }
    
    var url:URL?
    {
        get {
            return URL(string: Constants.URL.BASE.CRAFT_WEB + name)
//            switch Constants.JSON.URL {
//            case Constants.JSON.URLS.MEDIALIST_PHP:
//                if let id = id {
//                    return URL(string: Constants.URL.BASE.PHP_WEB + "\(id)")
//                } else {
//                    return nil
//                }
//
//            case Constants.JSON.URLS.MEDIALIST_JSON:
//                fallthrough
//
//            case Constants.JSON.URLS.SERIES_JSON:
//                return URL(string: Constants.URL.BASE.CRAFT_WEB + name)
//
//            default:
//                return nil
//            }
        }
    }
    
    var name:String!
    {
        get {
            return dict?[Constants.FIELDS.NAME] as? String
        }
    }
    
    var title:String?
    {
        get {
            return dict?[Constants.FIELDS.TITLE] as? String
        }
    }
    
    var scripture:String?
    {
        get {
            return dict?[Constants.FIELDS.SCRIPTURE] as? String
        }
    }
    
    var text:String?
    {
        get {
            return dict?[Constants.FIELDS.DESCRIPTION] as? String
//            switch Constants.JSON.URL {
//            case Constants.JSON.URLS.MEDIALIST_PHP:
//                return dict?[Constants.FIELDS.TEXT] as? String
//
//            case Constants.JSON.URLS.MEDIALIST_JSON:
//                return dict?[Constants.FIELDS.TEXT] as? String
//
//            case Constants.JSON.URLS.SERIES_JSON:
//                return dict?[Constants.FIELDS.DESCRIPTION] as? String
//
//            default:
//                return nil
//            }
        }
    }
    
//    var startingIndex:Int
//    {
//        get {
//            switch Constants.JSON.URL {
//            case Constants.JSON.URLS.MEDIALIST_PHP:
//                if let startingIndex = dict?[Constants.FIELDS.STARTING_INDEX] as? String {
//                    if let startingIndex = Int(startingIndex) {
//                        return startingIndex
//                    }
//                }
//                return -1
//
//            case Constants.JSON.URLS.MEDIALIST_JSON:
//                if let startingIndex = dict?[Constants.FIELDS.STARTING_INDEX] as? Int {
//                    return startingIndex
//                }
//                return -1
//
//            case Constants.JSON.URLS.SERIES_JSON:
//                return -1
//
//            default:
//                return -1
//            }
//        }
//    }
    
    var programs:[[String:String]]?
    {
//        guard Constants.JSON.URL == Constants.JSON.URLS.SERIES_JSON else {
//            return nil
//        }
//
        return dict?["programs"] as? [[String:String]]
    }
    
    var featuredStartDate:String?
    {
        get {
            return dict?[Constants.FIELDS.FEATURED_START_DATE] as? String
//            switch Constants.JSON.URL {
//            case Constants.JSON.URLS.MEDIALIST_PHP:
//                return nil
//
//            case Constants.JSON.URLS.MEDIALIST_JSON:
//                fallthrough
//
//            case Constants.JSON.URLS.SERIES_JSON:
//                return dict?[Constants.FIELDS.FEATURED_START_DATE] as? String
//
//            default:
//                return nil
//            }
        }
    }
    
//    var show:Int
//    {
//        get {
//            switch Constants.JSON.URL {
//            case Constants.JSON.URLS.MEDIALIST_PHP:
//                if let show = dict?[Constants.FIELDS.SHOW] as? String { // , let num = Int(show)
//                    return Int(show)!
//                } else {
//                    return numberOfSermons
//                }
//
//            case Constants.JSON.URLS.MEDIALIST_JSON:
//                if let show = dict?[Constants.FIELDS.SHOW] as? Int { // , let num = Int(show)
//                    return show
//                } else {
//                    return numberOfSermons
//                }
//
//            case Constants.JSON.URLS.SERIES_JSON:
//                return sermons?.count ?? -1
//
//            default:
//                return -1
//            }
//        }
//    }
    
//    var numberOfSermons:Int
//    {
//        get {
//            switch Constants.JSON.URL {
//            case Constants.JSON.URLS.MEDIALIST_PHP:
//                if let numberOfSermons = dict?[Constants.FIELDS.NUMBER_OF_SERMONS] as? String { // , let num = Int(numberOfSermons)
//                    return Int(numberOfSermons)!
//                } else {
//                    return -1
//                }
//
//            case Constants.JSON.URLS.MEDIALIST_JSON:
//                if let numberOfSermons = dict?[Constants.FIELDS.NUMBER_OF_SERMONS] as? Int { // , let num = Int(numberOfSermons)
//                    return numberOfSermons
//                } else {
//                    return -1
//                }
//
//            case Constants.JSON.URLS.SERIES_JSON:
//                return sermons?.count ?? -1
//
//            default:
//                return -1
//            }
//        }
//    }
    
    var titleSort:String?
    {
        get {
            return title?.withoutPrefixes.lowercased()
        }
    }

    var coverArtURL : URL?
    {
        get {
//            guard Constants.JSON.URL != Constants.JSON.URLS.MEDIALIST_PHP else {
//                if let name = name {
//                    return URL(string:"\(Constants.URL.BASE.PHP_IMAGE)\(Constants.COVER_ART_PREAMBLE)\(name)\(Constants.COVER_ART_POSTAMBLE)\(Constants.FILE_EXTENSION.JPEG)")
//                }
//
//                return nil
//            }
            
            guard let imageURL = Globals.shared.imageURL else {
                return nil
            }
            
            guard let imageName = name else {
                return nil
            }
            
            guard let squareSuffix = Globals.shared.squareSuffix else {
                return nil
            }
            
            let coverArtURL = imageURL + imageName + squareSuffix // + Constants.FILE_EXTENSION.JPEG
            
            return coverArtURL.url
        }
    }
    
//    func coverArt(block:((UIImage?)->()))
//    {
//        coverArtURL?.image(block:block)
//    }
    
    lazy var coverArt:FetchImage? = { [weak self] in
        return FetchImage(url: coverArtURL)
    }()
    
    var book:String?
    {
        get {
            guard let scripture = scripture else {
                return nil
            }
            
            if (dict?[Constants.FIELDS.BOOK] == nil) {
                if (scripture == Constants.Selected_Scriptures) {
                    dict?[Constants.FIELDS.BOOK] = Constants.Selected_Scriptures
                } else {
                    if (dict?[Constants.FIELDS.BOOK] == nil) {
                        for bookTitle in Constants.TESTAMENT.OLD {
                            if scripture.endIndex >= bookTitle.endIndex, String(scripture[..<bookTitle.endIndex]) == bookTitle {
                                    dict?[Constants.FIELDS.BOOK] = bookTitle
                                    break
                            }
                        }
                    }
                    if (dict?[Constants.FIELDS.BOOK] == nil) {
                        for bookTitle in Constants.TESTAMENT.NEW {
                            if scripture.endIndex >= bookTitle.endIndex, String(scripture[..<bookTitle.endIndex]) == bookTitle {
                                    dict?[Constants.FIELDS.BOOK] = bookTitle
                                    break
                            }
                        }
                    }
                }
            }
            
            return dict?[Constants.FIELDS.BOOK] as? String
        }
    }

    var sermons:[Sermon]?
    {
        didSet {
            guard let sermons = sermons else {
                return
            }
            
            for sermon in sermons {
                if index == nil {
                    index = [String:Sermon]()
                }
                index?[sermon.id] = sermon
            }
        }
    }
    
    var index:[String:Sermon]?

    lazy var settings:Settings? = { [weak self] in
        return Settings(series:self)
    }()

    var sermonSelected:Sermon?
    {
        get {
            if let sermonID = settings?[Constants.SETTINGS.SELECTED.SERMON] {
                return sermons?.filter({ (sermon) -> Bool in
                    return sermon.id == sermonID
                }).first // [num - startingIndex]
            }
            
            return nil
        }

        set {
            guard let newValue = newValue else {
                print("newValue == nil")
                return
            }
            
            guard let sermonID = newValue.sermonID else {
                print("sermonID == nil")
                return
            }
            
            settings?[Constants.SETTINGS.SELECTED.SERMON] = sermonID
        }
    }

    var description : String
    {
        //This requires that date, service, title, and speaker fields all be non-nil
        
        var seriesString = "Series: "
        
        if let title = title, !title.isEmpty {
            seriesString = "\(seriesString ) \(title)"
        }
        
        if let scripture = scripture, !scripture.isEmpty {
            seriesString = "\(seriesString ) \(scripture)"
        }
        
        if let name = name, !name.isEmpty {
            seriesString = "\(seriesString)\n\(name)"
        }

//        seriesString = "\(seriesString) \(startingIndex)"

        if let numberOfSermons = sermons?.count {
            seriesString = "\(seriesString) \(numberOfSermons)"
        }

        if let text = text, !text.isEmpty {
            seriesString = "\(seriesString)\n\(text)"
        }
        
        return seriesString
    }
}

