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

//extension MediaCollectionViewController : UIAdaptivePresentationControllerDelegate
//{
//    // MARK: UIAdaptivePresentationControllerDelegate
//    
//    // Specifically for Plus size iPhones.
//    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
//    {
//        return UIModalPresentationStyle.none
//    }
//    
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        return UIModalPresentationStyle.none
//    }
//}

//extension MediaCollectionViewController : UISplitViewControllerDelegate
//{
//    // MARK: UISplitViewControllerDelegate
//    
//}

extension MediaCollectionViewController : UICollectionViewDataSource
{
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in:UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        //return series.count
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        //return series[section].count
        return globals.activeSeries != nil ? globals.activeSeries!.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.IDENTIFIER.SERIES_CELL, for: indexPath) as! MediaCollectionViewCell
        
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
    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        //        print("didDeselect")
//        
//        //        if let cell: MediaCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as? MediaCollectionViewCell {
//        //
//        //        } else {
//        //
//        //        }
//    }
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     */
//    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
//        //        print("shouldHighlight")
//        return true
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        //        print("Highlighted")
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
//        //        print("Unhighlighted")
//    }
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     */
//    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        //        print("shouldSelect")
//        return true
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        //        print("shouldDeselect")
//        return true
//    }
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
     return false
     }
     
     override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
     return false
     }
     
     override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
     
     }
     */
}

//extension MediaCollectionViewController : UIPopoverPresentationControllerDelegate
//{
//    // MARK: UIPopoverPresentationControllerDelegate
//    
//}

extension MediaCollectionViewController : PopoverTableViewControllerDelegate
{
    // MARK: PopoverTableViewControllerDelegate

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
            if (globals.filter != string) {
                if (string == Constants.All) {
                    globals.showing = .all
                    globals.filter = nil
                } else {
                    globals.showing = .filtered
                    globals.filter = string
                }
                
                self.collectionView.reloadData()

                scrollToSeries(seriesSelected)

//                if globals.activeSeries != nil {
//                    let indexPath = IndexPath(item:0,section:0)
//                    collectionView.scrollToItem(at: indexPath,at:UICollectionViewScrollPosition.centeredHorizontally, animated: true)
//                }
            }
            break
            
        case .selectingMenu:
            globals.showingAbout = false

            switch string {
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
        if (seriesSelected != nil) {
            return seriesSelected!.show
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

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //        if let cell = seriesSermons.cellForRowAtIndexPath(indexPath) as? MediaTableViewCell {
        //
        //        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sermonSelected = seriesSelected?.sermons?[(indexPath as NSIndexPath).row]

        if (sermonSelected?.series == seriesSelected) && (globals.mediaPlayer.url == sermonSelected?.playingURL) {
            addSliderObserver()
        }
        
        updateUI()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.IDENTIFIER.SERMON_CELL, for: indexPath) as! MediaTableViewCell
        
        // Configure the cell...
//        cell.row = (indexPath as NSIndexPath).row
        print(indexPath.row)
        if indexPath.row < seriesSelected?.sermons?.count {
            cell.sermon = seriesSelected?.sermons?[indexPath.row]
        }
//        cell.vc = self
        
        return cell
    }

//    func tableView(_ tableView: UITableView, shouldSelectRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    
//    fileprivate func addEndObserver() {
//        if (globals.mediaPlayer.player != nil) && (globals.mediaPlayer.playing != nil) {
//            
//        }
//    }
}

class MediaCollectionViewController: UIViewController
{
    var preferredFocusView:UIView?
    {
        didSet {
            if (preferredFocusView != nil) {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.setNeedsFocusUpdate()
                })
            }
        }
    }
    
    override var preferredFocusEnvironments : [UIFocusEnvironment]
    {
        if preferredFocusView != nil {
            return [preferredFocusView!]
        } else {
            return [] // collectionView
        }
    }
    
    @IBOutlet weak var tomPennington: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var backgroundLogo: UIImageView!

    @IBOutlet weak var slider:UIProgressView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var avPlayerSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var controlView: UIView!
    
    @IBOutlet weak var restartButton: UIButton!
    {
        didSet {
            restartButton.setTitle(Constants.FA.RESTART, for: UIControlState.normal)
        }
    }
    @IBAction func restart(_ sender: UIButton)
    {
        globals.mediaPlayer.seek(to: 0)
    }
    
    @IBOutlet weak var skipBackwardsButton: UIButton!
    {
        didSet {
            skipBackwardsButton.setTitle(Constants.FA.REWIND, for: UIControlState.normal)
        }
    }
    @IBAction func skipBackwards(_ sender: UIButton)
    {
        guard globals.mediaPlayer.currentTime != nil else {
            return
        }
        
        globals.mediaPlayer.seek(to: globals.mediaPlayer.currentTime!.seconds - Constants.INTERVAL.SKIP_TIME)
    }
    
    @IBOutlet weak var skipForwardsButton: UIButton!
    {
        didSet {
            skipForwardsButton.setTitle(Constants.FA.FF, for: UIControlState.normal)
        }
    }
    @IBAction func skipForwards(_ sender: UIButton)
    {
        guard globals.mediaPlayer.currentTime != nil else {
            return
        }
        
        globals.mediaPlayer.seek(to: globals.mediaPlayer.currentTime!.seconds + Constants.INTERVAL.SKIP_TIME)
    }
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBAction func playPause(_ sender: UIButton)
    {
        guard (globals.mediaPlayer.state != nil) && (globals.mediaPlayer.playing == sermonSelected) && (globals.mediaPlayer.player != nil) else {
            playNewSermon(sermonSelected)
            return
        }
        
        switch globals.mediaPlayer.state! {
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
                addSliderObserver()
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
            //                setupPlayPauseButton()
            break
            
        case .seekingBackward:
            print("seekingBackward")
            globals.mediaPlayer.pause()
            //                setupPlayPauseButton()
            break
        }
    }
    
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
//    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var elapsed: UILabel!
    @IBOutlet weak var remaining: UILabel!
    
