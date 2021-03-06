//
//  MediaCollectionViewController.swift
//  TWU
//
//  Created by Steve Leeke on 7/28/15.
//  Copyright (c) 2015 Steve Leeke. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

extension MediaCollectionViewController : UICollectionViewDataSource
{
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in:UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        //return series.count
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return globals.activeSeries?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.IDENTIFIER.SERIES_CELL, for: indexPath) as? MediaCollectionViewCell ?? MediaCollectionViewCell()
        
        // Configure the cell
        cell.series = globals.activeSeries?[(indexPath as NSIndexPath).row]
        
        return cell
    }
}

extension MediaCollectionViewController : UICollectionViewDelegate
{
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool
    {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {

    }
    
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath?
    {
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            return indexPath
        } else {
            return IndexPath(item: 0, section: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        //        print("didSelect")
        
        if let cell: MediaCollectionViewCell = collectionView.cellForItem(at: indexPath) as? MediaCollectionViewCell {
            seriesSelected = cell.series
        } else {
            
        }
    }
}

extension MediaCollectionViewController : PopoverTableViewControllerDelegate
{
    // MARK: PopoverTableViewControllerDelegate

    func clearView()
    {
        guard Thread.isMainThread else {
            return
        }
        
        seriesSelected = nil
        sermonSelected = nil
        
        tableView.reloadData()
        
        updateUI()
    }

    func handleRefresh()
    {
        guard Thread.isMainThread else {
            return
        }
        
        globals.mediaPlayer.unobserve()
        
        globals.mediaPlayer.pause()
        
        globals.searchActive = false
        
        clearView()
        
//        if let isCollapsed = splitViewController?.isCollapsed, !isCollapsed {
//            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.CLEAR_VIEW), object: nil)
//        }
        
        disableBarButtons()
        
        // This is ABSOLUTELY ESSENTIAL to reset all of the Media so that things load as if from a cold start.
        globals = Globals()
        
        collectionView?.reloadData()
        
        loadSeries()
        {
            if globals.series == nil {
                let alert = UIAlertController(title: "No media available.",
                                              message: "Please check your network connection and try again.",
                                              preferredStyle: UIAlertControllerStyle.alert)
                
                let action = UIAlertAction(title: Constants.Okay, style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) -> Void in
                    
                })
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
            } else {
                self.collectionView.reloadData()
                self.scrollToSeries(self.seriesSelected)
            }
//            guard globals.series == nil else {
//                return
//            }
//
//            let alert = UIAlertController(title: "No media available.",
//                                          message: "Please check your network connection and try again.",
//                                          preferredStyle: UIAlertControllerStyle.alert)
//
//            let action = UIAlertAction(title: Constants.Okay, style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) -> Void in
//
//            })
//            alert.addAction(action)
//
//            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func rowClickedAtIndex(_ index: Int, strings: [String]?, purpose:PopoverPurpose)
    {
        guard Thread.isMainThread else {
            return
        }
        
        dismiss(animated: true, completion: nil)
        
        guard let string = strings?[index] else {
            return
        }
        
        splitViewController?.preferredDisplayMode = .allVisible
        
        switch purpose {
        case .selectingSorting:
            globals.sorting = string
            collectionView.reloadData()
            scrollToSeries(seriesSelected)
            break
            
        case .selectingFiltering:
            guard (globals.filter != string) else {
                break
            }
            
            if (string == Constants.All) {
                globals.showing = .all
                globals.filter = nil
            } else {
                globals.showing = .filtered
                globals.filter = string
            }
            
            self.collectionView.reloadData()
            
            scrollToSeries(seriesSelected)
            break
            
        case .selectingMenu:
            globals.showingAbout = false

            switch string {
            case "Refresh Media":
                handleRefresh()
                break
                
            case "About":
                globals.showingAbout = true
                seriesSelected = nil
                break
                
            case "Sorting":
                sorting()
                break
                
            case "Filtering":
                filtering()
                break
                
            default:
                break
            }
            
        default:
            break
        }
    }
}

extension MediaCollectionViewController : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if let show = seriesSelected?.show {
            return show
        } else {
            return 0
        }
    }
}

extension MediaCollectionViewController : UITableViewDelegate
{
    func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?
    {
        if let indexPath = tableView.indexPathForSelectedRow {
            return indexPath
        } else {
            return IndexPath(item: 0, section: 0)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        sermonSelected = seriesSelected?.sermons?[(indexPath as NSIndexPath).row]

        if (sermonSelected?.series == seriesSelected) && (globals.mediaPlayer.url == sermonSelected?.playingURL) {
            addProgressObserver()
        }
        
        updateUI()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.IDENTIFIER.SERMON_CELL, for: indexPath) as? MediaTableViewCell ?? MediaTableViewCell()
        
        // Configure the cell...
        if indexPath.row < seriesSelected?.sermons?.count {
            cell.sermon = seriesSelected?.sermons?[indexPath.row]
        }
        
        return cell
    }
}

