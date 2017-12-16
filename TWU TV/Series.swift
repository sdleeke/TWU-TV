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
    return (lhs.name == rhs.name) && (lhs.id == rhs.id)
}

func != (lhs:Series,rhs:Series) -> Bool
{
    return (lhs.name != rhs.name) || (lhs.id != rhs.id)
}

class Series : Equatable, CustomStringConvertible {
    var dict:[String:String]?
    
    init(seriesDict:[String:String]?)
    {
        guard let seriesDict = seriesDict else {
            return
        }

        dict = seriesDict

        guard let show = show else {
            return
        }
        
        guard let startingIndex = startingIndex else {
            return
        }
        
        for i in 0..<show {
            let sermon = Sermon(series: self,id:startingIndex+i)
            if sermons == nil {
                sermons = [sermon]
            } else {
                sermons?.append(sermon)
            }
        }
    }
    
    var id:Int? {
        get {
            if let seriesID = seriesID, let num = Int(seriesID) {
                return num
            } else {
                return nil
            }
        }
    }
    
    var seriesID:String? {
        get {
            return dict?[Constants.FIELDS.ID]        }
    }
    
    var url:URL? {
        get {
            if let id = id {
                return URL(string: Constants.URL.BASE.WEB + "\(id)")
            } else {
                return nil
            }
        }
    }
    
    var name:String? {
        get {
            return dict?[Constants.FIELDS.NAME]
        }
    }
    
    var title:String? {
        get {
            return dict?[Constants.FIELDS.TITLE]
        }
    }
    
    var scripture:String? {
        get {
            return dict?[Constants.FIELDS.SCRIPTURE]
        }
    }
    
    var text:String? {
        get {
            return dict?[Constants.FIELDS.TEXT]
        }
    }
    
    var startingIndex:Int? {
        get {
            if let startingIndex = dict?[Constants.FIELDS.STARTING_INDEX] {
                return Int(startingIndex)
            } else {
                return nil
            }
        }
    }
    
    var show:Int? {
        get {
            if let show = dict?[Constants.FIELDS.SHOW] {
                return Int(show)
            } else {
                return numberOfSermons
            }
        }
    }
    
    var numberOfSermons:Int? {
        get {
            if let numberOfSermons = dict?[Constants.FIELDS.NUMBER_OF_SERMONS] {
                return Int(numberOfSermons)
            } else {
                return nil
            }
        }
    }
    
    var titleSort:String? {
        get {
            if (dict?[Constants.FIELDS.TITLE+Constants.SORTING] == nil) {
                dict?[Constants.FIELDS.TITLE+Constants.SORTING] = stringWithoutPrefixes(title)?.lowercased()
            }
            
            return dict?[Constants.FIELDS.TITLE+Constants.SORTING]
        }
    }

    var coverArt:String?
    
    var book:String? {
        get {
            if (dict?[Constants.FIELDS.BOOK] == nil) {
                if (scripture == Constants.Selected_Scriptures) {
                    dict?[Constants.FIELDS.BOOK] = Constants.Selected_Scriptures
                } else {
                    if (dict?[Constants.FIELDS.BOOK] == nil) {
                        for bookTitle in Constants.TESTAMENT.OLD {
                            if (scripture?.endIndex >= bookTitle.endIndex) &&
                                (scripture?.substring(to: bookTitle.endIndex) == bookTitle) {
                                    dict?[Constants.FIELDS.BOOK] = bookTitle
                                    break
                            }
                        }
                    }
                    if (dict?[Constants.FIELDS.BOOK] == nil) {
                        for bookTitle in Constants.TESTAMENT.NEW {
                            if (scripture?.endIndex >= bookTitle.endIndex) &&
                                (scripture?.substring(to: bookTitle.endIndex) == bookTitle) {
                                    dict?[Constants.FIELDS.BOOK] = bookTitle
                                    break
                            }
                        }
                    }
                }
            }
            
            return dict?[Constants.FIELDS.BOOK]
        }
    }