//    @IBOutlet weak var seriesArtAndDescription: UIView!
    
    @IBOutlet weak var seriesArt: UIImageView! {
        willSet {
            
        }
        didSet {
            //            let tap = UITapGestureRecognizer(target: self, action: #selector(MediaViewController.flip(_:)))
            //            seriesArt.addGestureRecognizer(tap)
            
            //            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(MediaViewController.flipFromLeft(_:)))
            //            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            //            seriesArt.addGestureRecognizer(swipeRight)
            //
            //            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(MediaViewController.flipFromRight(_:)))
            //            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            //            seriesArt.addGestureRecognizer(swipeLeft)
        }
    }
    
    @IBOutlet weak var seriesLabel: UILabel!
    @IBOutlet weak var seriesDescription: UITextView! {
        willSet {
            
        }
        didSet {
            //            let tap = UITapGestureRecognizer(target: self, action: #selector(MediaViewController.flip(_:)))
            //            seriesDescription.addGestureRecognizer(tap)
            
            //            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(MediaViewController.flipFromLeft(_:)))
            //            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            //            seriesDescription.addGestureRecognizer(swipeRight)
            //
            //            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(MediaViewController.flipFromRight(_:)))
            //            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            //            seriesDescription.addGestureRecognizer(swipeLeft)
            
//            seriesDescription.text = seriesSelected?.text
            seriesDescription.alwaysBounceVertical = true
            seriesDescription.isSelectable = false
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    {
        didSet {
            tableView.mask = nil
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
            if let statusNumber = change?[.newKey] as? NSNumber {
                //                print(statusNumber.intValue)
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over the status
            switch status {
            case .readyToPlay:
                // Player item is ready to play.
                //                print(player?.currentItem?.duration.value)
                //                print(player?.currentItem?.duration.timescale)
                //                print(player?.currentItem?.duration.seconds)
                
                if sermonSelected != nil {
                    if let length = player?.currentItem?.duration.seconds {
                        let timeNow = Double(sermonSelected!.currentTime!)!
                        let progress = timeNow / length
                        
                        //                    print("timeNow",timeNow)
                        //                    print("progress",progress)
                        //                    print("length",length)
                        
                        slider.progress = Float(progress)
                        setTimes(timeNow: timeNow,length: length)
                        
                        avPlayerSpinner.stopAnimating()
                        avPlayerSpinner.isHidden = true
                        
                        controlView.isHidden = false
                        elapsed.isHidden = false
                        remaining.isHidden = false
                        slider.isHidden = false
//                        slider.isEnabled = false
                    }
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
    
    // A messy way to cache AVPlayers by URL and only change the UI for the one related to the currently selectedSermon when its observeValue callback is called.
    // I'm proposing to do it this way because the AVPlayer does carry the URL with it and that will uniquely identify the sermon associated with that AVPlayer.
    
    //    var players = [String:AVPlayer]() // index is URL
    //    var sermons = [String:Sermon]() // index is URL
    
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
        removePlayerObserver()
        
        if url != nil {
            avPlayerSpinner.isHidden = false
            avPlayerSpinner.startAnimating()
            
            player = AVPlayer(url: url!)
            addPlayerObserver()
            //            if player == nil {
            //            }
        }
    }
    
    var sliderObserver: Timer?
    
    var seriesSelected:Series? {
        willSet {
            
        }
        didSet {
            //            globals.seriesSelected = seriesSelected
            if (seriesSelected != nil) {
                globals.showingAbout = false
                
                avPlayerSpinner.stopAnimating()
                sermonSelected = seriesSelected?.sermonSelected
                selectSermon(sermonSelected)
                
                preferredFocusView = tableView
                
                if (sermonSelected?.series == seriesSelected) && (globals.mediaPlayer.url == sermonSelected?.playingURL) {
                    addSliderObserver()
                } else {
                    globals.mediaPlayer.stop()
                }

                
                let defaults = UserDefaults.standard
                defaults.set("\(seriesSelected!.id)", forKey: Constants.SETTINGS.SELECTED.SERIES)
                defaults.synchronize()
                
//                DispatchQueue.main.async(execute: { () -> Void in
//                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.SERMON_UPDATE_PLAYING_PAUSED), object: nil)
//                })
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
            
            //            print(sermonSelected)
            if (sermonSelected != oldValue) {
                //                print("\(sermonSelected)")
                
                if (sermonSelected != globals.mediaPlayer.playing) {
                    globals.mediaPlayer.stop()
                    removeSliderObserver()
                    playerURL(url: sermonSelected!.playingURL!)
                } else {
                    preferredFocusView = playPauseButton
                    removePlayerObserver()
                    
                    addSliderObserver()
                    //                    addSliderObserver() // Crashes because it uses UI and this is done before viewWillAppear when the sermonSelected is set in prepareForSegue, but it only happens on an iPhone because the MVC isn't setup already.
                }
                
//                DispatchQueue.main.async(execute: { () -> Void in
//                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.SERMON_UPDATE_PLAYING_PAUSED), object: nil)
//                })
            } else {
                //                print("MediaViewController:sermonSelected nil")
                preferredFocusView = playPauseButton
            }
        }
    }
    
//    var refreshControl:UIRefreshControl?

    func setupPlayPauseButton()
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

            switch globals.mediaPlayer.state! {
            case .playing:
                //                    print("Pause")
                playPauseButton.setTitle(Constants.FA.PAUSE, for: UIControlState())
                break
                
            case .paused:
                //                    print("Play")
                playPauseButton.setTitle(Constants.FA.PLAY, for: UIControlState())
                break
                
            default:
                break
            }
            
            restartButton.isEnabled = globals.mediaPlayer.loaded
            skipBackwardsButton.isEnabled = globals.mediaPlayer.loaded
            skipForwardsButton.isEnabled = globals.mediaPlayer.loaded
            
            restartButton.isHidden = false
            skipBackwardsButton.isHidden = false
            skipForwardsButton.isHidden = false
        } else {
            playPauseButton.isEnabled = true
            playPauseButton.setTitle(Constants.FA.PLAY, for: UIControlState())
            
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
    
//    func updateView()
//    {
//        guard Thread.isMainThread else {
//            return
//        }
//        
//        seriesSelected = globals.seriesSelected
//        //        print(seriesSelected?.sermonSelected)
//        sermonSelected = seriesSelected?.sermonSelected
//        
//        //        sermonSelected = globals.sermonSelected
//        
//        //        print(seriesSelected)
//        //        print(sermonSelected)
//        
//        tableView.reloadData()
//        
//        //Without this background/main dispatching there isn't time to scroll correctly after a reload.
//        DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
//            DispatchQueue.main.async(execute: { () -> Void in
//                self.scrollToSermon(self.sermonSelected, select: true, position: UITableViewScrollPosition.none)
//            })
//        })
//        
//        updateUI()
//    }
    
//    func clearView()
//    {
//        guard Thread.isMainThread else {
//            return
//        }
//        
//        seriesSelected = nil
//        sermonSelected = nil
//        
//        tableView.reloadData()
//        
//        updateUI()
//    }
    
    
    fileprivate func setupArtAndDescription()
    {
        guard Thread.isMainThread else {
            return
        }
        
        guard seriesSelected != nil else {
            seriesArt.isHidden = true
            
            logo.isHidden = globals.showingAbout
            
            backgroundLogo.isHidden = !logo.isHidden
            tomPennington.isHidden = !logo.isHidden
            
            //            seriesArt.image = UIImage(named: "twu_logo_circle_r") // cover170x170
            
            let description = "Tom Pennington is Pastor-Teacher at Countryside Bible Church in Southlake, TX.<br/>His pulpit ministry provides the material for The Word Unleashed.\n\nOur ministry is founded upon one principle: God has given you every spiritual resource you need to grow in Jesus Christ, and you find those resources in His all-sufficient Word (2 Pet. 1:3). That's why Tom embraces expository preaching - an approach that seeks to understand what the original authors of Scripture meant, rather than an approach that reads our own meaning into it. If that's what you've been looking for, you've come to the right place.\n\nIt's our prayer that the transforming power of God's Word be unleashed in your life.\n\nP.O. Box 96077<br>Southlake, Texas 76092<br/>www.thewordunleashed.org<br/>listeners@thewordunleashed.org<br/>877-577-WORD (9673)"
            
            let text = description.replacingOccurrences(of: " ???", with: ",").replacingOccurrences(of: "–", with: "-").replacingOccurrences(of: "—", with: "&mdash;").replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\n\n", with: "\n").replacingOccurrences(of: "\n", with: "<br><br>").replacingOccurrences(of: "’", with: "&rsquo;").replacingOccurrences(of: "“", with: "&ldquo;").replacingOccurrences(of: "”", with: "&rdquo;").replacingOccurrences(of: "?۪s", with: "'s").replacingOccurrences(of: "…", with: "...")
            
            if let attributedString = try? NSMutableAttributedString(data: text.data(using: String.Encoding.utf8, allowLossyConversion: false)!,
                                                                     options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                                     documentAttributes: nil) {
                
                attributedString.addAttributes([NSFontAttributeName:UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)],
                                               range: NSMakeRange(0, attributedString.length))
                
                
//                seriesDescription.attributedText = nil
                seriesLabel.attributedText = attributedString
            }
            
            //            seriesArt.isHidden = false
//            seriesDescription.isHidden = false
            
            //            seriesArtAndDescription.isHidden = true
            //            pageControl.isHidden = true

            return
        }
        
        //            seriesArtAndDescription.isHidden = false
        
        logo.isHidden = true
        tomPennington.isHidden = true

        backgroundLogo.isHidden = false
        //            pageControl.isHidden = false
        
        //            print(seriesSelected?.text)
        
        if let text = seriesSelected?.text?.replacingOccurrences(of: " ???", with: ",").replacingOccurrences(of: "–", with: "-").replacingOccurrences(of: "—", with: "&mdash;").replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\n\n", with: "\n").replacingOccurrences(of: "\n", with: "<br><br>").replacingOccurrences(of: "’", with: "&rsquo;").replacingOccurrences(of: "“", with: "&ldquo;").replacingOccurrences(of: "”", with: "&rdquo;").replacingOccurrences(of: "?۪s", with: "'s").replacingOccurrences(of: "…", with: "...") {
            if let attributedString = try? NSMutableAttributedString(data: text.data(using: String.Encoding.utf8, allowLossyConversion: false)!,
                                                                     options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                                     documentAttributes: nil) {
                
                // preferredFont(forTextStyle: UIFontTextStyle.footnote)
                
                attributedString.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 31.0)],
                                               range: NSMakeRange(0, attributedString.length))
                
                
                seriesDescription.attributedText = nil
                seriesLabel.attributedText = attributedString
            }
        }
        
        if let series = self.seriesSelected {
            if let image = series.loadArt() {
                seriesArt.image = image
            } else {
                DispatchQueue.global(qos: .background).async { () -> Void in
                    if let image = series.fetchArt() {
                        if self.seriesSelected == series {
                            DispatchQueue.main.async {
                                self.seriesArt.image = image
                            }
                        }
                    }
                }
            }
        }
        
        seriesArt.isHidden = false // pageControl.currentPage == 1
        seriesDescription.isHidden = false // pageControl.currentPage == 0
        return
    }
    
    func setupTitle()
    {
        guard Thread.isMainThread else {
            return
        }
        
        if (!globals.isLoading) { //  && !globals.isRefreshing
//            if navigationController?.visibleViewController == self {
//                self.navigationController?.isToolbarHidden = false
//            }
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
                if (globals.mediaPlayer.currentTime!.seconds > Double(globals.mediaPlayer.playing!.currentTime!)!) {
                    spinner.isHidden = true
                    spinner.stopAnimating()
                } else {
                    spinner.isHidden = false
                    spinner.startAnimating()
                }
            }
        }
    }
    
    func updateUI()
    {
        guard Thread.isMainThread else {
            return
        }
        
        self.setupArtAndDescription()
        
        self.setupTitle()
        self.setupPlayPauseButton()
        self.setupSpinner()
        self.setupSlider()

//        DispatchQueue.main.async(execute: { () -> Void in
//            self.setupArtAndDescription()
//            
//            self.setupTitle()
//            self.setupPlayPauseButton()
//            self.setupSpinner()
//            self.setupSlider()
//
////            self.collectionView.reloadData()
////            self.tableView.reloadData()
//        })


//        //These are being added here for the case when this view is opened and the sermon selected is playing already
//        if self.navigationController?.visibleViewController == self {
//            self.navigationController?.isToolbarHidden = true
//            
//            if  let hClass = self.splitViewController?.traitCollection.horizontalSizeClass,
//                let vClass = self.splitViewController?.traitCollection.verticalSizeClass,
//                let count = self.splitViewController?.viewControllers.count {
//                if let navigationController = self.splitViewController?.viewControllers[count - 1] as? UINavigationController {
//                    if (hClass == UIUserInterfaceSizeClass.regular) && (vClass == UIUserInterfaceSizeClass.compact) {
//                        navigationController.topViewController?.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
//                    } else {
//                        navigationController.topViewController?.navigationItem.leftBarButtonItem = nil
//                    }
//                }
//            }
//        }
        
//        addSliderObserver()
        
//        setupActionsButton()
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
            if let sermonIndex = seriesSelected?.sermons?.index(of: sermon!) {
                //                    print("\(sermonIndex)")
                indexPath = IndexPath(row: sermonIndex, section: 0)
            }
        }
        
        //            print("\(tableView.bounds)")
        
        if (select) {
            //                print(indexPath)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: position)
        }
        
        //            print("Row: \(indexPath.row) Section: \(indexPath.section)")
        
        tableView.scrollToRow(at: indexPath, at: position, animated: false)
        
        //        if (position == UITableViewScrollPosition.top) {
        //            //                var point = CGPointZero //tableView.bounds.origin
        //            //                point.y += tableView.rowHeight * CGFloat(indexPath.row)
        //            //                tableView.setContentOffset(point, animated: true)
        //            tableView.scrollToRow(at: indexPath, at: position, animated: false)
        //        } else {
        //            tableView.scrollToRow(at: indexPath, at: position, animated: false)
        //        }
    }

    //    var resultSearchController:UISearchController?