class MediaCollectionViewController: UIViewController
{
    var preferredFocusView:UIView?
    {
        didSet {
            guard (preferredFocusView != nil) else {
                return
            }
            
            Thread.onMainThread {
                self.setNeedsFocusUpdate()
            }
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override var preferredFocusEnvironments : [UIFocusEnvironment]
    {
        if let preferredFocusView = preferredFocusView {
            return [preferredFocusView]
        } else {
            return []
        }
    }
    
    @IBOutlet weak var tomPennington: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var backgroundLogo: UIImageView!

    @IBOutlet weak var progressView:UIProgressView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var avPlayerSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var restartButton: UIButton!
    {
        didSet {
            restartButton.setTitle(Constants.FA.RESTART)
        }
    }
    @IBAction func restart(_ sender: UIButton)
    {
        globals.mediaPlayer.seek(to: 0)
    }
    
    @IBOutlet weak var skipBackwardsButton: UIButton!
    {
        didSet {
            skipBackwardsButton.setTitle(Constants.FA.REWIND)
        }
    }
    @IBAction func skipBackwards(_ sender: UIButton)
    {
        guard let currentTime = globals.mediaPlayer.currentTime else {
            return
        }
        
        globals.mediaPlayer.seek(to: currentTime.seconds - Constants.INTERVAL.SKIP_TIME)
    }
    
    @IBOutlet weak var skipForwardsButton: UIButton!
    {
        didSet {
            skipForwardsButton.setTitle(Constants.FA.FF)
        }
    }
    @IBAction func skipForwards(_ sender: UIButton)
    {
        guard let currentTime = globals.mediaPlayer.currentTime else {
            return
        }
        
        globals.mediaPlayer.seek(to: currentTime.seconds + Constants.INTERVAL.SKIP_TIME)
    }
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBAction func playPause(_ sender: UIButton)
    {
        guard let state = globals.mediaPlayer.state, globals.mediaPlayer.playing == sermonSelected, globals.mediaPlayer.player != nil else {
            playNewSermon(sermonSelected)
            return
        }
        
        switch state {
        case .none:
            print("none")
            break
            
        case .playing:
            print("playing")
            globals.mediaPlayer.pause()
            
            setupPlayPauseButton()
            
            if spinner.isAnimating {
                spinner.stopAnimating()
                spinner.isHidden = true
            }
            break
            
        case .paused:
            print("paused")
            if globals.mediaPlayer.loaded && (globals.mediaPlayer.url == sermonSelected?.playingURL) {
                addProgressObserver()
                playCurrentSermon(sermonSelected)
            } else {
                playNewSermon(sermonSelected)
            }
            break
            
        case .stopped:
            print("stopped")
            break
            
        case .seekingForward:
            print("seekingForward")
            globals.mediaPlayer.pause()
            break
            
        case .seekingBackward:
            print("seekingBackward")
            globals.mediaPlayer.pause()
            break
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var elapsed: UILabel!
    @IBOutlet weak var remaining: UILabel!
    
    @IBOutlet weak var seriesArt: UIImageView!
    
    @IBOutlet weak var seriesLabel: UILabel!
    @IBOutlet weak var seriesDescription: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
    {
        didSet {
            tableView.mask = nil
            tableView.backgroundColor = UIColor.clear
        }
    }
    
    @IBOutlet weak var sermonLabel: UILabel!
    {
        didSet {
            sermonLabel.isHidden = true
        }
    }
    
    var observerActive = false

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        //        guard context == &PlayerContext else {
        //            super.observeValue(forKeyPath: keyPath,
        //                               of: object,
        //                               change: change,
        //                               context: nil)
        //            return
        //        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            
            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? NSNumber, let itemStatus = AVPlayerItemStatus(rawValue: statusNumber.intValue) {
                status = itemStatus
            } else {
                status = .unknown
            }
            
            // Switch over the status
            switch status {
            case .readyToPlay:
                // Player item is ready to play.
                
                if let currentTime = sermonSelected?.currentTime, let timeNow = Double(currentTime), let length = player?.currentItem?.duration.seconds {
                    let progress = timeNow / length
                    
                    progressView.progress = Float(progress)
                    setTimes(timeNow: timeNow,length: length)
                    
                    avPlayerSpinner.stopAnimating()
                    avPlayerSpinner.isHidden = true
                    
                    controlView.isHidden = false
                    elapsed.isHidden = false
                    remaining.isHidden = false
                    progressView.isHidden = false
                }
                
                preferredFocusView = playPauseButton
                break
                
            case .failed:
                // Player item failed. See error.
                break
                
            case .unknown:
                // Player item is not yet ready.
                break
            }
        }
    }
    
    var player:AVPlayer?
    
    func removePlayerObserver()
    {
        // observerActive and this function would not be needed if we cache as we would assume EVERY AVPlayer in the cache has an observer => must remove them prior to dealloc.
        
        if observerActive {
            player?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: nil) // &PlayerContext
            observerActive = false
        }
    }
    
    func addPlayerObserver()
    {
        player?.currentItem?.addObserver(self,
                                         forKeyPath: #keyPath(AVPlayerItem.status),
                                         options: [.old, .new],
                                         context: nil) // &PlayerContext
        observerActive = true
    }
    
    func playerURL(url: URL?)
    {
        guard let url = url else {
            return
        }

        removePlayerObserver()
        
        avPlayerSpinner.isHidden = false
        avPlayerSpinner.startAnimating()
        
        player = AVPlayer(url: url)
        addPlayerObserver()
    }
    
    var progressObserver: Timer?
    
    var seriesSelected:Series? {
        willSet {
            
        }
        didSet {
            if (seriesSelected != nil) {
                globals.showingAbout = false
                
                avPlayerSpinner.stopAnimating()
                sermonSelected = seriesSelected?.sermonSelected
                selectSermon(sermonSelected)
                
                preferredFocusView = tableView
                
                if (sermonSelected?.series == seriesSelected) && (globals.mediaPlayer.url == sermonSelected?.playingURL) {
                    addProgressObserver()
                } else {
                    globals.mediaPlayer.stop()
                }

                if let id = seriesSelected?.id {
                    let defaults = UserDefaults.standard
                    defaults.set("\(id)", forKey: Constants.SETTINGS.SELECTED.SERIES)
                    defaults.synchronize()
                }
            } else {
                print("MediaCollectionViewController:seriesSelected nil")
                sermonSelected = nil
            }

            tableView.reloadData()

            updateUI()
        }
    }
    
    var sermonSelected:Sermon? {
        willSet {
            
        }
        didSet {
            sermonLabel.text = sermonSelected?.title
            
            sermonLabel.isHidden = sermonSelected?.title == nil
            
            seriesSelected?.sermonSelected = sermonSelected
            
            guard sermonSelected != nil else {
                updateUI()
                return
            }
            
            if (sermonSelected != oldValue) {
                if sermonSelected != globals.mediaPlayer.playing, let playingURL = sermonSelected?.playingURL {
                    globals.mediaPlayer.stop()
                    removeProgressObserver()
                    playerURL(url: playingURL)
                } else {
                    preferredFocusView = playPauseButton
                    removePlayerObserver()
                    addProgressObserver()
                }
            } else {
                preferredFocusView = playPauseButton
            }
        }
    }
    
    @objc func setupPlayPauseButton()
    {
        guard (sermonSelected != nil) else {
            playPauseButton.isEnabled = false
            playPauseButton.isHidden = true

            restartButton.isEnabled = false
            restartButton.isHidden = true
            
            skipBackwardsButton.isEnabled = false
            skipBackwardsButton.isHidden = true
            
            skipForwardsButton.isEnabled = false
            skipForwardsButton.isHidden = true

            controlView.isHidden = true
            return
        }
        
        if (sermonSelected == globals.mediaPlayer.playing) {
            playPauseButton.isEnabled = globals.mediaPlayer.loaded || globals.mediaPlayer.loadFailed

            if let state = globals.mediaPlayer.state {
                switch state {
                case .playing:
                    playPauseButton.setTitle(Constants.FA.PAUSE)
                    break
                    
                case .paused:
                    playPauseButton.setTitle(Constants.FA.PLAY)
                    break
                    
                default:
                    break
                }
            }
            
            restartButton.isEnabled = globals.mediaPlayer.loaded
            skipBackwardsButton.isEnabled = globals.mediaPlayer.loaded
            skipForwardsButton.isEnabled = globals.mediaPlayer.loaded
            
            restartButton.isHidden = false
            skipBackwardsButton.isHidden = false
            skipForwardsButton.isHidden = false
        } else {
            playPauseButton.isEnabled = true
            playPauseButton.setTitle(Constants.FA.PLAY)
            
            restartButton.isEnabled = false
            skipBackwardsButton.isEnabled = false
            skipForwardsButton.isEnabled = false

            restartButton.isHidden = false
            skipBackwardsButton.isHidden = false
            skipForwardsButton.isHidden = false
        }
        
        controlView.isHidden = false
        
        playPauseButton.isHidden = false
    }
    
    fileprivate func setupArtAndDescription()
    {
        guard Thread.isMainThread else {
            return
        }
        
        guard let seriesSelected = seriesSelected else {
            seriesArt.isHidden = true
            
            logo.isHidden = globals.showingAbout
            
            backgroundLogo.isHidden = !logo.isHidden
            tomPennington.isHidden = !logo.isHidden
            
            let description = "Tom Pennington is Pastor-Teacher at Countryside Bible Church in Southlake, TX.<br/>His pulpit ministry provides the material for The Word Unleashed.\n\nOur ministry is founded upon one principle: God has given you every spiritual resource you need to grow in Jesus Christ, and you find those resources in His all-sufficient Word (2 Pet. 1:3). That's why Tom embraces expository preaching - an approach that seeks to understand what the original authors of Scripture meant, rather than an approach that reads our own meaning into it. If that's what you've been looking for, you've come to the right place.  It's our prayer that the transforming power of God's Word be unleashed in your life.\n\nP.O. Box 96077<br>Southlake, Texas 76092<br/>www.thewordunleashed.org<br/>listeners@thewordunleashed.org<br/>877-577-WORD (9673)"
            
            seriesLabel.text = description.replacingOccurrences(of: "<br/>", with: "\n").replacingOccurrences(of: "<br>", with: "\n")
            
            return
        }
        
        logo.isHidden = true
        tomPennington.isHidden = true

        backgroundLogo.isHidden = false

        seriesLabel.text = seriesSelected.text?.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\n\n", with: "\n").replacingOccurrences(of: "\n", with: "\n\n").replacingOccurrences(of: "?۪", with: "'").replacingOccurrences(of: " ??? What", with: ", what").replacingOccurrences(of: " ???", with: ",").replacingOccurrences(of: "&rsquo;", with: "’").replacingOccurrences(of: "&mdash;", with: "—").replacingOccurrences(of: "&ndash;", with: "—").replacingOccurrences(of: "sanctification–", with: "sanctification")
        
//        seriesLabel.text = nil

//        if let text = seriesSelected.text?.replacingOccurrences(of: " ???", with: ",").replacingOccurrences(of: "–", with: "-").replacingOccurrences(of: "—", with: "&mdash;").replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\n\n", with: "\n").replacingOccurrences(of: "\n", with: "<br><br>").replacingOccurrences(of: "’", with: "&rsquo;").replacingOccurrences(of: "“", with: "&ldquo;").replacingOccurrences(of: "”", with: "&rdquo;").replacingOccurrences(of: "?۪s", with: "'s").replacingOccurrences(of: "…", with: "...") {
//            if  let data = text.data(using: String.Encoding.utf8, allowLossyConversion: false),
//                let attributedString = try? NSMutableAttributedString(data: data,
//                                                                      options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
//                                                                      documentAttributes: nil) {
//                attributedString.addAttributes([NSFontAttributeName:UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1)],
//                                               range: NSMakeRange(0, attributedString.length))
//
//                seriesDescription.attributedText = attributedString
//            }
//        }
        
        if let image = seriesSelected.loadArt() {
            seriesArt.image = image
        } else {
            DispatchQueue.global(qos: .background).async { () -> Void in
                if let image = seriesSelected.fetchArt() {
                    if self.seriesSelected == seriesSelected {
                        Thread.onMainThread {
                            self.seriesArt.image = image
                        }
                    }
                }
            }
        }

        seriesArt.isHidden = false
        seriesDescription.isHidden = false
    }
    
    func setupTitle()
    {
        guard Thread.isMainThread else {
            return
        }
        
        if (!globals.isLoading) {
            self.navigationItem.title = Constants.TWU.LONG
        }
        
        self.navigationItem.title = seriesSelected?.title
    }
    
    func setupSpinner()
    {
        guard Thread.isMainThread else {
            return
        }
        
        guard (sermonSelected != nil) && (sermonSelected == globals.mediaPlayer.playing) else {
            if spinner.isAnimating {
                spinner.stopAnimating()
                spinner.isHidden = true
            }
            return
        }
        
        if !globals.mediaPlayer.loaded && !globals.mediaPlayer.loadFailed {
            if !spinner.isAnimating {
                spinner.isHidden = false
                spinner.startAnimating()
            }
        } else {
            if globals.mediaPlayer.isPaused {
                if spinner.isAnimating {
                    spinner.isHidden = true
                    spinner.stopAnimating()
                }
            }
            
            if globals.mediaPlayer.isPlaying {
                if let currentTime = globals.mediaPlayer.playing?.currentTime, globals.mediaPlayer.currentTime?.seconds > Double(currentTime) {
                    spinner.isHidden = true
                    spinner.stopAnimating()
                } else {
                    spinner.isHidden = false
                    spinner.startAnimating()
                }
            }
        }
    }
    
    @objc func updateUI()
    {
        guard Thread.isMainThread else {
            return
        }
        
        setupArtAndDescription()
        
        setupTitle()
        setupPlayPauseButton()
        setupSpinner()
        setupProgressView()
        
        collectionView.reloadData()
    }
    
    func scrollToSermon(_ sermon:Sermon?,select:Bool,position:UITableViewScrollPosition)
    {
        guard Thread.isMainThread else {
            return
        }
        
        guard (sermon != nil) else {
            return
        }
        
        var indexPath = IndexPath(row: 0, section: 0)
        
        if (seriesSelected?.show > 1) {
            if let sermon = sermon, let sermonIndex = seriesSelected?.sermons?.index(of: sermon) {
                //                    print("\(sermonIndex)")
                indexPath = IndexPath(row: sermonIndex, section: 0)
            }
        }
        
        if (select) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: position)
        }
        
