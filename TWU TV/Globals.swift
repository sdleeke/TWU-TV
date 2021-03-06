//
//  Globals.swift
//  TWU
//
//  Created by Steve Leeke on 11/4/15.
//  Copyright © 2015 Steve Leeke. All rights reserved.
//

import Foundation
import MediaPlayer

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

enum Showing {
    case all
    case filtered
}

var globals:Globals!

class Globals : NSObject
{
    func freeMemory()
    {
        // Free memory in classes
        Thread.onMainThread {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.FREE_MEMORY), object: nil)
        }
        
        URLCache.shared.removeAllCachedResponses()
    }

    var popoverNavCon: UINavigationController?

    let reachability = Reachability()!

    var sorting:String? = Constants.Sorting.Newest_to_Oldest {
        willSet {
            
        }
        didSet {
            guard sorting != oldValue else {
                return
            }

            activeSeries = sortSeries(activeSeries,sorting: sorting)
            
            let defaults = UserDefaults.standard
            if (sorting != nil) {
                defaults.set(sorting,forKey: Constants.SORTING)
            } else {
                defaults.removeObject(forKey: Constants.SORTING)
            }
            defaults.synchronize()
        }
    }
    
    var filter:String? {
        willSet {
            
        }
        didSet {
            guard filter != oldValue else {
                return
            }
            
            if (filter != nil) {
                showing = .filtered
                filteredSeries = series?.filter({ (series:Series) -> Bool in
                    return series.book == filter
                })
            } else {
                showing = .all
                filteredSeries = nil
            }
            
            updateSearchResults()
            
            activeSeries = sortSeries(activeSeries,sorting: sorting)
            
            let defaults = UserDefaults.standard
            if (filter != nil) {
                defaults.set(filter,forKey: Constants.FILTER)
            } else {
                defaults.removeObject(forKey: Constants.FILTER)
            }
            defaults.synchronize()
        }
    }
    
    var isLoading:Bool = false
    
    var seriesSettings:[String:[String:String]]?
    var sermonSettings:[String:[String:String]]?

    var mediaPlayer = MediaPlayer()
    
    var gotoNowPlaying:Bool = false
    
    var searchButtonClicked = false

    var searchActive:Bool = false {
        willSet {
            
        }
        didSet {
            guard !searchActive else {
                return
            }
            
            searchText = nil
            activeSeries = sortSeries(activeSeries,sorting: sorting)
        }
    }
    
    var searchValid:Bool {
        get {
            return searchActive && (searchText != nil) && (searchText != Constants.EMPTY_STRING)
        }
    }
    
    var searchSeries:[Series]?
    
    var searchText:String?
    {
        didSet {
            guard searchText != oldValue else {
                return
            }
            
            updateSearchResults()
        }
    }

    var showingAbout:Bool = false
    
    var seriesSelected:Series? {
        get {
            var seriesSelected:Series?
            
            let defaults = UserDefaults.standard
            if let seriesSelectedStr = defaults.string(forKey: Constants.SETTINGS.SELECTED.SERIES) {
                if let seriesSelectedID = Int(seriesSelectedStr) {
                    seriesSelected = index?[seriesSelectedID]
                }
            }
            defaults.synchronize()
            
            return seriesSelected
        }
    }
    
    var filteredSeries:[Series]?
    
    var series:[Series]? {
        willSet {
            
        }
        didSet {
            if let series = series {
                index = [Int:Series]()
                for sermonSeries in series {
                    if let id = sermonSeries.id, index?[id] == nil {
                        index?[id] = sermonSeries
                    } else {
                        print("DUPLICATE SERIES ID: \(sermonSeries)")
                    }
                }
            }
            if (filter != nil) {
                showing = .filtered
                filteredSeries = series?.filter({ (series:Series) -> Bool in
                    return series.book == filter
                })
            }
            updateSearchResults()
        }
    }
    
    var index:[Int:Series]?
    
    var showing:Showing = .all

    var seriesToSearch:[Series]? {
        get {
            switch showing {
            case .all:
                return series
                
            case .filtered:
                return filteredSeries
            }
        }
    }
    
    var activeSeries:[Series]? {
        get {
            if searchActive {
                return searchSeries
            } else {
                return seriesToSearch
            }
        }
        set {
            if searchActive {
                searchSeries = newValue
            } else {
                switch showing {
                case .all:
                    series = newValue
                    break
                case .filtered:
                    filteredSeries = newValue
                    break
                }
            }
        }
    }

    func updateSearchResults()
    {
        guard searchActive else {
            searchSeries = seriesToSearch
            return
        }

        searchSeries = seriesToSearch?.filter({ (series:Series) -> Bool in
            guard let searchText = searchText else {
                return false
            }
            
            var seriesResult = false
            
            if let string = series.title  {
                seriesResult = seriesResult || ((string.range(of: searchText, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)) != nil)
            }
            
            if let string = series.scripture {
                seriesResult = seriesResult || ((string.range(of: searchText, options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)) != nil)
            }
            
            return seriesResult
        })
        
        // Filter will return an empty array and we don't want that.
        
        if searchSeries?.count == 0 {
            searchSeries = nil
        }
    }
    
    func saveSettingsBackground()
    {
        print("saveSermonSettingsBackground")
        DispatchQueue.global(qos: .background).async { () -> Void in
            self.saveSettings()
        }
    }
    
    func saveSettings()
    {
        print("saveSermonSettings")
        let defaults = UserDefaults.standard

        defaults.set(seriesSettings,forKey: Constants.SETTINGS.KEY.SERIES)
        defaults.set(sermonSettings,forKey: Constants.SETTINGS.KEY.SERMON)
        defaults.synchronize()
    }
    
    func loadSettings()
    {
        let defaults = UserDefaults.standard
        
        if let settingsDictionary = defaults.dictionary(forKey: Constants.SETTINGS.KEY.SERIES) {
            seriesSettings = settingsDictionary as? [String:[String:String]]
        }
        
        if let settingsDictionary = defaults.dictionary(forKey: Constants.SETTINGS.KEY.SERMON) {
            sermonSettings = settingsDictionary as? [String:[String:String]]
        }
        
        if let sorting = defaults.string(forKey: Constants.SORTING) {
            self.sorting = sorting
        }
        
        if let filter = defaults.string(forKey: Constants.FILTER) {
            if (filter == Constants.All) {
                self.filter = nil
                self.showing = .all
            } else {
                self.filter = filter
                self.showing = .filtered
            }
        }
        
        if let seriesPlayingIDStr = defaults.string(forKey: Constants.SETTINGS.PLAYING.SERIES) {
            if let seriesPlayingID = Int(seriesPlayingIDStr) {
                if let index = series?.index(where: { (series) -> Bool in
                    return series.id == seriesPlayingID
                }) {
                    let seriesPlaying = series?[index]
                    
                    if let sermonPlayingIndexStr = defaults.string(forKey: Constants.SETTINGS.PLAYING.SERMON_INDEX) {
                        if let sermonPlayingIndex = Int(sermonPlayingIndexStr) {
                            if let show = seriesPlaying?.show, (sermonPlayingIndex > (show - 1)) {
                                mediaPlayer.playing = nil
                            } else {
                                mediaPlayer.playing = seriesPlaying?.sermons?[sermonPlayingIndex]
                            }
                        }
                    }
                } else {
                    defaults.removeObject(forKey: Constants.SETTINGS.PLAYING.SERIES)
                }
            }
        }
    }
    
    var autoAdvance:Bool = false
    
    func addAccessoryEvents()
    {
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget (handler: { (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            print("RemoteControlPlay")
            self.mediaPlayer.play()
            return MPRemoteCommandHandlerStatus.success
        })
        
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget (handler: { (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            print("RemoteControlPause")
            self.mediaPlayer.pause()
            return MPRemoteCommandHandlerStatus.success
        })
        
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget (handler: { (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            print("RemoteControlTogglePlayPause")
            if self.mediaPlayer.isPaused {
                self.mediaPlayer.play()
            } else {
                self.mediaPlayer.pause()
            }
            return MPRemoteCommandHandlerStatus.success
        })
        
        MPRemoteCommandCenter.shared().stopCommand.isEnabled = true
        MPRemoteCommandCenter.shared().stopCommand.addTarget (handler: { (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            print("RemoteControlStop")
            self.mediaPlayer.pause()
            return MPRemoteCommandHandlerStatus.success
        })
        
        //    MPRemoteCommandCenter.sharedCommandCenter().seekBackwardCommand.enabled = true
        //    MPRemoteCommandCenter.sharedCommandCenter().seekBackwardCommand.addTargetWithHandler { (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
        ////        self.mediaPlayer.player?.beginSeekingBackward()
        //        return MPRemoteCommandHandlerStatus.Success
        //    }
        //
        //    MPRemoteCommandCenter.sharedCommandCenter().seekForwardCommand.enabled = true
        //    MPRemoteCommandCenter.sharedCommandCenter().seekForwardCommand.addTargetWithHandler { (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
        ////        self.mediaPlayer.player?.beginSeekingForward()
        //        return MPRemoteCommandHandlerStatus.Success
        //    }
        
        MPRemoteCommandCenter.shared().skipBackwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipBackwardCommand.addTarget (handler: { (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            if let currentTime = self.mediaPlayer.currentTime {
                self.mediaPlayer.seek(to: currentTime.seconds - Constants.INTERVAL.SKIP_TIME)
                return MPRemoteCommandHandlerStatus.success
            } else {
                return MPRemoteCommandHandlerStatus.commandFailed
            }
        })
        
        MPRemoteCommandCenter.shared().skipForwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipForwardCommand.addTarget (handler: { (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
            if let currentTime = self.mediaPlayer.currentTime {
                self.mediaPlayer.seek(to: currentTime.seconds + Constants.INTERVAL.SKIP_TIME)
                return MPRemoteCommandHandlerStatus.success
            } else {
                return MPRemoteCommandHandlerStatus.commandFailed
            }
        })
        
        if #available(iOS 9.1, *) {
            MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = true
            MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget (handler: { (event:MPRemoteCommandEvent!) -> MPRemoteCommandHandlerStatus in
                NSLog("MPChangePlaybackPositionCommand")
                self.mediaPlayer.seek(to: (event as! MPChangePlaybackPositionCommandEvent).positionTime)
                return MPRemoteCommandHandlerStatus.success
            })
        } else {
            // Fallback on earlier versions
        }
        
        MPRemoteCommandCenter.shared().seekForwardCommand.isEnabled = false
        MPRemoteCommandCenter.shared().seekBackwardCommand.isEnabled = false
        
        MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled = false
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = false
        
        MPRemoteCommandCenter.shared().changePlaybackRateCommand.isEnabled = false
        
        MPRemoteCommandCenter.shared().ratingCommand.isEnabled = false
        MPRemoteCommandCenter.shared().likeCommand.isEnabled = false
        MPRemoteCommandCenter.shared().dislikeCommand.isEnabled = false
        MPRemoteCommandCenter.shared().bookmarkCommand.isEnabled = false
    }
}