//    var session:URLSession? // Used for JSON
    
    fileprivate func setTimes(timeNow:Double, length:Double)
    {
        let elapsedHours = Int(timeNow / (60*60))
        let elapsedMins = Int((timeNow - (Double(elapsedHours) * 60*60)) / 60)
        let elapsedSec = Int(timeNow.truncatingRemainder(dividingBy: 60))
        
        var elapsed:String
        
        if (elapsedHours > 0) {
            elapsed = "\(String(format: "%d",elapsedHours)):"
        } else {
            elapsed = Constants.EMPTY_STRING
        }
        
        elapsed = elapsed + "\(String(format: "%02d",elapsedMins)):\(String(format: "%02d",elapsedSec))"
        
        self.elapsed.text = elapsed
        
        let timeRemaining = length - timeNow
        let remainingHours = Int(timeRemaining / (60*60))
        let remainingMins = Int((timeRemaining - (Double(remainingHours) * 60*60)) / 60)
        let remainingSec = Int(timeRemaining.truncatingRemainder(dividingBy: 60))
        
        var remaining:String
        
        if (remainingHours > 0) {
            remaining = "\(String(format: "%d",remainingHours)):"
        } else {
            remaining = Constants.EMPTY_STRING
        }
        
        remaining = remaining + "\(String(format: "%02d",remainingMins)):\(String(format: "%02d",remainingSec))"
        
        self.remaining.text = remaining
    }
    
    
    fileprivate func setSliderAndTimesToAudio()
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
        
        guard (globals.mediaPlayer.state != nil) else {
            return
        }
        
        var progress = -1.0
        
        //            print("currentTime",selectedSermon?.currentTime)
        //            print("timeNow",timeNow)
        //            print("progress",progress)
        //            print("length",length)
        
        if (length > 0) {
            switch globals.mediaPlayer.state! {
            case .playing:
                if (playingCurrentTime >= 0) && (playerCurrentTime <= globals.mediaPlayer.duration!.seconds) {
                    progress = playerCurrentTime / length
                    
                    //                        print("playing")
                    //                        print("timeNow",timeNow)
                    //                        print("progress",progress)
                    //                        print("length",length)
                    
//                    if sliding && (Int(progress*100) == Int(playingCurrentTime/length*100)) {
//                        print("DONE SLIDING")
//                        sliding = false
//                    }
                    
                    if globals.mediaPlayer.loaded { // !sliding &&
                        if playerCurrentTime == 0 {
                            progress = playingCurrentTime / length
                            slider.progress = Float(progress)
                            setTimes(timeNow: playingCurrentTime,length: length)
                        } else {
                            slider.progress = Float(progress)
                            setTimes(timeNow: playerCurrentTime,length: length)
                        }
                    }
                    
                    elapsed.isHidden = false
                    remaining.isHidden = false
                    slider.isHidden = false
//                    slider.isEnabled = true
                }
                break
                
            case .paused:
                //                    if sermonSelected?.currentTime != playerCurrentTime.description {
                progress = playingCurrentTime / length
                
                //                        print("paused")
                //                        print("timeNow",timeNow)
                //                        print("progress",progress)
                //                        print("length",length)
                
                slider.progress = Float(progress)
                setTimes(timeNow: playingCurrentTime,length: length)
                
                elapsed.isHidden = false
                remaining.isHidden = false
                slider.isHidden = false
//                slider.isEnabled = true
                //                    }
                break
                
            case .stopped:
                //                    if sermonSelected?.currentTime != playerCurrentTime.description {
                progress = playingCurrentTime / length
                
                //                        print("stopped")
                //                        print("timeNow",timeNow)
                //                        print("progress",progress)
                //                        print("length",length)
                
                slider.progress = Float(progress)
                setTimes(timeNow: playingCurrentTime,length: length)
                
                elapsed.isHidden = false
                remaining.isHidden = false
                slider.isHidden = false
//                slider.isEnabled = true
                //                    }
                break
                
            default:
                break
            }
        }
    }
    