    func fetchArt() -> UIImage?
    {
        guard let name = name else {
            return nil
        }
        
        let imageName = "\(Constants.COVER_ART_PREAMBLE)\(name)\(Constants.COVER_ART_POSTAMBLE)"
        
        // See if it is in the cloud, download it and store it in the file system.
        
        // Try to get it from the cloud
        let imageCloudURL = Constants.URL.BASE.IMAGE + imageName + Constants.FILE_EXTENSION.JPEG
        //                print("\(imageCloudURL)")
        
        guard let url = URL(string: imageCloudURL) else {
            return nil
        }

        do {
            let imageData = try Data(contentsOf: url)
            print("Image \(imageName) read from cloud")
            
            if let image = UIImage(data: imageData) {
                print("Image \(imageName) read from cloud and converted to image")
                
                DispatchQueue.global(qos: .background).async { () -> Void in
                    do {
                        if let imageURL = cachesURL()?.appendingPathComponent(imageName + Constants.FILE_EXTENSION.JPEG) {
                            try UIImageJPEGRepresentation(image, 1.0)?.write(to: imageURL, options: [.atomic])
                            print("Image \(imageName) saved to file system")
                        }
                    } catch let error as NSError {
                        NSLog(error.localizedDescription)
                        print("Image \(imageName) not saved to file system")
                    }
                }
                
                return image
            } else {
                print("Image \(imageName) read from cloud but not converted to image")
            }
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            print("Image \(imageName) not read from cloud")
        }
        
        print("Image \(imageName) not available")
        
        return nil
    }
    
    func loadArt() -> UIImage?
    {
        guard let name = name else {
            return nil
        }
        
        let imageName = "\(Constants.COVER_ART_PREAMBLE)\(name)\(Constants.COVER_ART_POSTAMBLE)"
        
        // If it isn't in the bundle, see if it is in the file system.
        
        if let image = UIImage(named:imageName) {
//            print("Image \(imageName) in bundle")
            return image
        } else {
//            print("Image \(imageName) not in bundle")
            
            // Check to see if it is in the file system.
            if let imageURL = cachesURL()?.appendingPathComponent(imageName + Constants.FILE_EXTENSION.JPEG) {
                if let image = UIImage(contentsOfFile: imageURL.path) {
//                    print("Image \(imageName) in file system")
                    return image
                } else {
//                    print("Image \(imageName) not in file system")
                }
            }
        }
        
//        print("Image \(imageName) not available")
 
        return nil
    }
    
    var sermons:[Sermon]?
    
    class Settings {
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
                if let seriesID = self.series?.seriesID {
                    value = globals.seriesSettings?[seriesID]?[key]
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
                
                guard let seriesID = series.seriesID else {
                    print("series!.seriesID == nil in Settings!")
                    return
                }
                
                if (globals.seriesSettings == nil) {
                    globals.seriesSettings = [String:[String:String]]()
                }
                
                if (globals.seriesSettings?[seriesID] == nil) {
                    globals.seriesSettings?[seriesID] = [String:String]()
                }
                
                globals.seriesSettings?[seriesID]?[key] = newValue
                
                // For a high volume of activity this can be very expensive.
                globals.saveSettingsBackground()
            }
        }
    }

    lazy var settings:Settings? = {
        return Settings(series:self)
    }()

    var sermonSelected:Sermon? {
        get {
            if  let sermonID = settings?[Constants.SETTINGS.SELECTED.SERMON],
                let range = sermonID.range(of: Constants.COLON),
                let num = Int(sermonID.substring(from: range.upperBound)),
                let startingIndex = startingIndex {
                return sermons?[num - startingIndex]
            } else {
                return nil
            }
        }
        
        set {
            if (newValue != nil) {
                settings?[Constants.SETTINGS.SELECTED.SERMON] = newValue?.sermonID
            } else {
                print("newValue == nil")
            }
        }
    }

    var description : String {
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
        
        if let id = id {
            seriesString = "\(seriesString)\n\(id)"
        }
        
        if let startingIndex = startingIndex {
            seriesString = "\(seriesString) \(startingIndex)"
        }
    
        if let numberOfSermons = numberOfSermons {
            seriesString = "\(seriesString) \(numberOfSermons)"
        }

        if let text = text, !text.isEmpty {
            seriesString = "\(seriesString)\n\(text)"
        }
        
        return seriesString
    }
}

