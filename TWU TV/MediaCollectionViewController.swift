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

class MyTextView : UITextView
{
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        guard context.previouslyFocusedItem != nil else {
            return
        }
        
//        let inset:CGFloat = 10
        
        if context.nextFocusedView == self {
//            frame = frame.inset(by: UIEdgeInsets.init(top: -inset, left: 0, bottom: -2*inset, right: -2*inset))
            backgroundColor = UIColor(displayP3Red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
        } else {
//            frame = frame.inset(by: UIEdgeInsets.init(top: inset, left: 0, bottom: 2*inset, right: 2*inset))
            scrollRangeToVisible(NSMakeRange(0,0))
            backgroundColor = UIColor.clear
        }
    }
}

extension MediaCollectionViewController : UICollectionViewDataSource
{
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in:UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        //return series.count
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return Globals.shared.activeSeries?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        if let cell = cell as? MediaCollectionViewCell {
            // Configure the cell
            
            cell.series = Globals.shared.activeSeries?[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.IDENTIFIER.SERIES_CELL, for: indexPath) as? MediaCollectionViewCell ?? MediaCollectionViewCell()
        
        // Configure the cell
        cell.series = Globals.shared.activeSeries?[indexPath.row]
        
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
        if let cell: MediaCollectionViewCell = collectionView.cellForItem(at: indexPath) as? MediaCollectionViewCell {
            didSelectSeries = true
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
        
        Globals.shared.mediaPlayer.unobserve()
        
        Globals.shared.mediaPlayer.pause()
        
        Globals.shared.searchActive = false
        
        clearView()
        
        disableBarButtons()
        
        // This is ABSOLUTELY ESSENTIAL to reset all of the Media so that things load as if from a cold start.
        Globals.shared.series = nil
        
        collectionView?.reloadData()
        
        loadSeries()
        {
            if Globals.shared.series == nil {
                let alert = UIAlertController(title: "No media available.",
                                              message: "Please check your network connection and try again.",
                                              preferredStyle: UIAlertController.Style.alert)
                
                let action = UIAlertAction(title: Constants.Strings.Okay, style: UIAlertAction.Style.cancel, handler: { (UIAlertAction) -> Void in
                    
                })
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
            } else {
                self.collectionView.reloadData()
                self.scrollToSeries(self.seriesSelected)
            }
        }
    }
    
    func rowClickedAtIndex(_ index: Int, strings: [String]?, purpose:PopoverPurpose)
    {
        guard Thread.isMainThread else {
            return
        }
        
        dismiss(animated: true, completion: {
            guard let string = strings?[index] else {
                return
            }
            
            self.splitViewController?.preferredDisplayMode = .allVisible
            
            switch purpose {
            case .selectingSorting:
                guard (Globals.shared.sorting != string) else {
                    break
                }
                
                Globals.shared.sorting = string
//                self.preferredFocusView = self.collectionView
                self.collectionView.reloadData()
                self.scrollToSeries(self.seriesSelected)
                break
                
            case .selectingFiltering:
                guard (Globals.shared.filter != string) else {
                    break
                }
                
                if (string == Constants.All) {
                    Globals.shared.showing = .all
                    Globals.shared.filter = nil
                } else {
                    Globals.shared.showing = .filtered
                    Globals.shared.filter = string
                }
                
//                self.preferredFocusView = self.collectionView
                self.collectionView.reloadData()
                self.scrollToSeries(self.seriesSelected)
                break
                
            case .selectingMenu:
                switch string {
                case Constants.Strings.Refresh_Media:
                    self.handleRefresh()
                    break
                    
                case "About":
                    Globals.shared.showingAbout = true
                    self.preferredFocusView = nil
                    self.seriesSelected = nil
                    break
                    
                case "Sorting":
                    self.sorting()
                    break
                    
                case "Filtering":
                    self.filtering()
                    break
                    
                default:
                    break
                }
                
            default:
                break
            }
        })
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
        return seriesSelected?.sermons?.count ?? 0
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
        sermonSelected = seriesSelected?.sermons?[indexPath.row]
        
        if (sermonSelected?.series == seriesSelected) && (Globals.shared.mediaPlayer.url == sermonSelected?.playingURL) {
            addProgressObserver()
        }
        
        setupPlayPauseButton()
        setupSpinner()
        setupProgressView()

//        if sermonSelected != nil {
//            playPauseButton.isEnabled = true
//            preferredFocusView = playPauseButton
//        }
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
//            guard (preferredFocusView != nil) else {
//                return
//            }
            
            Thread.onMainThread {
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
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
        Globals.shared.mediaPlayer.seek(to: 0)
    }
    
    @IBOutlet weak var skipBackwardsButton: UIButton!
    {
        didSet {
            skipBackwardsButton.setTitle(Constants.FA.REWIND)
        }
    }
    @IBAction func skipBackwards(_ sender: UIButton)
    {
        guard let currentTime = Globals.shared.mediaPlayer.currentTime else {
            return
        }
        
        Globals.shared.mediaPlayer.seek(to: currentTime.seconds - Constants.INTERVALS.SKIP_TIME)
    }
    
    @IBOutlet weak var skipForwardsButton: UIButton!
    {
        didSet {
            skipForwardsButton.setTitle(Constants.FA.FF)
        }
    }
    @IBAction func skipForwards(_ sender: UIButton)
    {
        guard let currentTime = Globals.shared.mediaPlayer.currentTime else {
            return
        }
        
        Globals.shared.mediaPlayer.seek(to: currentTime.seconds + Constants.INTERVALS.SKIP_TIME)
    }
    
    @IBOutlet weak var playPauseButton: UIButton!
    {
        didSet {
            
        }
    }
    
    @IBAction func playPause(_ sender: UIButton)
    {
        guard let state = Globals.shared.mediaPlayer.state, Globals.shared.mediaPlayer.playing == sermonSelected, Globals.shared.mediaPlayer.player != nil else {
            playNewSermon(sermonSelected)
            return
        }
        
        switch state {
        case .none:
//            print("none")
            break
            
        case .playing:
//            print("playing")
            Globals.shared.mediaPlayer.pause()
            
            setupPlayPauseButton()
            
            if spinner.isAnimating {
                spinner.stopAnimating()
                spinner.isHidden = true
            }
            break
            
        case .paused:
//            print("paused")
            if Globals.shared.mediaPlayer.loaded && (Globals.shared.mediaPlayer.url == sermonSelected?.playingURL) {
                addProgressObserver()
                playCurrentSermon(sermonSelected)
            } else {
                playNewSermon(sermonSelected)
            }
            break
            
        case .stopped:
//            print("stopped")
            break
            
        case .seekingForward:
//            print("seekingForward")
            Globals.shared.mediaPlayer.pause()
            break
            
        case .seekingBackward:
//            print("seekingBackward")
            Globals.shared.mediaPlayer.pause()
            break
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var elapsed: UILabel!
    @IBOutlet weak var remaining: UILabel!
    
    @IBOutlet weak var seriesArt: UIImageView!
    
    @IBOutlet weak var seriesLabel: UILabel!
    {
        didSet {
            seriesLabel.text = nil
        }
    }
    
    @IBOutlet weak var seriesDescription: UITextView!
    {
        didSet {
            seriesDescription.isSelectable = true
            seriesDescription.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        }
    }
    
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
    
    var observer: NSKeyValueObservation?
    
//    var observerActive = false

//    override func observeValue(forKeyPath keyPath: String?,
//                               of object: Any?,
//                               change: [NSKeyValueChangeKey : Any]?,
//                               context: UnsafeMutableRawPointer?) {
//        // Only handle observations for the playerItemContext
//        //        guard context == &PlayerContext else {
//        //            super.observeValue(forKeyPath: keyPath,
//        //                               of: object,
//        //                               change: change,
//        //                               context: nil)
//        //            return
//        //        }
//
//        if keyPath == #keyPath(AVPlayerItem.status) {
//            let status: AVPlayerItem.Status
//
//            // Get the status change from the change dictionary
//            if let statusNumber = change?[.newKey] as? NSNumber, let itemStatus = AVPlayerItem.Status(rawValue: statusNumber.intValue) {
//                status = itemStatus
//            } else {
//                status = .unknown
//            }
//
//            // Switch over the status
//            switch status {
//            case .readyToPlay:
//                // Player item is ready to play.
//
//                if let currentTime = sermonSelected?.currentTime, let timeNow = Double(currentTime), let length = player?.currentItem?.duration.seconds {
//                    let progress = timeNow / length
//
//                    progressView.progress = Float(progress)
//                    setTimes(timeNow: timeNow,length: length)
//
//                    avPlayerSpinner.stopAnimating()
//                    avPlayerSpinner.isHidden = true
//
//                    controlView.isHidden = false
//                    elapsed.isHidden = false
//                    remaining.isHidden = false
//                    progressView.isHidden = false
//                }
//
//                playPauseButton.isEnabled = true
//                preferredFocusView = playPauseButton
////                if preferredFocusView == tableView {
////                    preferredFocusView = playPauseButton
////                }
//                break
//
//            case .failed:
//                // Player item failed. See error.
//                break
//
//            case .unknown:
//                // Player item is not yet ready.
//                break
//
//            @unknown default:
//                break
//            }
//        }
//    }
    
    var player:AVPlayer?
    
    func removePlayerObserver()
    {
        observer?.invalidate()
        
//        // observerActive and this function would not be needed if we cache as we would assume EVERY AVPlayer in the cache has an observer => must remove them prior to dealloc.
//
//        if observerActive {
//            player?.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: nil) // &PlayerContext
//            observerActive = false
//        }
    }
    
    func addPlayerObserver()
    {
        observer = player?.currentItem?.observe(\.status, options:[.new]) { [weak self] (currentItem, change) in
            switch currentItem.status {
            case .readyToPlay:
                // Player item is ready to play.
                
                if let currentTime = self?.sermonSelected?.currentTime, let timeNow = Double(currentTime), let length = self?.player?.currentItem?.duration.seconds {
                    let progress = timeNow / length
                    
                    self?.progressView.progress = Float(progress)
                    self?.setTimes(timeNow: timeNow,length: length)
                    
                    self?.avPlayerSpinner.stopAnimating()
                    self?.avPlayerSpinner.isHidden = true
                    
                    self?.controlView.isHidden = false
                    self?.elapsed.isHidden = false
                    self?.remaining.isHidden = false
                    self?.progressView.isHidden = false
                }
                
                self?.playPauseButton.isEnabled = true
                self?.preferredFocusView = self?.playPauseButton
                
//                if preferredFocusView == tableView {
//                    preferredFocusView = playPauseButton
//                }
                break
                
            case .failed:
                // Player item failed. See error.
                break
                
            case .unknown:
                // Player item is not yet ready.
                break
                
            @unknown default:
                break
            }
        }
            
//        player?.currentItem?.addObserver(self,
//                                         forKeyPath: #keyPath(AVPlayerItem.status),
//                                         options: [.old, .new],
//                                         context: nil) // &PlayerContext
//        observerActive = true
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
    
    var didSelectSeries = false
    
    var seriesSelected:Series?
    {
        willSet {
            
        }
        didSet {
            guard let seriesSelected = seriesSelected else {
                sermonSelected = nil
                didSelectSeries = false
//                seriesDescription.isSelectable = false
//                seriesDescription.panGestureRecognizer.allowedTouchTypes = []
                return
            }
            
//            seriesDescription.isSelectable = true
//            seriesDescription.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]

            Globals.shared.showingAbout = false
            
            avPlayerSpinner.stopAnimating()
            
            sermonSelected = seriesSelected.sermonSelected

            if (sermonSelected?.series == seriesSelected) && (Globals.shared.mediaPlayer.url == sermonSelected?.playingURL) {
                addProgressObserver()
            } else {
                Globals.shared.mediaPlayer.stop()
            }

            let defaults = UserDefaults.standard
            defaults.set(seriesSelected.name, forKey: Constants.SETTINGS.SELECTED.SERIES)
            defaults.synchronize()

            tableView.reloadData()

            if sermonSelected != nil {
                selectSermon(sermonSelected)
            } else {
                preferredFocusView = tableView
            }

            updateUI()
            
            didSelectSeries = false
        }
    }
    
    var sermonSelected:Sermon?
    {
        willSet {
            
        }
        didSet {
            sermonLabel.text = sermonSelected?.partString
            
            sermonLabel.isHidden = sermonSelected?.partString == nil
            
            seriesSelected?.sermonSelected = sermonSelected
            
            guard sermonSelected != nil else {
                updateUI()
                return
            }
            
            guard Globals.shared.reachability.isReachable else {
                updateUI()
                return
            }

            if sermonSelected != Globals.shared.mediaPlayer.playing {
                Globals.shared.mediaPlayer.stop()
                removeProgressObserver()
                playerURL(url: sermonSelected?.playingURL)
            } else {
                if !didSelectSeries {
                    preferredFocusView = playPauseButton
                }

                removePlayerObserver()
                addProgressObserver()
            }

//            if (sermonSelected != oldValue) || !Globals.shared.mediaPlayer.loaded {
//                if sermonSelected != Globals.shared.mediaPlayer.playing, let playingURL = sermonSelected?.playingURL {
//                    Globals.shared.mediaPlayer.stop()
//                    removeProgressObserver()
//                    playerURL(url: playingURL)
//                } else {
//                    if !didSelectSeries {
//                        preferredFocusView = playPauseButton
//                    }
//
//                    removePlayerObserver()
//                    addProgressObserver()
//                }
//            } else {
//                if !didSelectSeries {
//                    preferredFocusView = playPauseButton
//                }
//            }
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
        
        if (sermonSelected == Globals.shared.mediaPlayer.playing) || (Globals.shared.mediaPlayer.playing == nil) {
            playPauseButton.isEnabled = Globals.shared.mediaPlayer.loaded || Globals.shared.mediaPlayer.loadFailed

            if let state = Globals.shared.mediaPlayer.state {
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
            
            restartButton.isEnabled = Globals.shared.mediaPlayer.loaded
            skipBackwardsButton.isEnabled = Globals.shared.mediaPlayer.loaded
            skipForwardsButton.isEnabled = Globals.shared.mediaPlayer.loaded
            
            restartButton.isHidden = false
            skipBackwardsButton.isHidden = false
            skipForwardsButton.isHidden = false
        } else {
            playPauseButton.isEnabled = false
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
            tableView.isHidden = true

            logo.isHidden = Globals.shared.showingAbout
            
            backgroundLogo.isHidden = !logo.isHidden
            tomPennington.isHidden = !logo.isHidden
            
            let description = "Tom Pennington is Pastor-Teacher at Countryside Bible Church in Southlake, TX.<br/>His pulpit ministry provides the material for The Word Unleashed.\n\nOur ministry is founded upon one principle: God has given you every spiritual resource you need to grow in Jesus Christ, and you find those resources in His all-sufficient Word (2 Pet. 1:3). That's why Tom embraces expository preaching - an approach that seeks to understand what the original authors of Scripture meant, rather than an approach that reads our own meaning into it. If that's what you've been looking for, you've come to the right place.  It's our prayer that the transforming power of God's Word be unleashed in your life.\n\nP.O. Box 96077<br>Southlake, Texas 76092<br/>www.thewordunleashed.org<br/>listeners@thewordunleashed.org<br/>877-577-WORD (9673)"
            
            // seriesLabel
            seriesDescription.text = description.replacingOccurrences(of: "<br/>", with: "\n").replacingOccurrences(of: "<br>", with: "\n")
            seriesDescription.isHidden = false
            
            DispatchQueue.global(qos: .background).async {
                Thread.onMainThread {
                    self.preferredFocusView = self.seriesDescription
                }
            }
            return
        }
        
        logo.isHidden = true
        tomPennington.isHidden = true

        backgroundLogo.isHidden = false

        // seriesLabel
        seriesDescription.text = seriesSelected.text?.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\n\n", with: "\n").replacingOccurrences(of: "\n", with: "\n\n").replacingOccurrences(of: "\n\n\n", with: "\n").replacingOccurrences(of: "?۪", with: "'").replacingOccurrences(of: " ??? What", with: ", what").replacingOccurrences(of: " ???", with: ",").replacingOccurrences(of: "&rsquo;", with: "’").replacingOccurrences(of: "&mdash;", with: "—").replacingOccurrences(of: "&ndash;", with: "—").replacingOccurrences(of: "sanctification–", with: "sanctification")
        
        // Should be an opQueue
        DispatchQueue.global(qos: .background).async { () -> Void in
            seriesSelected.coverArt?.load(success: { [weak self] (image:UIImage?) in
                Thread.onMainThread {
                    if self?.seriesSelected == seriesSelected {
                        self?.seriesArt.image = image
                    }
                }
            }, failure: { [weak self] in
                Thread.onMainThread {
                    if self?.seriesSelected == seriesSelected {
                        self?.seriesArt.image = UIImage(named: "iTunesArtwork") // twu_logo_circle_r
                    }
                }
            })
        }
        
        tableView.isHidden = false
        
        seriesArt.isHidden = false
        seriesDescription.isHidden = false
    }
    
    func setupTitle()
    {
        guard Thread.isMainThread else {
            return
        }
        
        if (!Globals.shared.isLoading) {
            self.navigationItem.title = Constants.TWU.LONG
        }
        
        self.navigationItem.title = seriesSelected?.title
    }
    
    func setupSpinner()
    {
        guard Thread.isMainThread else {
            return
        }
        
        guard (sermonSelected != nil) && (sermonSelected == Globals.shared.mediaPlayer.playing) else {
            if spinner.isAnimating {
                spinner.stopAnimating()
                spinner.isHidden = true
            }
            return
        }
        
        if !Globals.shared.mediaPlayer.loaded && !Globals.shared.mediaPlayer.loadFailed {
            if !spinner.isAnimating {
                spinner.isHidden = false
                spinner.startAnimating()
            }
        } else {
            if Globals.shared.mediaPlayer.isPaused {
                if spinner.isAnimating {
                    spinner.isHidden = true
                    spinner.stopAnimating()
                }
            }
            
            if Globals.shared.mediaPlayer.isPlaying {
                if let currentTime = Globals.shared.mediaPlayer.playing?.currentTime, Globals.shared.mediaPlayer.currentTime?.seconds > Double(currentTime) {
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
        
//        collectionView.reloadData()
    }
    
    func scrollToSermon(_ sermon:Sermon?,select:Bool,position:UITableView.ScrollPosition)
    {
        guard Thread.isMainThread else {
            return
        }
        
        guard (sermon != nil) else {
            return
        }
        
        var indexPath = IndexPath(row: 0, section: 0)
        
        if (seriesSelected?.sermons?.count > 1) {
            if let sermon = sermon, let sermonIndex = seriesSelected?.sermons?.firstIndex(of: sermon) {
                //                    print("\(sermonIndex)")
                indexPath = IndexPath(row: sermonIndex, section: 0)
            }
        }
        
        if (select) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: position)
        }
        
        tableView.scrollToRow(at: indexPath, at: position, animated: false)
        
        preferredFocusView = tableView.cellForRow(at: indexPath)
    }

    fileprivate func setTimes(timeNow:Double, length:Double)
    {
        guard !timeNow.isNaN, !timeNow.isInfinite else {
            return
        }
        
        guard !length.isNaN, !length.isInfinite else {
            return
        }
        
        self.elapsed.text = timeNow.secondsToHMS
        
        let timeRemaining = max(length - timeNow,0)
        
        self.remaining.text = timeRemaining.secondsToHMS
    }
    
    fileprivate func setProgressAndTimesToAudio()
    {
        guard Thread.isMainThread else {
            return
        }
        
        guard let length = Globals.shared.mediaPlayer.duration?.seconds else {
            return
        }
        
        guard length > 0 else {
            return
        }
        
        guard let currentTime = Globals.shared.mediaPlayer.playing?.currentTime else {
            return
        }
        
        guard let playingCurrentTime = Double(currentTime) else {
            return
        }
        
        guard let playerCurrentTime = Globals.shared.mediaPlayer.currentTime?.seconds else {
            return
        }
        
        guard let state = Globals.shared.mediaPlayer.state else {
            return
        }
        
        var progress = -1.0
        
        if (length > 0) {
            switch state {
            case .playing:
                if playingCurrentTime >= 0, let duration = Globals.shared.mediaPlayer.duration, playerCurrentTime <= duration.seconds {
                    progress = playerCurrentTime / length
                    
                    if Globals.shared.mediaPlayer.loaded {
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
        
        // Without this background/main dispatching there isn't time to scroll correctly after a reload.
        // For UI
        DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
            Thread.onMainThread {
                self.scrollToSermon(sermon, select: true, position: UITableView.ScrollPosition.none)
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
        
        guard (sermonSelected == Globals.shared.mediaPlayer.playing) else {
            return
        }
        
        guard let state = Globals.shared.mediaPlayer.state else {
            return
        }
        
        guard (Globals.shared.mediaPlayer.startTime != nil) else {
            return
        }
        
        guard (Globals.shared.mediaPlayer.currentTime != nil) else {
            return
        }
        
        setupPlayPauseButton()
        
        if (!Globals.shared.mediaPlayer.loaded) {
            if (!spinner.isAnimating) {
                spinner.isHidden = false
                spinner.startAnimating()
            }
        }
        
        switch state {
        case .none:
//            print("none")
            break
            
        case .playing:
//            print("playing")
            setProgressAndTimesToAudio()
            
            if (!Globals.shared.mediaPlayer.loaded) {
                if (!spinner.isAnimating) {
                    spinner.isHidden = false
                    spinner.startAnimating()
                }
            } else {
                if Globals.shared.mediaPlayer.rate > 0, let startTime = Globals.shared.mediaPlayer.startTime, Globals.shared.mediaPlayer.currentTime?.seconds > Double(startTime) {
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
//            print("paused")
            
            if Globals.shared.mediaPlayer.loaded {
                setProgressAndTimesToAudio()
            }
            
            if Globals.shared.mediaPlayer.loaded || Globals.shared.mediaPlayer.loadFailed {
                if spinner.isAnimating {
                    spinner.stopAnimating()
                    spinner.isHidden = true
                }
            }
            break
            
        case .stopped:
//            print("stopped")
            break
            
        case .seekingForward:
//            print("seekingForward")
            if !spinner.isAnimating {
                spinner.isHidden = false
                spinner.startAnimating()
            }
            break
            
        case .seekingBackward:
//            print("seekingBackward")
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
                NSLog("playPause Globals.shared.mediaPlayer.currentTime and Globals.shared.player.playing!.currentTime reset to 0!")
                Globals.shared.mediaPlayer.playing?.currentTime = Constants.ZERO
                seekToTime = CMTimeMakeWithSeconds(0,preferredTimescale: Constants.CMTime_Resolution)
                sermon.atEnd = false
            } else {
                if let currentTime = sermon.currentTime, let num = Double(currentTime) {
                    seekToTime = CMTimeMakeWithSeconds(num,preferredTimescale: Constants.CMTime_Resolution)
                }
            }
        } else {
            NSLog("playPause selectedMediaItem has NO currentTime!")
            sermon.currentTime = Constants.ZERO
            seekToTime = CMTimeMakeWithSeconds(0,preferredTimescale: Constants.CMTime_Resolution)
        }
        
        if let seekToTime = seekToTime {
            let loadedTimeRanges = (Globals.shared.mediaPlayer.player?.currentItem?.loadedTimeRanges as? [CMTimeRange])?.filter({ (cmTimeRange:CMTimeRange) -> Bool in
                return cmTimeRange.containsTime(seekToTime)
            })
            
            let seekableTimeRanges = (Globals.shared.mediaPlayer.player?.currentItem?.seekableTimeRanges as? [CMTimeRange])?.filter({ (cmTimeRange:CMTimeRange) -> Bool in
                return cmTimeRange.containsTime(seekToTime)
            })
            
            if (loadedTimeRanges != nil) || (seekableTimeRanges != nil) {
                Globals.shared.mediaPlayer.seek(to: seekToTime.seconds)
                
                Globals.shared.mediaPlayer.play()
                
                setupPlayPauseButton()
            } else {
                playNewSermon(sermon)
            }
        }
    }
    
    fileprivate func reloadCurrentSermon(_ sermon:Sermon?)
    {
        //This guarantees a fresh start.
        Globals.shared.mediaPlayer.playOnLoad = true
        Globals.shared.mediaPlayer.reload(sermon)
        addProgressObserver()
        setupPlayPauseButton()
    }
    
    fileprivate func playNewSermon(_ sermon:Sermon?)
    {
        Globals.shared.mediaPlayer.pauseIfPlaying()
        
        guard (sermon != nil) else {
            return
        }
        
        if (!spinner.isAnimating) {
            spinner.isHidden = false
            spinner.startAnimating()
        }
        
        Globals.shared.mediaPlayer.playing = sermon
        
        removeProgressObserver()
        
        //This guarantees a fresh start.
        Globals.shared.mediaPlayer.playOnLoad = true
        Globals.shared.mediaPlayer.setup(sermon)
        
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
        
        if (Globals.shared.mediaPlayer.playing != nil) && (Globals.shared.mediaPlayer.playing == sermonSelected) {
            if !Globals.shared.mediaPlayer.loadFailed {
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
            popover.section.strings = Globals.shared.series?.books
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
        
        guard let index = Globals.shared.activeSeries?.firstIndex(of: series) else {
//            preferredFocusView = playPauseButton
            return
        }
        
        let indexPath = IndexPath(item: index, section: 0)
        
        self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.left, animated: false)
        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
        
//        preferredFocusView = collectionView.cellForItem(at: indexPath)
    }
    
    func setupViews()
    {
        collectionView.reloadData()
        
        enableBarButtons()
        
        setupTitle()
    }
    
//    func seriesFromSeriesDicts(_ seriesDicts:[[String:Any]]?) -> [Series]?
//    {
//        return seriesDicts?.compactMap({ (seriesDict:[String:Any]) -> Series? in
//            let series = Series(seriesDict: seriesDict)
//            return series.sermons?.count > 0 ? series : nil // .show != 0
//        })
////            .map({ (seriesDict:[String:Any]) -> Series in
////            let series = Series(seriesDict: seriesDict)
////
////            // Allows the visible cells to load first/faster, I think because tvOS isn't as well-threaded as iOS.
//////            if series.coverArtURL?.exists == true {
//////                series.coverArt?.fetch.fill()
////////                DispatchQueue.global(qos: .background).async { () -> Void in
////////                    // This blocks.
////////                    series.coverArt.load()
////////                }
//////            }
////
////            // Too slow, loads everything, and because it isn't sync'd through a Fetch may not speed anything up.
//////            DispatchQueue.global(qos: .background).async { () -> Void in
//////                series.coverArt { (image:UIImage?) in
//////                    guard let name = series.coverArtURL?.lastPathComponent else {
//////                        return
//////                    }
//////
//////                    Globals.shared.images[name] = image
//////                }
//////            }
////
////            return series
////        })
//    }
    
//    func jsonFromFileSystem(filename:String?) -> Any?
//    {
//        guard let filename = filename else {
//            return nil
//        }
//
//        guard let jsonFileSystemURL = filename.fileSystemURL else {
//            return nil
//        }
//
//        guard let data = jsonFileSystemURL.data else {
//            return nil
//        }
//
//        return data.json
//
////        do {
////            let json = try JSONSerialization.jsonObject(with: data, options: [])
////            return json
////        } catch let error {
////            NSLog(error.localizedDescription)
////            return nil
////        }
//    }
    
    private lazy var jsonQueue:OperationQueue! = {
        let operationQueue = OperationQueue()
        operationQueue.name = "JSON"
        operationQueue.qualityOfService = .background
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    
    deinit {
        jsonQueue.cancelAllOperations()
        operationQueue.cancelAllOperations()
    }
    
    func jsonFromURL(urlString:String?,filename:String?) -> Any?
    {
        // THIS STOPS THE FILESYSTEM CALL BELOW!
//        guard Globals.shared.reachability.isReachable else {
//            return nil
//        }
        
//        guard let json = filename?.fileSystemURL?.data?.json else {
//            // BLOCKS
//            let data = urlString?.url?.data
//
//            jsonQueue.addOperation {
//                data?.save(to: filename?.fileSystemURL)
//            }
//
//            return data?.json
//        }
        
        guard Globals.shared.reachability.isReachable else {
            return filename?.fileSystemURL?.data?.json
        }
        
        guard let data = urlString?.url?.data else {
            return filename?.fileSystemURL?.data?.json
        }
        
        jsonQueue.addOperation {
            data.save(to: filename?.fileSystemURL)
        }
        
        return data.json
        
//        jsonQueue.addOperation {
//            urlString?.url?.data?.save(to: filename?.fileSystemURL)
//        }
//
//        return json
    }
    
//    func jsonFromURL(urlString:String?,filename:String?) -> Any?
//    {
//        guard Globals.shared.reachability.isReachable, urlString?.url != nil else {
//            return filename?.fileSystemURL?.data?.json
//        }
//
//        if Globals.shared.format == Constants.JSON.SERIES_JSON, let json = jsonFromFileSystem(filename: filename) {
//            operationQueue.addOperation {
//                url.data?.save(to: filename?.fileSystemURL)
//
////                do {
////                    let data = try Data(contentsOf: url)
////                    print("able to read json from the URL.")
////
////                    if let filename = filename {
////                        do {
////                            if let jsonFileSystemURL = cachesURL?.appendingPathComponent(filename) {
////                                try data.write(to: jsonFileSystemURL)
////                            }
////                            print("able to write json to the file system")
////                        } catch let error {
////                            print("unable to write json to the file system.")
////                            NSLog(error.localizedDescription)
////                        }
////                    }
////                } catch let error {
////                    NSLog(error.localizedDescription)
////                }
//            }
//
//            Globals.shared.format = Constants.JSON.SERIES_JSON
//            return json
//        } else {
//            guard let data = url.data else {
//                return jsonFromFileSystem(filename: filename)
//            }
//
//            if let fileSystemURL = url.fileSystemURL {
//                data.save(to: fileSystemURL)
//            }
//
//            return data.json ?? jsonFromFileSystem(filename: filename)
//
////            do {
////                let data = try Data(contentsOf: url)
////                print("able to read json from the URL.")
////
////                do {
////                    let json = try JSONSerialization.jsonObject(with: data, options: [])
////
////                    if let filename = filename {
////                        do {
////                            if let jsonFileSystemURL = cachesURL?.appendingPathComponent(filename) {
////                                try data.write(to: jsonFileSystemURL)
////                            }
////                            print("able to write json to the file system")
////                        } catch let error {
////                            print("unable to write json to the file system.")
////
////                            NSLog(error.localizedDescription)
////                        }
////                    }
////
////                    Globals.shared.format = Constants.JSON.SERIES_JSON
////                    return json
////                } catch let error {
////                    NSLog(error.localizedDescription)
////                    return jsonFromFileSystem(filename: filename)
////                }
////            } catch let error {
////                NSLog(error.localizedDescription)
////                return jsonFromFileSystem(filename: filename)
////            }
//        }
//    }
    
    func loadSeriesDicts() -> [[String:Any]]?
    {
        guard let json = jsonFromURL(urlString: Constants.JSON.SERIES_JSON,filename: Constants.JSON.SERIES_JSON.url?.lastPathComponent) as? [String:Any] else {
            print("could not get json from file, make sure that file contains valid json.")
            return nil
        }
        
        if let meta = json[Constants.JSON.KEYS.META] as? [String:Any] {
            Globals.shared.meta = meta
        }
        
        var seriesDicts = [[String:Any]]()
        
        let key = Constants.JSON.KEYS.DATA

//        switch Constants.JSON.URL {
//        case Constants.JSON.URLS.MEDIALIST_PHP:
//            key = Constants.JSON.KEYS.SERIES
//            break
//
//        default:
//            key = Constants.JSON.KEYS.DATA
//            break
//        }
        
        if let series = json[key] as? [[String:Any]] {
            for i in 0..<series.count {
                var dict = [String:Any]()
                
                for (key,value) in series[i] {
                    dict["\(key)"] = value  // "\(value)".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                }
                
                seriesDicts.append(dict)
            }
        }
        
        return seriesDicts.count > 0 ? seriesDicts : nil
    }
    
    private lazy var operationQueue : OperationQueue! = {
        let operationQueue = OperationQueue()
        operationQueue.name = "MCVC:" + UUID().uuidString
        operationQueue.qualityOfService = .userInitiated
        operationQueue.maxConcurrentOperationCount = 1 // Slides and Notes
        return operationQueue
    }()
    
    func loadSeries(_ completion: (() -> Void)?)
    {
        Globals.shared.isLoading = true
        
        Thread.onMainThread {
            self.activityIndicator.startAnimating()
        }
        
        operationQueue.cancelAllOperations()
        
//        operationQueue.waitUntilAllOperationsAreFinished()
        
        let operation = CancellableOperation { (test:(()->(Bool))?) in
//        DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
            Thread.onMainThread {
                self.navigationItem.title = Constants.Titles.Loading_Series
            }
            
            if let seriesDicts = self.loadSeriesDicts() {
                let upgradedImages = UserDefaults.standard.bool(forKey: "UPGRADED IMAGES")
                
                Globals.shared.series = seriesDicts.compactMap({ (seriesDict:[String:Any]) -> Series? in
                    let series = Series(seriesDict: seriesDict)
                    
                    if !upgradedImages {
                        series.coverArt?.fileSystemURL?.delete()
                    }
                
                    return series.sermons?.count > 0 ? series : nil // .show != 0
                })
                
                UserDefaults.standard.set(true, forKey: "UPGRADED IMAGES")
            }

            Thread.onMainThread {
                self.navigationItem.title = Constants.Titles.Loading_Settings
            }
            Globals.shared.loadSettings()

            Thread.onMainThread {
                self.navigationItem.title = Constants.Titles.Setting_up_Player
                if (Globals.shared.mediaPlayer.playing != nil) {
                    Globals.shared.mediaPlayer.playOnLoad = false
                    Globals.shared.mediaPlayer.setup(Globals.shared.mediaPlayer.playing)
                }

                self.navigationItem.title = Constants.TWU.LONG

                self.seriesSelected = Globals.shared.seriesSelected
                self.sermonSelected = Globals.shared.seriesSelected?.sermonSelected
                
                self.updateUI()

                completion?()

                self.activityIndicator.stopAnimating()
            }

            Globals.shared.isLoading = false
        }
        
        operationQueue.addOperation(operation)
    }
    
    func disableBarButtons()
    {
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func enableBarButtons()
    {
        guard (Globals.shared.series != nil) else {
            return
        }

        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @objc func playPauseButtonAction(tap:UITapGestureRecognizer)
    {
        print("play pause button pressed")
        
        if let state = Globals.shared.mediaPlayer.state {
            switch state {
            case .playing:
                Globals.shared.mediaPlayer.pause()
                
            case .paused:
                if Globals.shared.mediaPlayer.url == sermonSelected?.playingURL {
                    addProgressObserver()
                }
                Globals.shared.mediaPlayer.play()
                
            case .stopped:
//                print("stopped")
                playPause(playPauseButton)
                
            default:
//                print("default")
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

        Globals.shared.popoverNavCon = self.storyboard?.instantiateViewController(withIdentifier: Constants.IDENTIFIER.POPOVER_TABLEVIEW_NAV) as? UINavigationController
        
        if let popoverNavCon = Globals.shared.popoverNavCon, let popover = popoverNavCon.viewControllers[0] as? PopoverTableViewController {
            popoverNavCon.modalPresentationStyle = .fullScreen
            
            popover.navigationItem.title = Constants.Strings.Menu_Options
            
            popover.delegate = self
            
            popover.purpose = .selectingMenu
            
            var strings = [String]()
            
            if !Globals.shared.showingAbout {
                strings.append(Constants.Strings.About)
            }
            strings.append(Constants.Strings.Sorting)
            strings.append(Constants.Strings.Filtering)
            strings.append(Constants.Strings.Refresh_Media)

            popover.purpose = .selectingMenu
            popover.section.strings = strings
            
            present(popoverNavCon, animated: true, completion: nil)
        }
    }
    
    func addNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(doneSeeking), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.DONE_SEEKING), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showPlaying), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.SHOW_PLAYING), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.FAILED_TO_PLAY), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readyToPlay), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.READY_TO_PLAY), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.PAUSED), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupPlayPauseButton), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.UPDATE_PLAY_PAUSE), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        addNotifications()
        
        view.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 0.75)
        
        let menuPressRecognizer = UITapGestureRecognizer(target: self, action: #selector(menuButtonAction(tap:)))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        view.addGestureRecognizer(menuPressRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(playPauseButtonAction(tap:)))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)];
        view.addGestureRecognizer(tapRecognizer)

        collectionView?.allowsSelection = true

//        if #available(iOS 10.0, *) {
//            collectionView?.isPrefetchingEnabled = false
//        } else {
//            // Fallback on earlier versions
//        }
    }
    
    @objc func readyToPlay()
    {
        updateUI()

//        preferredFocusView = playPauseButton
    }
    
    @objc func showPlaying()
    {
        guard Thread.isMainThread else {
            return
        }
        
        if let playing = Globals.shared.mediaPlayer.playing, seriesSelected?.sermons?.firstIndex(of: playing) != nil {
            sermonSelected = playing
            scrollToSermon(sermonSelected, select: true, position: UITableView.ScrollPosition.none)
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
        
        Globals.shared.mediaPlayer.checkPlayToEnd()
    }
    
    @objc func willEnterForeground()
    {
        
    }
    
    @objc func didBecomeActive()
    {
        guard !Globals.shared.isLoading, Globals.shared.series == nil else {
            return
        }

        loadSeries()
        {
            if Globals.shared.series == nil {
                let alert = UIAlertController(title: "No media available.",
                                              message: "Please check your network connection and try again.",
                                              preferredStyle: UIAlertController.Style.alert)
                
                let action = UIAlertAction(title: Constants.Strings.Okay, style: UIAlertAction.Style.cancel, handler: { (UIAlertAction) -> Void in
                    
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
        
//        collectionView.remembersLastFocusedIndexPath = true
        
        addNotifications()

        updateUI()

        collectionView.reloadData()
        scrollToSeries(self.seriesSelected)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        setNeedsFocusUpdate()
    }
    
    func removeProgressObserver()
    {
        if Globals.shared.mediaPlayer.progressTimerReturn != nil {
            Globals.shared.mediaPlayer.player?.removeTimeObserver(Globals.shared.mediaPlayer.progressTimerReturn!)
            Globals.shared.mediaPlayer.progressTimerReturn = nil
        }
    }
    
    func addProgressObserver()
    {
        removeProgressObserver()
        
        Globals.shared.mediaPlayer.progressTimerReturn = Globals.shared.mediaPlayer.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.1,preferredTimescale: Constants.CMTime_Resolution), queue: DispatchQueue.main, using: { [weak self] (CMTime) in
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