//    override var canBecomeFirstResponder : Bool
//    {
//        return true
//    }

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
        
        //            print("\(seriesSelected!.title)")
        
        //Without this background/main dispatching there isn't time to scroll correctly after a reload.
        DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self.scrollToSermon(sermon, select: true, position: UITableViewScrollPosition.none)
            })
        })
    }
    
    func sliderTimer()
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
        
        guard (globals.mediaPlayer.state != nil) else {
            return
        }
        
        guard (globals.mediaPlayer.startTime != nil) else {
            return
        }
        
        guard (globals.mediaPlayer.currentTime != nil) else {
            return
        }
        
//        slider.isEnabled = globals.mediaPlayer.loaded
        setupPlayPauseButton()
        
        if (!globals.mediaPlayer.loaded) {
            if (!spinner.isAnimating) {
                spinner.isHidden = false
                spinner.startAnimating()
            }
        }
        
        switch globals.mediaPlayer.state! {
        case .none:
            print("none")
            break
            
        case .playing:
            print("playing")
            setSliderAndTimesToAudio()
            
            if (!globals.mediaPlayer.loaded) {
                if (!spinner.isAnimating) {
                    spinner.isHidden = false
                    spinner.startAnimating()
                }
            } else {
                if (globals.mediaPlayer.rate > 0) && (globals.mediaPlayer.currentTime!.seconds > Double((globals.mediaPlayer.startTime!))!) {
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
                setSliderAndTimesToAudio()
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
        var seekToTime:CMTime?
        
        if sermonSelected!.hasCurrentTime() {
            if sermon!.atEnd {
                NSLog("playPause globals.mediaPlayer.currentTime and globals.player.playing!.currentTime reset to 0!")
                globals.mediaPlayer.playing!.currentTime = Constants.ZERO
                seekToTime = CMTimeMakeWithSeconds(0,Constants.CMTime_Resolution)
                sermon?.atEnd = false
            } else {
                seekToTime = CMTimeMakeWithSeconds(Double(sermon!.currentTime!)!,Constants.CMTime_Resolution)
            }
        } else {
            NSLog("playPause selectedMediaItem has NO currentTime!")
            sermon?.currentTime = Constants.ZERO
            seekToTime = CMTimeMakeWithSeconds(0,Constants.CMTime_Resolution)
        }
        
        if seekToTime != nil {
            let loadedTimeRanges = (globals.mediaPlayer.player?.currentItem?.loadedTimeRanges as? [CMTimeRange])?.filter({ (cmTimeRange:CMTimeRange) -> Bool in
                return cmTimeRange.containsTime(seekToTime!)
            })
            
            let seekableTimeRanges = (globals.mediaPlayer.player?.currentItem?.seekableTimeRanges as? [CMTimeRange])?.filter({ (cmTimeRange:CMTimeRange) -> Bool in
                return cmTimeRange.containsTime(seekToTime!)
            })
            
            if (loadedTimeRanges != nil) || (seekableTimeRanges != nil) {
                globals.mediaPlayer.seek(to: seekToTime?.seconds)
                
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
        globals.reloadPlayer(sermon)
        addSliderObserver()
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
        
        removeSliderObserver()
        
        //This guarantees a fresh start.
        globals.mediaPlayer.playOnLoad = true
        globals.setupPlayer(sermon)
        
        addSliderObserver()
        
        if (view.window != nil) {
            setupSlider()
            setupPlayPauseButton()
//            setupActionsButton()
        }
    }
    
    fileprivate func setupSlider()
    {
        guard Thread.isMainThread else {
            return
        }
        
        guard (sermonSelected != nil) else {
            elapsed.isHidden = true
            remaining.isHidden = true
            slider.isHidden = true
            return
        }
        
        if (globals.mediaPlayer.playing != nil) && (globals.mediaPlayer.playing == sermonSelected) {
            if !globals.mediaPlayer.loadFailed {
                setSliderAndTimesToAudio()
            } else {
                elapsed.isHidden = true
                remaining.isHidden = true
                slider.isHidden = true
            }
        } else {
            //            print(player?.currentItem?.status.rawValue)
            if (player?.currentItem?.status == .readyToPlay) {
                if let length = player?.currentItem?.duration.seconds {
                    let timeNow = Double(sermonSelected!.currentTime!)!
                    let progress = timeNow / length
                    
                    //                        print("timeNow",timeNow)
                    //                        print("progress",progress)
                    //                        print("length",length)
                    
                    slider.progress = Float(progress)
                    setTimes(timeNow: timeNow,length: length)
                    
                    elapsed.isHidden = false
                    remaining.isHidden = false
                    slider.isHidden = false
//                    slider.isEnabled = false
                } else {
                    elapsed.isHidden = true
                    remaining.isHidden = true
                    slider.isHidden = true
                }
            } else {
                elapsed.isHidden = true
                remaining.isHidden = true
                slider.isHidden = true
            }
        }
    }

    func sorting()
    {
        if let navigationController = self.storyboard!.instantiateViewController(withIdentifier: Constants.IDENTIFIER.POPOVER_TABLEVIEW_NAV) as? UINavigationController {
            if let popover = navigationController.viewControllers[0] as? PopoverTableViewController {
                navigationController.modalPresentationStyle = .fullScreen
                //            popover?.preferredContentSize = CGSizeMake(300, 500)
                
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
        if let navigationController = self.storyboard!.instantiateViewController(withIdentifier: Constants.IDENTIFIER.POPOVER_TABLEVIEW_NAV) as? UINavigationController,
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
        
        if let navigationController = self.storyboard!.instantiateViewController(withIdentifier: Constants.IDENTIFIER.POPOVER_TABLEVIEW) as? UINavigationController,
            let popover = navigationController.viewControllers[0] as? PopoverTableViewController {
            navigationController.modalPresentationStyle = .fullScreen
            
            popover.navigationItem.title = "Auto Advance"
            
            popover.delegate = self
            
            popover.purpose = .selectingSettings
            popover.section.strings = ["On, Off"]
            
            present(navigationController, animated: true, completion: nil)
        }
    }
    
//    func settings(_ button:UIBarButtonItem?)
//    {
//        dismiss(animated: true, completion: nil)
//        performSegue(withIdentifier: Constants.SEGUE.SHOW_SETTINGS, sender: nil)
//    }
    
    fileprivate func setupSortingAndGroupingOptions()
    {
//        let sortingButton = UIBarButtonItem(title: Constants.Sort, style: UIBarButtonItemStyle.plain, target: self, action: #selector(MediaCollectionViewController.sorting(_:)))
//        
//        let filterButton = UIBarButtonItem(title: Constants.Filter, style: UIBarButtonItemStyle.plain, target: self, action: #selector(MediaCollectionViewController.filtering(_:)))
//        
//        let settingsButton = UIBarButtonItem(title: Constants.Settings, style: UIBarButtonItemStyle.plain, target: self, action: #selector(MediaCollectionViewController.settings(_:)))
//        
//        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
//        
//        var barButtons = [UIBarButtonItem]()
//        
//        barButtons.append(spaceButton)
//        
//        barButtons.append(sortingButton)
//        
//        barButtons.append(spaceButton)
//
//        barButtons.append(filterButton)
//        
//        barButtons.append(spaceButton)
//        
//        barButtons.append(settingsButton)
//        
//        barButtons.append(spaceButton)
//        
//        navigationController?.toolbar.isTranslucent = false
//        
//        if navigationController?.visibleViewController == self {
//            navigationController?.isToolbarHidden = false // If this isn't here a colleciton view in an iPad master view controller will NOT show the toolbar - even though it will show in the navigation controller on an iPhone if this occurs in viewWillAppear()
//        }
//        
//        setToolbarItems(barButtons, animated: true)
    }
    
//    fileprivate func setupSearchBar()
//    {
//        switch globals.showing {
//        case .all:
//            searchBar.placeholder = Constants.All
//            break
//        case .filtered:
//            searchBar.placeholder = globals.filter
//            break
//        }
//    }
    
    func scrollToSeries(_ series:Series?)
    {
        guard series != nil else {
            return
        }
        
        guard globals.activeSeries?.index(of: series!) != nil else {
            preferredFocusView = playPauseButton
            return
        }
        
        let indexPath = IndexPath(item: globals.activeSeries!.index(of: series!)!, section: 0)
        
        self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: false)
        self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.left)
        
        preferredFocusView = collectionView.cellForItem(at: indexPath)
        
        //            preferredFocusView = collectionView
        //
        //            self.collectionView.setNeedsFocusUpdate()
        
        //Without this background/main dispatching there isn't time to scroll after a reload.
        //            DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
        //                DispatchQueue.main.async(execute: { () -> Void in
        //                    self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
        //                    self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.left)
        //                    self.collectionView.setNeedsFocusUpdate()
        //                })
        //            })
    }
    
    func setupViews()
    {
//        setupSearchBar()
        
        collectionView.reloadData()
        
        enableBarButtons()
        
        setupTitle()
        
//        setupPlayingPausedButton()
        
//        scrollToSeries(seriesSelected)
        
        if let isCollapsed = splitViewController?.isCollapsed, !isCollapsed {
            DispatchQueue.main.async(execute: { () -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.UPDATE_VIEW), object: nil)
            })
        }
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
    
    func removeJSONFromFileSystemDirectory()
    {
        if let jsonFileSystemURL = cachesURL()?.appendingPathComponent(Constants.JSON.SERIES) {
            do {
                try FileManager.default.removeItem(atPath: jsonFileSystemURL.path)
            } catch let error as NSError {
                NSLog(error.localizedDescription)
                print("failed to copy sermons.json")
            }
        }
    }
    
    func jsonToFileSystem()
    {
        let fileManager = FileManager.default
        
        //Get documents directory URL
        let jsonFileSystemURL = cachesURL()?.appendingPathComponent(Constants.JSON.SERIES)
        
        // Check if file exist
        if (!fileManager.fileExists(atPath: jsonFileSystemURL!.path)){
//            downloadJSON()
        }
    }
    
    func jsonFromURL() -> JSON
    {
//        if let url = cachesURL()?.URLByAppendingPathComponent(Constants.SERIES_JSON) {

        let jsonFileSystemURL = cachesURL()?.appendingPathComponent(Constants.JSON.SERIES)
        
        do {
            let data = try Data(contentsOf: URL(string: Constants.JSON.URL)!) // , options: NSData.ReadingOptions.mappedIfSafe
            
            let json = JSON(data: data)
            
            if json != JSON.null {
                try data.write(to: jsonFileSystemURL!, options: NSData.WritingOptions.atomicWrite)
                
                print(json)
                
                return json
            } else {
                print("could not get json from file, make sure that file contains valid json.")
                
                let data = try Data(contentsOf: jsonFileSystemURL!) // , options: NSData.ReadingOptions.mappedIfSafe
                
                let json = JSON(data: data)
                if json != JSON.null {
                    print(json)
                    return json
                }
            }
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            
            do {
                let data = try Data(contentsOf: jsonFileSystemURL!) // , options: NSData.ReadingOptions.mappedIfSafe
                
                let json = JSON(data: data)
                if json != JSON.null {
                    print(json)
                    return json
                }
            } catch let error as NSError {
                NSLog(error.localizedDescription)
            }
        }

        
//        } else {
//            print("Invalid filename/path.")
//        }
        
        return nil
    }
    
    func loadSeriesDicts() -> [[String:String]]?
    {
//        jsonToFileSystem()
        
        let json = jsonFromURL()
        
        if json != nil {
//            print("json:\(json)")
            
            var seriesDicts = [[String:String]]()
            
            let series = json[Constants.JSON.ARRAY_KEY]
            
            for i in 0..<series.count {
                //                    print("sermon: \(series[i])")
                
                var dict = [String:String]()
                
                for (key,value) in series[i] {
                    dict["\(key)"] = "\(value)"
                }
                
                seriesDicts.append(dict)
            }
            
            return seriesDicts.count > 0 ? seriesDicts : nil
        } else {
            print("could not get json from file, make sure that file contains valid json.")
        }
        
        return nil
    }
    
    func loadSeries(_ completion: (() -> Void)?)
    {
        DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
            globals.isLoading = true

            DispatchQueue.main.async(execute: { () -> Void in
//                if !globals.isRefreshing {
//                }
//                self.activityIndicator.isHidden = false
//                self.activityIndicator.startAnimating()
                self.navigationItem.title = Constants.Titles.Loading_Series
            })
            
            if let seriesDicts = self.loadSeriesDicts() {
                globals.series = self.seriesFromSeriesDicts(seriesDicts)
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.navigationItem.title = Constants.Titles.Loading_Settings
            })
            globals.loadSettings()

            DispatchQueue.main.async(execute: { () -> Void in
                self.navigationItem.title = Constants.Titles.Setting_up_Player
                if (globals.mediaPlayer.playing != nil) {
                    globals.mediaPlayer.playOnLoad = false
                    globals.setupPlayer(globals.mediaPlayer.playing)
                }

                self.navigationItem.title = Constants.TWU.LONG

                self.seriesSelected = globals.seriesSelected
                self.sermonSelected = globals.seriesSelected?.sermonSelected
                
                self.updateUI()

//                if globals.isRefreshing {
//                    self.refreshControl?.endRefreshing()
//                    globals.isRefreshing = false
////                    DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
////                    })
//                } else {
//                    self.activityIndicator.stopAnimating()
//                    self.activityIndicator.isHidden = true
//                }

//                self.activityIndicator.stopAnimating()
//                self.activityIndicator.isHidden = true

                completion?()
            })

            globals.isLoading = false
        })
    }
    
