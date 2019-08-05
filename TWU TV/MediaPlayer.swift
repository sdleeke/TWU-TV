//
//  MediaPlayer.swift
//  TWU TV
//
//  Created by Steve Leeke on 6/16/17.
//  Copyright © 2017 Countryside Bible Church. All rights reserved.
//

import Foundation
import MediaPlayer

enum PlayerState {
    case none
    
    case paused
    case playing
    case stopped
    
    case seekingForward
    case seekingBackward
}

class PlayerStateTime {
    var sermon:Sermon? {
        willSet {
            
        }
        didSet {
            startTime = sermon?.currentTime
        }
    }
    
    var state:PlayerState = .none {
        willSet {
            
        }
        didSet {
            if (state != oldValue) {
                dateEntered = Date()
            }
        }
    }
    
    var startTime:String?
    
    var dateEntered:Date?
    var timeElapsed:TimeInterval?
    {
        get {
            if let dateEntered = dateEntered {
                return Date().timeIntervalSince(dateEntered)
            } else {
                return nil
            }
        }
    }
    
    init()
    {
        dateEntered = Date()
    }
    
    convenience init(sermon:Sermon?,state:PlayerState)
    {
        self.init()
        self.sermon = sermon
        self.state = state
        self.startTime = sermon?.currentTime
    }
    
    func log()
    {
        var stateName:String?
        
        switch state {
        case .none:
            stateName = "none"
            break
            
        case .paused:
            stateName = "paused"
            break
            
        case .playing:
            stateName = "playing"
            break
            
        case .seekingForward:
            stateName = "seekingForward"
            break
            
        case .seekingBackward:
            stateName = "seekingBackward"
            break
            
        case .stopped:
            stateName = "stopped"
            break
        }
        
        if let stateName = stateName {
            print(stateName)
        }
    }
}

class MediaPlayer : NSObject
{
    var playerTimerReturn:Any? = nil
    var progressTimerReturn:Any? = nil
    
    var observerActive = false
    var observedItem:AVPlayerItem?
    
    var playerObserverTimer:Timer?
    
    var url : URL? {
        get {
            return (player?.currentItem?.asset as? AVURLAsset)?.url
        }
    }
    
    var hiddenPlayer:AVPlayer?
    
    var player:AVPlayer? {
        get {
            return hiddenPlayer
        }
        
        set {
            if progressTimerReturn != nil {
                hiddenPlayer?.removeTimeObserver(progressTimerReturn!)
                progressTimerReturn = nil
            }
            
            if playerTimerReturn != nil {
                hiddenPlayer?.removeTimeObserver(playerTimerReturn!)
                playerTimerReturn = nil
            }
            
            self.hiddenPlayer = newValue
        }
    }
    
    private var stateTime : PlayerStateTime?
    