        tableView.scrollToRow(at: indexPath, at: position, animated: false)
    }

    fileprivate func setTimes(timeNow:Double, length:Double)
    {
        let elapsedHours = max(Int(timeNow / (60*60)),0)
        let elapsedMins = max(Int((timeNow - (Double(elapsedHours) * 60*60)) / 60),0)
        let elapsedSec = max(Int(timeNow.truncatingRemainder(dividingBy: 60)),0)
        
        var elapsed:String
        
        if (elapsedHours > 0) {
            elapsed = "\(String(format: "%d",elapsedHours)):"
        } else {
            elapsed = Constants.EMPTY_STRING
        }
        
        elapsed = elapsed + "\(String(format: "%02d",elapsedMins)):\(String(format: "%02d",elapsedSec))"
        
        self.elapsed.text = elapsed
        
        let timeRemaining = max(length - timeNow,0)
        let remainingHours = max(Int(timeRemaining / (60*60)),0)
        let remainingMins = max(Int((timeRemaining - (Double(remainingHours) * 60*60)) / 60),0)
        let remainingSec = max(Int(timeRemaining.truncatingRemainder(dividingBy: 60)),0)
        
        var remaining:String
        
        if (remainingHours > 0) {
            remaining = "\(String(format: "%d",remainingHours)):"
        } else {
            remaining = Constants.EMPTY_STRING
        }
        
        remaining = remaining + "\(String(format: "%02d",remainingMins)):\(String(format: "%02d",remainingSec))"
        
        self.remaining.text = remaining
    }
    
    
    fileprivate func setProgressAndTimesToAudio()
    {
        guard Thread.isMainThread else {
            return
        }
        
        guard let length = globals.mediaPlayer.duration?.seconds else {
            return
        }
        
        guard length > 0 else {
            return
        }
        
        guard let currentTime = globals.mediaPlayer.playing?.currentTime else {
            return
        }
        
        guard let playingCurrentTime = Double(currentTime) else {
            return
        }
        
        guard let playerCurrentTime = globals.mediaPlayer.currentTime?.seconds else {
            return
        }
        
        guard let state = globals.mediaPlayer.state else {
            return
        }
        
        var progress = -1.0
        
        if (length > 0) {
            switch state {
            case .playing:
                if playingCurrentTime >= 0, let duration = globals.mediaPlayer.duration, playerCurrentTime <= duration.seconds {
                    progress = playerCurrentTime / length
                    
                    if globals.mediaPlayer.loaded {
                        if playerCurrentTime == 0 {
                            progress = playingCurrentTime / length
                            progressView.progress = Float(progress)
                            setTimes(timeNow: playingCurrentTime,length: length)
                        } else {
                            progressView.progress = Float(progress)
                            setTimes(timeNow: playerCurrentTime,length: length)
                        }
                    }
                    
                    elapsed.isHidden = false
                    remaining.isHidden = false
                    progressView.isHidden = false
                }
                break
                
            case .paused:
                progress = playingCurrentTime / length
                
                progressView.progress = Float(progress)
                setTimes(timeNow: playingCurrentTime,length: length)
                
                elapsed.isHidden = false
                remaining.isHidden = false
                progressView.isHidden = false
                break
                
            case .stopped:
                progress = playingCurrentTime / length
                
                progressView.progress = Float(progress)
                setTimes(timeNow: playingCurrentTime,length: length)
                
                elapsed.isHidden = false
                remaining.isHidden = false
                progressView.isHidden = false
                break
                
            default:
                break
            }
        }
    }
    
    func selectSermon(_ sermon:Sermon?)
    {
        guard (sermon != nil) else {
            return
        }
        
        guard (seriesSelected != nil) else {
            return
        }
        
        guard (seriesSelected == sermon?.series) else {
            return
        }
        
        setupPlayPauseButton()
        
        //Without this background/main dispatching there isn't time to scroll correctly after a reload.
        DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
            Thread.onMainThread {
                self.scrollToSermon(sermon, select: true, position: UITableViewScrollPosition.none)
            }
        })
    }
    
    func progressTimer()
    {
        guard Thread.isMainThread else {
            return
        }
        
        guard (sermonSelected != nil) else {
            return
        }
        
        guard (sermonSelected == globals.mediaPlayer.playing) else {
            return
        }
        
        guard let state = globals.mediaPlayer.state else {
            return
        }
        
        guard (globals.mediaPlayer.startTime != nil) else {
            return
        }
        
        guard (globals.mediaPlayer.currentTime != nil) else {
            return
        }
        
        setupPlayPauseButton()
        
        if (!globals.mediaPlayer.loaded) {
            if (!spinner.isAnimating) {
                spinner.isHidden = false
                spinner.startAnimating()
            }
        }
        
        switch state {
        case .none:
            print("none")
            break
            
        case .playing:
            print("playing")
            setProgressAndTimesToAudio()
            
            if (!globals.mediaPlayer.loaded) {
                if (!spinner.isAnimating) {
                    spinner.isHidden = false
                    spinner.startAnimating()
                }
            } else {
                if globals.mediaPlayer.rate > 0, let startTime = globals.mediaPlayer.startTime, globals.mediaPlayer.currentTime?.seconds > Double(startTime) {
                    if spinner.isAnimating {
                        spinner.isHidden = true
                        spinner.stopAnimating()
                    }
                } else {
                    if !spinner.isAnimating {
                        spinner.isHidden = false
                        spinner.startAnimating()
                    }
                }
            }
            break
            
        case .paused:
            print("paused")
            
            if globals.mediaPlayer.loaded {
                setProgressAndTimesToAudio()
            }
            
            if globals.mediaPlayer.loaded || globals.mediaPlayer.loadFailed {
                if spinner.isAnimating {
                    spinner.stopAnimating()
                    spinner.isHidden = true
                }
            }
            break
            
        case .stopped:
            print("stopped")
            break
            
        case .seekingForward:
            print("seekingForward")
            if !spinner.isAnimating {
                spinner.isHidden = false
                spinner.startAnimating()
            }
            break
            
        case .seekingBackward:
            print("seekingBackward")
            if !spinner.isAnimating {
                spinner.isHidden = false
                spinner.startAnimating()
            }
            break
        }
    }
    
    func playCurrentSermon(_ sermon:Sermon?)
    {
        guard let sermon = sermon else {
            return
        }
        
        var seekToTime:CMTime?
        
        if let hasCurrentTime = sermonSelected?.hasCurrentTime, hasCurrentTime {
            if sermon.atEnd {
                NSLog("playPause globals.mediaPlayer.currentTime and globals.player.playing!.currentTime reset to 0!")
                globals.mediaPlayer.playing?.currentTime = Constants.ZERO
                seekToTime = CMTimeMakeWithSeconds(0,Constants.CMTime_Resolution)
                sermon.atEnd = false
            } else {
                if let currentTime = sermon.currentTime, let num = Double(currentTime) {
                    seekToTime = CMTimeMakeWithSeconds(num,Constants.CMTime_Resolution)
                }
            }
        } else {
            NSLog("playPause selectedMediaItem has NO currentTime!")
            sermon.currentTime = Constants.ZERO
            seekToTime = CMTimeMakeWithSeconds(0,Constants.CMTime_Resolution)
        }
        
        if let seekToTime = seekToTime {
            let loadedTimeRanges = (globals.mediaPlayer.player?.currentItem?.loadedTimeRanges as? [CMTimeRange])?.filter({ (cmTimeRange:CMTimeRange) -> Bool in
                return cmTimeRange.containsTime(seekToTime)
            })
            
            let seekableTimeRanges = (globals.mediaPlayer.player?.currentItem?.seekableTimeRanges as? [CMTimeRange])?.filter({ (cmTimeRange:CMTimeRange) -> Bool in
                return cmTimeRange.containsTime(seekToTime)
            })
            
            if (loadedTimeRanges != nil) || (seekableTimeRanges != nil) {
                globals.mediaPlayer.seek(to: seekToTime.seconds)
                
                globals.mediaPlayer.play()
                
                setupPlayPauseButton()
            } else {
                playNewSermon(sermon)
            }
        }
    }
    
    fileprivate func reloadCurrentSermon(_ sermon:Sermon?) {
        //This guarantees a fresh start.
        globals.mediaPlayer.playOnLoad = true
        globals.mediaPlayer.reload(sermon)
        addProgressObserver()
        setupPlayPauseButton()
    }
    
    fileprivate func playNewSermon(_ sermon:Sermon?)
    {
        globals.mediaPlayer.pauseIfPlaying()
        
        guard (sermon != nil) else {
            return
        }
        
        if (!spinner.isAnimating) {
            spinner.isHidden = false
            spinner.startAnimating()
        }
        
        globals.mediaPlayer.playing = sermon
        
        removeProgressObserver()
        
        //This guarantees a fresh start.
        globals.mediaPlayer.playOnLoad = true
        globals.mediaPlayer.setup(sermon)
        
        addProgressObserver()
        
        if (view.window != nil) {
            setupProgressView()
            setupPlayPauseButton()
        }
    }
    
    fileprivate func setupProgressView()
    {
        guard Thread.isMainThread else {
            return
        }
        
        guard (sermonSelected != nil) else {
            elapsed.isHidden = true
            remaining.isHidden = true
            progressView.isHidden = true
            return
        }
        
        if (globals.mediaPlayer.playing != nil) && (globals.mediaPlayer.playing == sermonSelected) {
            if !globals.mediaPlayer.loadFailed {
                setProgressAndTimesToAudio()
            } else {
                elapsed.isHidden = true
                remaining.isHidden = true
                progressView.isHidden = true
            }
        } else {
            if  player?.currentItem?.status == .readyToPlay,
                let length = player?.currentItem?.duration.seconds,
                let currentTime = sermonSelected?.currentTime,
                let timeNow = Double(currentTime) {
                let progress = timeNow / length
                
                progressView.progress = Float(progress)
                setTimes(timeNow: timeNow,length: length)
                
                elapsed.isHidden = false
                remaining.isHidden = false
                progressView.isHidden = false
            } else {
                elapsed.isHidden = true
                remaining.isHidden = true
                progressView.isHidden = true
            }
        }
    }

    func sorting()
    {
        if let navigationController = self.storyboard?.instantiateViewController(withIdentifier: Constants.IDENTIFIER.POPOVER_TABLEVIEW_NAV) as? UINavigationController {
            if let popover = navigationController.viewControllers[0] as? PopoverTableViewController {
                navigationController.modalPresentationStyle = .fullScreen
                
                popover.navigationItem.title = Constants.Sorting_Options_Title
                
                popover.delegate = self
                
                popover.purpose = .selectingSorting
                popover.section.strings = Constants.Sorting.Options
                
                present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    func filtering()
    {
        if let navigationController = self.storyboard?.instantiateViewController(withIdentifier: Constants.IDENTIFIER.POPOVER_TABLEVIEW_NAV) as? UINavigationController,
            let popover = navigationController.viewControllers[0] as? PopoverTableViewController {
            navigationController.modalPresentationStyle = .fullScreen
            
            popover.navigationItem.title = Constants.Filtering_Options_Title
            
            popover.delegate = self
            
            popover.purpose = .selectingFiltering
            popover.section.strings = booksFromSeries(globals.series)
            popover.section.strings?.insert(Constants.All, at: 0)
            
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    func settings()
    {
        //In case we have one already showing
        dismiss(animated: true, completion: nil)
        
        if let navigationController = self.storyboard?.instantiateViewController(withIdentifier: Constants.IDENTIFIER.POPOVER_TABLEVIEW) as? UINavigationController,
            let popover = navigationController.viewControllers[0] as? PopoverTableViewController {
            navigationController.modalPresentationStyle = .fullScreen
            
            popover.navigationItem.title = "Auto Advance"
            
            popover.delegate = self
            
            popover.purpose = .selectingSettings
            popover.section.strings = ["On, Off"]
            
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    func scrollToSeries(_ series:Series?)
    {
        guard let series = series else {
            return
        }
        
        guard let index = globals.activeSeries?.index(of: series) else {
            preferredFocusView = playPauseButton
            return
        }
        
        let indexPath = IndexPath(item: index, section: 0)
        
        self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: false)
        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.left)
        
        preferredFocusView = collectionView.cellForItem(at: indexPath)
    }
    
    func setupViews()
    {
        collectionView.reloadData()
        
        enableBarButtons()
        
        setupTitle()
    }
    
    func seriesFromSeriesDicts(_ seriesDicts:[[String:String]]?) -> [Series]?
    {
        return seriesDicts?.filter({ (seriesDict:[String:String]) -> Bool in
            let series = Series(seriesDict: seriesDict)
            return series.show != 0
        }).map({ (seriesDict:[String:String]) -> Series in
            return Series(seriesDict: seriesDict)
        })
    }
    
    func jsonFromFileSystem(filename:String?) -> Any?
    {
        guard let filename = filename else {
            return nil
        }
        
        guard let jsonFileSystemURL = cachesURL()?.appendingPathComponent(filename) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: jsonFileSystemURL) // , options: NSData.ReadingOptions.mappedIfSafe
            print("able to read json from the URL.")
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                return json
            } catch let error as NSError {
                NSLog(error.localizedDescription)
                return nil
            }
        } catch let error as NSError {
            print("Network unavailable: json could not be read from the file system.")
            NSLog(error.localizedDescription)
            return nil
        }
    }
    
    func jsonFromURL(url:String,filename:String) -> Any?
    {
        guard globals.reachability.isReachable, let url = URL(string: url) else {
            return jsonFromFileSystem(filename: filename)
        }
        
        do {
            let data = try Data(contentsOf: url)
            print("able to read json from the URL.")
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                do {
                    if let jsonFileSystemURL = cachesURL()?.appendingPathComponent(filename) {
                        try data.write(to: jsonFileSystemURL)
                    }
                    print("able to write json to the file system")
                } catch let error as NSError {
                    print("unable to write json to the file system.")
                    NSLog(error.localizedDescription)
                }
                
                return json
            } catch let error as NSError {
                NSLog(error.localizedDescription)
                return jsonFromFileSystem(filename: filename)
            }
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            return jsonFromFileSystem(filename: filename)
        }
    }
    
    func loadSeriesDicts() -> [[String:String]]?
    {
        if let json = jsonFromURL(url: Constants.JSON.URL,filename: Constants.JSON.SERIES) as? [String:Any] {
            var seriesDicts = [[String:String]]()
            
            if let series = json[Constants.JSON.ARRAY_KEY] as? [[String:String]] {
                for i in 0..<series.count {
                    var dict = [String:String]()
                    
                    for (key,value) in series[i] {
                        dict["\(key)"] = "\(value)".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                    
                    seriesDicts.append(dict)
                }
            }
            
            return seriesDicts.count > 0 ? seriesDicts : nil
        } else {
            print("could not get json from file, make sure that file contains valid json.")
        }
        
        return nil
    }
    
    func loadSeries(_ completion: (() -> Void)?)
    {
        globals.isLoading = true
        
        Thread.onMainThread {
            self.activityIndicator.startAnimating()
        }
        
        DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
            Thread.onMainThread {
                self.navigationItem.title = Constants.Titles.Loading_Series
            }
            
            if let seriesDicts = self.loadSeriesDicts() {
                globals.series = self.seriesFromSeriesDicts(seriesDicts)
            }
            
            Thread.onMainThread {
                self.navigationItem.title = Constants.Titles.Loading_Settings
            }
            globals.loadSettings()

            Thread.onMainThread {
                self.navigationItem.title = Constants.Titles.Setting_up_Player
                if (globals.mediaPlayer.playing != nil) {
                    globals.mediaPlayer.playOnLoad = false
                    globals.mediaPlayer.setup(globals.mediaPlayer.playing)
                }

                self.navigationItem.title = Constants.TWU.LONG

                self.seriesSelected = globals.seriesSelected
                self.sermonSelected = globals.seriesSelected?.sermonSelected
                
                self.updateUI()

                completion?()

                self.activityIndicator.stopAnimating()
            }

            globals.isLoading = false
        })
    }
    
    func disableBarButtons()
    {
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func enableBarButtons()
    {
        guard (globals.series != nil) else {
            return
        }

        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @objc func playPauseButtonAction(tap:UITapGestureRecognizer)
    {
        print("play pause button pressed")
        
        if let state = globals.mediaPlayer.state {
            switch state {
            case .playing:
                globals.mediaPlayer.pause()
                
            case .paused:
                if globals.mediaPlayer.url == sermonSelected?.playingURL {
                    addProgressObserver()
                }
                globals.mediaPlayer.play()
                
            case .stopped:
                print("stopped")
                playPause(playPauseButton)
                
            default:
                print("default")
                break
            }
        } else {
            playPause(playPauseButton)
        }
    }
    
    @objc func menuButtonAction(tap:UITapGestureRecognizer)
    {
        print("MTVC menu button pressed")
        
        if !Thread.isMainThread {
            print("NOT MAIN THREAD")
        }

        globals.popoverNavCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.IDENTIFIER.POPOVER_TABLEVIEW_NAV) as? UINavigationController
        
        if let popoverNavCon = globals.popoverNavCon, let popover = popoverNavCon.viewControllers[0] as? PopoverTableViewController {
            popoverNavCon.modalPresentationStyle = .fullScreen
            
            popover.navigationItem.title = "Menu Options"
            
            popover.delegate = self
            
            popover.purpose = .selectingMenu
            
            var strings = [String]()
            
            strings.append("Refresh Media")
            if !globals.showingAbout {
                strings.append("About")
            }
            strings.append("Sorting")
            strings.append("Filtering")
            
            popover.purpose = .selectingMenu
            popover.section.strings = strings
            
            present(popoverNavCon, animated: true, completion: nil)
        }
    }
    
    func addNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.doneSeeking), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.DONE_SEEKING), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.showPlaying), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.SHOW_PLAYING), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.updateUI), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.FAILED_TO_PLAY), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.readyToPlay), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.READY_TO_PLAY), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.updateUI), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.PAUSED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.setupPlayPauseButton), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.UPDATE_PLAY_PAUSE), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.willEnterForeground), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.WILL_ENTER_FORGROUND), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.didBecomeActive), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.DID_BECOME_ACTIVE), object: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        addNotifications()
        
        view.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 0.75)
        
        let menuPressRecognizer = UITapGestureRecognizer(target: self, action: #selector(MediaCollectionViewController.menuButtonAction(tap:)))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)]
        view.addGestureRecognizer(menuPressRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MediaCollectionViewController.playPauseButtonAction(tap:)))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)];
        view.addGestureRecognizer(tapRecognizer)

        collectionView?.allowsSelection = true

        if #available(iOS 10.0, *) {
            collectionView?.isPrefetchingEnabled = false
        } else {
            // Fallback on earlier versions
        }
        
        // globals.series load happens in didBecomeActive
    }
    
    @objc func readyToPlay()
    {
        updateUI()

        preferredFocusView = playPauseButton
    }
    
    @objc func showPlaying()
    {
        guard Thread.isMainThread else {
            return
        }
        
        if let playing = globals.mediaPlayer.playing, seriesSelected?.sermons?.index(of: playing) != nil {
            sermonSelected = playing
            scrollToSermon(sermonSelected, select: true, position: UITableViewScrollPosition.none)
        } else {
            removeProgressObserver()
            if let url = sermonSelected?.playingURL {
                playerURL(url: url)
            }
            preferredFocusView = playPauseButton
        }

        updateUI()
    }
    
    @objc func doneSeeking()
    {
        print("DONE SEEKING")
        
        globals.mediaPlayer.checkPlayToEnd()
    }
    
    @objc func willEnterForeground()
    {
        
    }
    
    @objc func didBecomeActive()
    {
        guard !globals.isLoading, globals.series == nil else {
            return
        }

        loadSeries()
        {
            if globals.series == nil {
                let alert = UIAlertController(title: "No media available.",
                                              message: "Please check your network connection and try again.",
                                              preferredStyle: UIAlertControllerStyle.alert)
                
                let action = UIAlertAction(title: Constants.Okay, style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) -> Void in
                    
                })
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
            } else {
                self.collectionView.reloadData()
                self.scrollToSeries(self.seriesSelected)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        collectionView.remembersLastFocusedIndexPath = true
        
        addNotifications()

        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        scrollToSeries(seriesSelected)

        setNeedsFocusUpdate()
    }
    
    func removeProgressObserver() {
        if globals.mediaPlayer.progressTimerReturn != nil {
            globals.mediaPlayer.player?.removeTimeObserver(globals.mediaPlayer.progressTimerReturn!)
            globals.mediaPlayer.progressTimerReturn = nil
        }
    }
    
    func addProgressObserver()
    {
        removeProgressObserver()
        
        globals.mediaPlayer.progressTimerReturn = globals.mediaPlayer.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.1,Constants.CMTime_Resolution), queue: DispatchQueue.main, using: { [weak self] (CMTime) in
            self?.progressTimer()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        removeProgressObserver()
        removePlayerObserver()
        
        NotificationCenter.default.removeObserver(self)
        
        progressObserver?.invalidate()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