//    func disableToolBarButtons()
//    {
//        if let barButtons = toolbarItems {
//            for barButton in barButtons {
//                barButton.isEnabled = false
//            }
//        }
//    }
    
    func disableBarButtons()
    {
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
//        disableToolBarButtons()
    }
    
//    func enableToolBarButtons()
//    {
//        if (globals.series != nil) {
//            if let barButtons = toolbarItems {
//                for barButton in barButtons {
//                    barButton.isEnabled = true
//                }
//            }
//        }
//    }
    
    func enableBarButtons()
    {
        if (globals.series != nil) {
            navigationItem.leftBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
//            enableToolBarButtons()
        }
    }
    
//    func handleRefresh(_ refreshControl: UIRefreshControl)
//    {
//        guard Thread.isMainThread else {
//            return
//        }
//        
//        globals.isRefreshing = true
//        
//        globals.unobservePlayer()
//        
//        globals.mediaPlayer.pause()
//
//        globals.cancelAllDownloads()
//        
//        searchBar.placeholder = nil
//        
//        if let isCollapsed = splitViewController?.isCollapsed, !isCollapsed {
//            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.CLEAR_VIEW), object: nil)
//        }
//        
//        disableBarButtons()
//        
//        loadSeries()
//        {
//            if globals.series == nil {
//                let alert = UIAlertController(title: "No media available.",
//                                              message: "Please check your network connection and try again.",
//                                              preferredStyle: UIAlertControllerStyle.alert)
//                
//                let action = UIAlertAction(title: Constants.Cancel, style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) -> Void in
//                    if globals.isRefreshing {
//                        self.refreshControl?.endRefreshing()
//                        globals.isRefreshing = false
//                    }
//                })
//                alert.addAction(action)
//                
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//
////        downloadJSON()
//    }
    
    func playPauseButtonAction(tap:UITapGestureRecognizer)
    {
        print("play pause button pressed")
        
        //        if (globals.mediaPlayer.url != URL(string:Constants.URL.LIVE_STREAM)) {
        //            DispatchQueue.main.async(execute: { () -> Void in
        //                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NOTIFICATION.PLAY_PAUSE), object: nil)
        //            })
        //        } else {
        if let state = globals.mediaPlayer.state {
            switch state {
            case .playing:
                globals.mediaPlayer.pause()
                
            case .paused:
                if globals.mediaPlayer.url == sermonSelected?.playingURL {
                    addSliderObserver()
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
        //        }
    }
    
    func menuButtonAction(tap:UITapGestureRecognizer)
    {
        print("MTVC menu button pressed")
        
        if !Thread.isMainThread {
            print("NOT MAIN THREAD")
        }

        globals.popoverNavCon = self.storyboard!.instantiateViewController(withIdentifier: Constants.IDENTIFIER.POPOVER_TABLEVIEW_NAV) as? UINavigationController
        
        if globals.popoverNavCon != nil, let popover = globals.popoverNavCon?.viewControllers[0] as? PopoverTableViewController {
            globals.popoverNavCon?.modalPresentationStyle = .fullScreen
            
            popover.navigationItem.title = "Menu Options"
            
            popover.delegate = self
            
            popover.purpose = .selectingMenu
            
            var strings = [String]()
            
            if !globals.showingAbout {
                strings.append("About")
            }
            strings.append("Sorting")
            strings.append("Filtering")
            
            popover.purpose = .selectingMenu
            popover.section.strings = strings
            
            present(globals.popoverNavCon!, animated: true, completion: nil )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 0.75)
        
        if globals.series == nil {
            loadSeries({
                self.collectionView.reloadData()
                self.scrollToSeries(self.seriesSelected)
            })
        }
        
        let menuPressRecognizer = UITapGestureRecognizer(target: self, action: #selector(MediaCollectionViewController.menuButtonAction(tap:)))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)]
        view.addGestureRecognizer(menuPressRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MediaCollectionViewController.playPauseButtonAction(tap:)))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)];
        view.addGestureRecognizer(tapRecognizer)

//        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.updateUI), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.SERIES_UPDATE_UI), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.setupPlayingPausedButton), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.SERMON_UPDATE_PLAYING_PAUSED), object: nil)
        
//        splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible //iPad only
        
//        refreshControl = UIRefreshControl()
//        refreshControl!.addTarget(self, action: #selector(MediaCollectionViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)

//        collectionView.addSubview(refreshControl!)
        
//        collectionView.alwaysBounceVertical = true

//        setupPlayingPausedButton()
        
        collectionView?.allowsSelection = true

        if #available(iOS 10.0, *) {
            collectionView?.isPrefetchingEnabled = false
        } else {
            // Fallback on earlier versions
        }
        
        setupSortingAndGroupingOptions()
    }
    
