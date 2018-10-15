//
//  extensions.swift
//  TWU TV
//
//  Created by Steve Leeke on 10/13/18.
//  Copyright © 2018 Countryside Bible Church. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    func setTitleTextAttributes(_ attributes:[NSAttributedStringKey:UIFont])
    {
        setTitleTextAttributes(attributes, for: UIControlState.normal)
        setTitleTextAttributes(attributes, for: UIControlState.disabled)
        setTitleTextAttributes(attributes, for: UIControlState.selected)
        setTitleTextAttributes(attributes, for: UIControlState.highlighted)
        setTitleTextAttributes(attributes, for: UIControlState.focused)
    }
}

extension UISegmentedControl {
    func setTitleTextAttributes(_ attributes:[String:UIFont])
    {
        setTitleTextAttributes(attributes, for: UIControlState.normal)
        setTitleTextAttributes(attributes, for: UIControlState.disabled)
        setTitleTextAttributes(attributes, for: UIControlState.selected)
        setTitleTextAttributes(attributes, for: UIControlState.highlighted)
        setTitleTextAttributes(attributes, for: UIControlState.focused)
    }
}

extension UIButton {
    func setTitle(_ string:String?)
    {
        setTitle(string, for: UIControlState.normal)
        setTitle(string, for: UIControlState.disabled)
        setTitle(string, for: UIControlState.selected)
        setTitle(string, for: UIControlState.highlighted)
        setTitle(string, for: UIControlState.focused)
    }
}

extension Thread {
    static func onMainThread(block:(()->(Void))?)
    {
        if Thread.isMainThread {
            block?()
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
                block?()
            })
        }
    }
}

extension String
{
    var url : URL?
    {
        get {
            return URL(string: self)
        }
    }
}

fileprivate var queue = DispatchQueue(label: UUID().uuidString)

extension URL
{
    var fileSystemURL : URL?
    {
        return cachesURL()?.appendingPathComponent(self.lastPathComponent)
    }
    
    var downloaded : Bool
    {
        get {
            if let fileSystemURL = fileSystemURL {
                return FileManager.default.fileExists(atPath: fileSystemURL.path)
            } else {
                return false
            }
        }
    }
    
    var data : Data?
    {
        get {
            return try? Data(contentsOf: self)
        }
    }
    
    func delete()
    {
        guard let fileSystemURL = fileSystemURL else {
            return
        }
        
        // Check if file exists and if so, delete it.
        if (FileManager.default.fileExists(atPath: fileSystemURL.path)){
            do {
                try FileManager.default.removeItem(at: fileSystemURL)
            } catch let error as NSError {
                print("failed to delete download: \(error.localizedDescription)")
            }
        }
    }
    
    func image(block:((UIImage)->()))
    {
        if let image = image {
            block(image)
        }
    }
    
    var image : UIImage?
    {
        get {
            guard let imageURL = fileSystemURL else {
                return nil
            }
            
            if imageURL.downloaded, let image = UIImage(contentsOfFile: imageURL.path) {
                return image
            } else {
                guard let data = try? Data(contentsOf: self) else {
                    return nil
                }
                
                guard let image = UIImage(data: data) else {
                    return nil
                }
                
                DispatchQueue.global(qos: .background).async {
                    queue.sync {
                        guard !imageURL.downloaded else {
                            return
                        }
                        
                        do {
                            try UIImageJPEGRepresentation(image, 1.0)?.write(to: imageURL, options: [.atomic])
                            print("Image \(self.lastPathComponent) saved to file system")
                        } catch let error as NSError {
                            NSLog(error.localizedDescription)
                            print("Image \(self.lastPathComponent) not saved to file system")
                        }
                    }
                }

                return image
            }
        }
    }
}

extension Date
{
    
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "MM/dd/yyyy"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let d = dateStringFormatter.date(from: dateString) {
            self = Date(timeInterval:0, since:d)
        } else {
            self = Date()
        }
    }
    
    func isNewerThanDate(_ dateToCompare : Date) -> Bool
    {
        //Declare Variables
        var isNewer = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending
        {
            isNewer = true
        }
        
        //Return Result
        return isNewer
    }
    
    
    func isOlderThanDate(_ dateToCompare : Date) -> Bool
    {
        //Declare Variables
        var isOlder = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending
        {
            isOlder = true
        }
        
        //Return Result
        return isOlder
    }
    
    func addDays(_ daysToAdd : Int) -> Date
    {
        let secondsInDays : TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    
    func addHours(_ hoursToAdd : Int) -> Date
    {
        let secondsInHours : TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