    func setupPlayingInfoCenter()
    {
        guard let title = playing?.series?.title else {
            return
        }

        guard let partString = playing?.partString else {
            return
        }
        
        guard let partNumber = playing?.partNumber else {
            return
        }
        
        var sermonInfo = [String:AnyObject]()
        
        sermonInfo[MPMediaItemPropertyTitle] = "\(title) \(partString)" as AnyObject
        
        sermonInfo[MPMediaItemPropertyArtist] = Constants.Tom_Pennington as AnyObject
        
        sermonInfo[MPMediaItemPropertyAlbumTitle] = title as AnyObject
        
        sermonInfo[MPMediaItemPropertyAlbumArtist] = Constants.Tom_Pennington as AnyObject

        playing?.series?.coverArt?.load(success: { (image:UIImage) in
            if #available(iOS 10.0, *) {
                sermonInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (CGSize) -> UIImage in
                    return image
                })
            } else {
                // Fallback on earlier versions
                sermonInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
            }
        }, failure: {
            
        })
        
        sermonInfo[MPMediaItemPropertyAlbumTrackNumber] = partNumber as AnyObject
        
        if let numberOfSermons = playing?.series?.sermons?.count {
            sermonInfo[MPMediaItemPropertyAlbumTrackCount] = numberOfSermons as AnyObject
        }
        
        if let duration = duration?.seconds {
            sermonInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: duration)
        }
        
        if let currentTime = currentTime?.seconds {
            sermonInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: currentTime)
        }
        
        if let rate = rate {
            sermonInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: rate)
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = sermonInfo
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        //        guard context == &GlobalPlayerContext else {
        //            super.observeValue(forKeyPath: keyPath,
        //                               of: object,
        //                               change: change,
        //                               context: context)
        //            return
        //        }
        
        if keyPath == #keyPath(AVPlayer.timeControlStatus) {
            if  let statusNumber = change?[.newKey] as? NSNumber,
                let status = AVPlayer.TimeControlStatus(rawValue: statusNumber.intValue) {
                switch status {
                case .waitingToPlayAtSpecifiedRate:
                    if let reason = player?.reasonForWaitingToPlay {
                        print("waitingToPlayAtSpecifiedRate: ",reason)
                    } else {
                        print("waitingToPlayAtSpecifiedRate: no reason")
                    }
                    break
                    
                case .paused:
                    if let state = state {
                        switch state {
                        case .none:
                            break
                            
                        case .paused:
                            break
                            
                        case .playing:
                            pause()
                            checkPlayToEnd()
                            break
                            
                        case .seekingBackward:
                            //                                pause()
                            break
                            
                        case .seekingForward:
                            //                                pause()
                            break
                            
                        case .stopped:
                            break
                        }
                    }
                    break
                    
                case .playing:
                    if let state = state {
                        switch state {
                        case .none:
                            break
                            
                        case .paused:
                            play()
                            break
                            
                        case .playing:
                            break
                            
                        case .seekingBackward:
                            //                                play()
                            break
                            
                        case .seekingForward:
                            //                                play()
                            break
                            
                        case .stopped:
                            break
                        }
                    }
                    break
                    
                @unknown default:
                    break
                }
            }
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            
            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? NSNumber, let itemStatus = AVPlayerItem.Status(rawValue: statusNumber.intValue) {
                status = itemStatus
            } else {
                status = .unknown
            }
            
            // Switch over the status
            switch status {
            case .readyToPlay:
                // Player item is ready to play.
                if !loaded && (playing != nil) {
                    loaded = true
                    
                    if let hasCurrentTime = playing?.hasCurrentTime, hasCurrentTime {
                        if let atEnd = playing?.atEnd, atEnd, let end = duration?.seconds {
                            seek(to: end)
                        } else {
                            if let currentTime = playing?.currentTime, let time = Double(currentTime) {
                                seek(to: time)
                            }
                        }
                    } else {
                        playing?.currentTime = Constants.ZERO
                        seek(to: 0)
                    }
                    
                    if playOnLoad {
                        if let atEnd = playing?.atEnd, atEnd {
                            playing?.currentTime = Constants.ZERO
                            seek(to: 0)
                            playing?.atEnd = false
                        }
                        playOnLoad = false
                        play()
                    }
                    
                    Thread.onMainThread {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NOTIFICATION.READY_TO_PLAY), object: nil)
                    }
                }
                
                setupPlayingInfoCenter()
                break
                
            case .failed:
                // Player item failed. See error.
                Globals.shared.networkUnavailable("Media failed to load.")
                loadFailed = true
                Thread.onMainThread {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NOTIFICATION.FAILED_TO_PLAY), object: nil)
                }
                break
                
            case .unknown:
                // Player item is not yet ready.
                if #available(iOS 10.0, *) {
                    print(player?.reasonForWaitingToPlay as Any)
                } else {
                    // Fallback on earlier versions
                }
                break
                
            @unknown default:
                break
            }
        }
    }
    
    func checkPlayToEnd()
    {
        // didPlayToEnd observer doesn't always work.  This seemds to catch the cases where it doesn't.
        if let currentTime = currentTime?.seconds,
            let duration = duration?.seconds,
            Int(currentTime) >= Int(duration) {
            didPlayToEnd()
        }
    }
    
    @objc func didPlayToEnd()
    {
        pause()
        
        Thread.onMainThread {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.PAUSED), object: nil)
        }
        
        if let duration = duration?.seconds, let currentTime = currentTime?.seconds {
            playing?.atEnd = currentTime >= (duration - 1)
            if let atEnd = playing?.atEnd, !atEnd {
                reload(playing)
            }
        } else {
            playing?.atEnd = true
        }
        
        if Globals.shared.autoAdvance, let playing = playing, playing.atEnd,
            let mediaItems = playing.series?.sermons,
            let index = mediaItems.firstIndex(of: playing), index < (mediaItems.count - 1) {
            let nextMediaItem = mediaItems[index + 1]
            
            nextMediaItem.currentTime = Constants.ZERO
            
            self.playing = nextMediaItem
            playOnLoad = true
            
            setup(nextMediaItem)
        } else {
            stop()
        }
        
        Thread.onMainThread {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.SHOW_PLAYING), object: nil)
        }
    }
    
    func reload(_ sermon:Sermon?)
    {
        if let url = sermon?.playingURL {
            reload(url: url)
        }
    }
    
    func reload(url:URL?)
    {
        guard let url = url else {
            return
        }

        unload()
        
        unobserve()
        
        player?.replaceCurrentItem(with: AVPlayerItem(url: url))
        
        observe()
    }
    
    func setup(_ sermon:Sermon?)
    {
        guard let sermon = sermon else {
            return
        }
        
        guard let url = sermon.playingURL else {
            return
        }
        
        unload()
        
        unobserve()
        
        player = AVPlayer(url: url)
        
        if #available(iOS 10.0, *) {
            player?.automaticallyWaitsToMinimizeStalling = false
        } else {
            // Fallback on earlier versions
        }
        
        player?.actionAtItemEnd = .pause
        
        observe()
        
        pause() // Puts the player in a known state .paused
        
        MPRemoteCommandCenter.shared().playCommand.isEnabled = (player != nil)
        MPRemoteCommandCenter.shared().skipForwardCommand.isEnabled = (player != nil)
        MPRemoteCommandCenter.shared().skipBackwardCommand.isEnabled = (player != nil)
    }
    
    func setupPlayerAtEnd(_ sermon:Sermon?)
    {
        guard let sermon = sermon else {
            return
        }
        
        setup(sermon)

        guard let duration = duration else {
            return
        }
        
        seek(to: duration.seconds)
        pause()
        sermon.currentTime = Float(duration.seconds).description
    }

    func updateCurrentTimeForPlaying()
    {
        guard loaded else {
            return
        }
        
        guard let currentTime = currentTime else {
            return
        }
        
        guard let duration = duration else {
            return
        }
        
        var timeNow = 0
        
        if (currentTime.seconds > 0) && (currentTime.seconds <= duration.seconds) {
            timeNow = Int(currentTime.seconds)
        }
        
        if ((timeNow > 0) && (timeNow % 10) == 0) {
            if let playingCurrentTime = playing?.currentTime, let num = Float(playingCurrentTime), Int(num) != Int(currentTime.seconds) {
                playing?.currentTime = currentTime.seconds.description
            }
        }
    }

    func failedToLoad()
    {
        loadFailed = true
        
        Thread.onMainThread {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NOTIFICATION.FAILED_TO_LOAD), object: nil)
        }
        
        if (UIApplication.shared.applicationState == UIApplication.State.active) {
            Globals.shared.alert(title: "Failed to Load Content", message: "Please check your network connection and try again.")
        }
    }
    
    func failedToPlay()
    {
        loadFailed = true
        
        Thread.onMainThread {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NOTIFICATION.FAILED_TO_PLAY), object: nil)
        }
        
        if (UIApplication.shared.applicationState == UIApplication.State.active) {
            Globals.shared.alert(title: "Unable to Play Content", message: "Please check your network connection and try again.")
        }
    }
    
    @objc func playerObserver()
    {
        //        logPlayerState()
        
        guard let state = state,
            let startTime = stateTime?.startTime,
            let start = Double(startTime),
            let timeElapsed = stateTime?.timeElapsed,
            let currentTime = currentTime?.seconds else {
                return
        }
        
        switch state {
        case .none:
            break
            
        case .playing:
            if loaded && !loadFailed {
                
            } else {
                // If it isn't loaded then it shouldn't be playing.
            }
            break
            
        case .paused:
            if loaded {
                // What would cause this?
//                if (rate != 0) {
//                    pause()
//                }
            } else {
                if !loadFailed {
                    if Int(currentTime) <= Int(start) {
                        if (timeElapsed > Constants.MIN_LOAD_TIME) {
                            pause() // To reset playOnLoad
                            failedToLoad()
                        } else {
                            // Wait
                        }
                    } else {
                        // Paused normally
                    }
                } else {
                    // Load failed.
                }
            }
            break
            
        case .stopped:
            break
            
        case .seekingForward:
            break
            
        case .seekingBackward:
            break
        }
    }
    
    func playerTimer()
    {
        if (state != nil) {
            if (rate > 0) {
                updateCurrentTimeForPlaying()
            }
        }
    }
    
    func observe()
    {
        Thread.onMainThread {
            self.playerObserverTimer = Timer.scheduledTimer(timeInterval: Constants.INTERVALS.TIMER.PLAYER, target: self, selector: #selector(self.playerObserver), userInfo: nil, repeats: true)
        }
        
        unobserve()
        
        player?.addObserver( self,
                             forKeyPath: #keyPath(AVPlayer.timeControlStatus),
                             options: [.old, .new],
                             context: nil)
        
        player?.currentItem?.addObserver(self,
                                         forKeyPath: #keyPath(AVPlayerItem.status),
                                         options: [.old, .new],
                                         context: nil)
        observerActive = true
        observedItem = currentItem

        playerTimerReturn = player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1,preferredTimescale: Constants.CMTime_Resolution), queue: DispatchQueue.main, using: { (time:CMTime) in // [weak globals]
            self.playerTimer()
        })
        
        Thread.onMainThread {
            NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
        
        pause()
    }
    
    func unobserve()
    {
        playerObserverTimer?.invalidate()
        playerObserverTimer = nil
        
        if playerTimerReturn != nil {
            player?.removeTimeObserver(playerTimerReturn!)
            playerTimerReturn = nil
        }
        
        if observerActive {
            if observedItem != currentItem {
                print("observedItem != currentPlayer!")
            }
            if observedItem != nil {
                print("GLOBAL removeObserver: ",observedItem?.observationInfo as Any)

                player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), context: nil)
                
                player?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: nil)
                
                observedItem = nil
                
                observerActive = false
            } else {
                print("mediaPlayer.observedItem == nil!")
            }
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func unload()
    {
        loaded = false
        loadFailed = false
    }
    
    func updateCurrentTimeExactWhilePlaying()
    {
        if isPlaying {
            updateCurrentTimeExact()
        }
    }
    
    func updateCurrentTimeExact()
    {
        guard loaded else {
            print("Player NOT loaded.")
            return
        }
        
        guard let currentTime = currentTime else {
            print("Player has no currentTime.")
            return
        }
        
        updateCurrentTimeExact(currentTime.seconds)
    }
    
    func updateCurrentTimeExact(_ seekToTime:Double)
    {
        if (seekToTime >= 0) {
            playing?.currentTime = seekToTime.description
        } else {
            print("seekeToTime < 0")
        }
    }
    
    func pauseIfPlaying()
    {
        if isPlaying {
            pause()
        } else {
            print("Player NOT playing.")
        }
    }
    
    func play()
    {
        if loaded {
            stateTime = PlayerStateTime(sermon: playing,state:.playing)
            
            Thread.onMainThread {
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.UPDATE_PLAY_PAUSE), object: nil)
            }
            
            player?.play()
            
            setupPlayingInfoCenter()
        }
    }
    
    func stop()
    {
        pause()
        
        unload()
        
        unobserve()
        
        stateTime = nil // PlayerStateTime(sermon: playing,state:.stopped)
        
        playing = nil
        player = nil
    }
    
    func pause()
    {
        updateCurrentTimeExact()
        stateTime = PlayerStateTime(sermon: playing,state:.paused)
        
        player?.pause()
        
        Thread.onMainThread {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.UPDATE_PLAY_PAUSE), object: nil)
        }
        
        setupPlayingInfoCenter()
    }
    
    func seek(to: Double?)
    {
        guard let to = to else {
            return
        }

        guard loaded else {
            return
        }
        
        guard let currentItem = currentItem else {
            return
        }
        
        var seek = to
        
        if seek > currentItem.duration.seconds {
            seek = currentItem.duration.seconds
        }
        
        if seek < 0 {
            seek = 0
        }
        
        player?.seek(to: CMTimeMakeWithSeconds(seek,preferredTimescale: Constants.CMTime_Resolution), toleranceBefore: CMTimeMakeWithSeconds(0,preferredTimescale: Constants.CMTime_Resolution), toleranceAfter: CMTimeMakeWithSeconds(0,preferredTimescale: Constants.CMTime_Resolution),
                     completionHandler: { (finished:Bool) in
                        if finished {
                            Thread.onMainThread {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.DONE_SEEKING), object: nil)
                            }
                        }
        })
        
        playing?.currentTime = seek.description
        stateTime?.startTime = seek.description
        
        setupPlayingInfoCenter()
    }
    
    var currentItem:AVPlayerItem? {
        get {
            return player?.currentItem
        }
    }
    
    var currentTime:CMTime? {
        get {
            return player?.currentTime()
        }
    }
    
    var duration:CMTime? {
        get {
            return player?.currentItem?.duration
        }
    }
    
    var state:PlayerState? {
        get {
            return stateTime?.state
        }
        set {
            if let newValue = newValue {
                stateTime?.state = newValue
            }
        }
    }
    
    var startTime:String? {
        get {
            return stateTime?.startTime
        }
        set {
            stateTime?.startTime = newValue
        }
    }
    
    var rate:Float? {
        get {
            return player?.rate
        }
    }
    
    var isPlaying:Bool {
        get {
            return stateTime?.state == .playing
        }
    }
    
    var isPaused:Bool {
        get {
            return stateTime?.state == .paused
        }
    }
    
    var playOnLoad:Bool = true
    var loaded:Bool = false
    var loadFailed:Bool = false
    
    var playing:Sermon? {
        willSet {
            
        }
        didSet {
            if playing == nil {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            } else {

            }
            
            let defaults = UserDefaults.standard
            if let playing = playing {
                if let name = playing.series?.name {
                    defaults.set(name, forKey: Constants.SETTINGS.PLAYING.SERIES)
                }
                defaults.set(playing.id, forKey: Constants.SETTINGS.PLAYING.SERMON)
            } else {
                defaults.removeObject(forKey: Constants.SETTINGS.PLAYING.SERIES)
                defaults.removeObject(forKey: Constants.SETTINGS.PLAYING.SERMON)
            }
            defaults.synchronize()
        }
    }
    
    func logPlayerState()
    {
        stateTime?.log()
    }
}