//    func setPlayingPausedButton()
//    {
//        guard globals.mediaPlayer.playing != nil else {
//            navigationItem.setRightBarButton(nil, animated: true)
//            return
//        }
//        
//        var title:String?
//        
//        switch globals.mediaPlayer.state! {
//        case .paused:
//            title = Constants.Paused
//            break
//            
//        case .playing:
//            title = Constants.Playing
//            break
//            
//        default:
//            title = Constants.None
//            break
//        }
//        
////        var playingPausedButton = navigationItem.rightBarButtonItem
////        
////        if (playingPausedButton == nil) {
////            playingPausedButton = UIBarButtonItem(title: nil, style: UIBarButtonItemStyle.plain, target: self, action: #selector(MediaCollectionViewController.gotoNowPlaying))
////        }
//        
////        playingPausedButton!.title = title
//        
////        navigationItem.setRightBarButton(playingPausedButton, animated: true)
//    }

//    func setupPlayingPausedButton()
//    {
//        guard (globals.mediaPlayer.player != nil) && (globals.mediaPlayer.playing != nil) else {
//            if (navigationItem.rightBarButtonItem != nil) {
//                navigationItem.setRightBarButton(nil, animated: true)
//            }
//            return
//        }
//
//        guard (!globals.showingAbout) else {
//            // Showing About
//            setPlayingPausedButton()
//            return
//        }
//        
//        guard let isCollapsed = splitViewController?.isCollapsed, !isCollapsed else {
//            // iPhone
//            setPlayingPausedButton()
//            return
//        }
//        
//        guard (!splitViewController!.isCollapsed) else {
//            // iPhone
//            setPlayingPausedButton()
//            return
//        }
//        
//        guard (seriesSelected == globals.mediaPlayer.playing?.series) else {
//            // iPhone
//            setPlayingPausedButton()
//            return
//        }
//        
//        if let sermonSelected = seriesSelected?.sermonSelected {
//            if (sermonSelected != globals.mediaPlayer.playing) {
//                setPlayingPausedButton()
//            } else {
//                if (navigationItem.rightBarButtonItem != nil) {
//                    navigationItem.setRightBarButton(nil, animated: true)
//                }
//            }
//        } else {
//            if (navigationItem.rightBarButtonItem != nil) {
//                navigationItem.setRightBarButton(nil, animated: true)
//            }
//        }
//    }
    
//    func deviceOrientationDidChange()
//    {
//    
//    }
    
    func readyToPlay()
    {
        updateUI()

        preferredFocusView = playPauseButton
    }
    
    func showPlaying()
    {
        guard Thread.isMainThread else {
            return
        }
        
//        guard (globals.mediaPlayer.playing != nil) else {
//            removeSliderObserver()
//            playerURL(url: sermonSelected!.playingURL!)
//            preferredFocusView = playPauseButton
//            updateUI()
//            return
//        }
//        
//        guard (sermonSelected?.series?.sermons?.index(of: globals.mediaPlayer.playing!) != nil) else {
//            updateUI()
//            return
//        }
        
        if globals.mediaPlayer.playing != nil {
            sermonSelected = globals.mediaPlayer.playing
        } else {
            removeSliderObserver()
            playerURL(url: sermonSelected!.playingURL!)
            preferredFocusView = playPauseButton
        }
        
//        tableView.reloadData()
        
        //Without this background/main dispatching there isn't time to scroll correctly after a reload.
        
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async(execute: { () -> Void in
                self.scrollToSermon(self.sermonSelected, select: true, position: UITableViewScrollPosition.none)
            })
        }
        
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.remembersLastFocusedIndexPath = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.showPlaying), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.SHOW_PLAYING), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.updateUI), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.FAILED_TO_PLAY), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.readyToPlay), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.READY_TO_PLAY), object: nil)

//        navigationController?.isToolbarHidden = false

//        if globals.searchActive && !globals.searchButtonClicked {
//            searchBar.becomeFirstResponder()
//        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(MediaCollectionViewController.deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        //Unreliable
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground:", name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication())
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:", name: UIApplicationWillResignActiveNotification, object: UIApplication.sharedApplication())
        
//        splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible //iPad only

//        setupPlayingPausedButton()
        
        //Solves icon sizing problem in split screen multitasking.
        updateUI()
        
//        scrollToSeries(seriesSelected)
    }
    
//    func collectionView(_: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
//    {
//        var minSize:CGFloat = 0.0
//        var maxSize:CGFloat = 0.0
//        
//        // We want at least two full icons showing in either direction.
//        
//        var minIndex = 2
//        var maxIndex = 2
//        
//        let minMeasure = min(view.bounds.height,view.bounds.width)
//        let maxMeasure = max(view.bounds.height,view.bounds.width)
//        
//        repeat {
//            minSize = (minMeasure - CGFloat(10*(minIndex+1)))/CGFloat(minIndex)
//            minIndex += 1
//        } while minSize > minMeasure
//        
////        print(minSize)
////        print(minIndex-1)
//        
//        repeat {
//            maxSize = (maxMeasure - CGFloat(10*(maxIndex+1)))/CGFloat(maxIndex)
//            maxIndex += 1
//        } while maxSize > maxMeasure/(maxMeasure / minSize)
//
////        print(maxMeasure / minSize)
//        
////        print(maxSize)
////        print(maxIndex-1)
//        
//        var size:CGFloat = 0
//
//        // These get the gap right between the icons.
//        
//        if minMeasure == view.bounds.height {
//            size = min(minSize,maxSize)
//        }
//        
//        if minMeasure == view.bounds.width {
//            size = max(minSize,maxSize)
//        }
//
//        return CGSize(width: size,height: size)
//    }
    
//    func about()
//    {
//        performSegue(withIdentifier: Constants.SEGUE.SHOW_ABOUT, sender: self)
//    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        
////        if (self.view.window == nil) {
////            return
////        }
//
//        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
//            self.collectionView.reloadData()
////            if (UIApplication.shared.applicationState == UIApplicationState.active) { //  && (self.view.window != nil)
////            }
//
//            //Not quite what we want.  What we want is for the list to "look" the same.
////            self.scrollToSeries(self.seriesSelected)
//        }) { (UIViewControllerTransitionCoordinatorContext) -> Void in
//            self.setupTitle()
//
//            //Solves icon sizing problem in split screen multitasking.
//            self.collectionView.reloadData()
//        }
//    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        scrollToSeries(seriesSelected)

        setNeedsFocusUpdate()
    }
    
    func removeSliderObserver() {
        if globals.mediaPlayer.sliderTimerReturn != nil {
            globals.mediaPlayer.player?.removeTimeObserver(globals.mediaPlayer.sliderTimerReturn!)
            globals.mediaPlayer.sliderTimerReturn = nil
        }
    }
    
    func addSliderObserver()
    {
        removeSliderObserver()
        
        globals.mediaPlayer.sliderTimerReturn = globals.mediaPlayer.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.1,Constants.CMTime_Resolution), queue: DispatchQueue.main, using: { [weak self] (CMTime) in
            self?.sliderTimer()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
//        if let isCollapsed = splitViewController?.isCollapsed, isCollapsed {
//            navigationController?.isToolbarHidden = true
//        }
        
        removeSliderObserver()
        removePlayerObserver()
        
        //        for player in players.values {
        //            player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: nil)
        //        }
        
        NotificationCenter.default.removeObserver(self)
        
        sliderObserver?.invalidate()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using [segue destinationViewController].
//        // Pass the selected object to the new view controller.
//        var destination = segue.destination as UIViewController
//        // this next if-statement makes sure the segue prepares properly even
//        //   if the MVC we're seguing to is wrapped in a UINavigationController
//        if let navCon = destination as? UINavigationController {
//            destination = navCon.visibleViewController!
//        }
//        if let identifier = segue.identifier {
//            switch identifier {
//            case Constants.SEGUE.SHOW_SETTINGS:
//                if let svc = destination as? SettingsViewController {
//                    svc.modalPresentationStyle = .popover
//                    svc.popoverPresentationController?.delegate = self
//                    svc.popoverPresentationController?.barButtonItem = toolbarItems?[5]
//                }
//                break
//                
//            case Constants.SEGUE.SHOW_ABOUT:
//                //The block below only matters on an iPad
//                globals.showingAbout = true
//                setupPlayingPausedButton()
//                break
//                
//            case Constants.SEGUE.SHOW_SERIES:
////                print("ShowSeries")
//                if (globals.gotoNowPlaying) {
//                    //This pushes a NEW MediaViewController.
//                    
//                    seriesSelected = globals.mediaPlayer.playing?.series
//                    
//                    if let dvc = destination as? MediaViewController {
//                        dvc.seriesSelected = globals.mediaPlayer.playing?.series
//                        dvc.sermonSelected = globals.mediaPlayer.playing
//                    }
//
//                    globals.gotoNowPlaying = !globals.gotoNowPlaying
////                    let indexPath = NSIndexPath(forItem: globals.activeSeries!.indexOf(seriesSelected!)!, inSection: 0)
////                    collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
//                } else {
//                    if let myCell = sender as? MediaCollectionViewCell {
//                        seriesSelected = myCell.series
//                    }
//
//                    if (seriesSelected != nil) {
//                        if let isCollapsed = splitViewController?.isCollapsed, !isCollapsed {
//                            setupPlayingPausedButton()
//                        }
//                    }
//                    
//                    if let dvc = destination as? MediaViewController {
//                        dvc.seriesSelected = seriesSelected
//                        dvc.sermonSelected = nil
//                    }
//                }
//                break
//                
//            default:
//                break
//            }
//        }
//    }
    
//    func gotoNowPlaying()
//    {
////        print("gotoNowPlaying")
//        
//        globals.gotoNowPlaying = true
//        
//        performSegue(withIdentifier: Constants.SEGUE.SHOW_SERIES, sender: self)
//    }
}
