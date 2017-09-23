//
//  MediaViewController.swift
//  TWU
//
//  Created by Steve Leeke on 7/31/15.
//  Copyright (c) 2015 Steve Leeke. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
//import Social

//extension MediaViewController : UIPopoverPresentationControllerDelegate
//{
//    // MARK: UIPopoverPresentationControllerDelegate
//    
//}

//extension MediaViewController : PopoverTableViewControllerDelegate
//{
//    // MARK: PopoverTableViewControllerDelegate
//    
//    func rowClickedAtIndex(_ index: Int, strings: [String], purpose:PopoverPurpose, sermon:Sermon?) {
//        dismiss(animated: true, completion: nil)
//        
//        switch purpose {
//            
//        case .selectingAction:
//            switch strings[index] {
//            case Constants.Open_Scripture:
//                openScripture(seriesSelected)
//                break
//                
//            case Constants.Open_Series:
//                openSeriesOnWeb(seriesSelected)
//                break
//                
//            case Constants.Download_All:
//                if (seriesSelected?.sermons != nil) {
//                    for sermon in seriesSelected!.sermons! {
//                        sermon.audioDownload?.download()
//                    }
//                }
//                break
//                
//            case Constants.Cancel_All_Downloads:
//                if (seriesSelected?.sermons != nil) {
//                    for sermon in seriesSelected!.sermons! {
//                        sermon.audioDownload?.cancelDownload()
//                    }
//                }
//                break
//                
//            case Constants.Delete_All_Downloads:
//                if (seriesSelected?.sermons != nil) {
//                    for sermon in seriesSelected!.sermons! {
//                        sermon.audioDownload?.deleteDownload()
//                    }
//                }
//                break
//                
//            case Constants.Share:
//                shareHTML(viewController: self, htmlString: "\(seriesSelected!.title!) by Tom Pennington from The Word Unleashed\n\n\(seriesSelected!.url!.absoluteString)")
//                break
//                
//            default:
//                break
//            }
//            break
//            
//        default:
//            break
//        }
//    }
//}

class MediaViewController : UIViewController  {
//    var observerActive = false

//    var sliding = false

//    private var PlayerContext = 0
    
//    @IBOutlet weak var pageControl: UIPageControl!
//    @IBAction func pageControlAction(_ sender: UIPageControl)
//    {
//        flip(self)
//    }
    
//    {
//        get {
//            if sermonSelected != nil {
//                return players[sermonSelected!.playingURL!.absoluteString]
//            } else {
//                return nil
//            }
//        }
//        set {
//            players[sermonSelected!.playingURL!.absoluteString] = newValue
//            sermons[sermonSelected!.playingURL!.absoluteString] = sermonSelected
//        }
//    }

//    {
//        didSet {
//            if let seriesSermons = seriesSelected?.sermons {
//                for sermon in seriesSermons {
//                    if let url = sermon.playingURL {
//                        if players[url.absoluteString] == nil {
//                            players[url.absoluteString] = AVPlayer(url: url)
//                            
//                            players[url.absoluteString]?.currentItem?.addObserver(self,
//                                                                                  forKeyPath: #keyPath(AVPlayerItem.status),
//                                                                                  options: [.old, .new],
//                                                                                  context: nil) // &PlayerContext
//                            
//                            sermons[url.absoluteString] = sermon
//                        }
//                    }
//                }
//            }
//        }
//    }
    
//    override var canBecomeFirstResponder : Bool
//    {
//        return true
//    }
//
//    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?)
//    {
//        if let isCollapsed = splitViewController?.isCollapsed, isCollapsed {
//            globals.motionEnded(motion, event: event)
//        }
//    }

//    @IBOutlet weak var slider: OBSlider!
    
//    fileprivate func adjustAudioAfterUserMovedSlider()
//    {
//        guard (globals.mediaPlayer.player != nil) else {
//            return
//        }
//        
//        if (slider.value < 1.0) {
//            let length = globals.mediaPlayer.duration!.seconds
//            let seekToTime = Double(slider.value) * length
//            
//            globals.mediaPlayer.seek(to: seekToTime)
//            
//            globals.mediaPlayer.playing?.currentTime = seekToTime.description
//        } else {
//            globals.mediaPlayer.pause()
//            
//            globals.mediaPlayer.seek(to: globals.mediaPlayer.duration!.seconds)
//            globals.mediaPlayer.playing?.currentTime = globals.mediaPlayer.duration!.seconds.description
//        }
//        
//        switch globals.mediaPlayer.state! {
//        case .playing:
//            sliding = globals.reachability.isReachable
//            break
//            
//        default:
//            sliding = false
//            break
//        }
//        
//        globals.mediaPlayer.playing?.atEnd = slider.value == 1.0
//        
//        globals.mediaPlayer.startTime = globals.mediaPlayer.playing?.currentTime
//        
//        setupSpinner()
//        setupPlayPauseButton()
//        addSliderObserver()
//    }
    
//    @IBAction func sliderTouchDown(_ sender: UISlider) {
//        //        println("sliderTouchDown")
//        sliding = true
//        removeSliderObserver()
//    }
//    
//    @IBAction func sliderTouchUpOutside(_ sender: UISlider) {
//        //        println("sliderTouchUpOutside")
//        adjustAudioAfterUserMovedSlider()
//    }
//    
//    @IBAction func sliderTouchUpInside(_ sender: UISlider) {
//        //        println("sliderTouchUpInside")
//        adjustAudioAfterUserMovedSlider()
//    }
//    
//    @IBAction func sliderValueChanging(_ sender: UISlider) {
//        setTimeToSlider()
//    }
    
    var views : (seriesArt: UIView?, seriesDescription: UIView?)

//    var sliderObserver: NSTimer?
//    var playObserver: NSTimer?

    var actionButton:UIBarButtonItem?
    
//    fileprivate func showSendMessageErrorAlert() {
//        let sendMessageErrorAlert = UIAlertView(title: "Could Not Send a Message", message: "Your device could not send a text message.  Please check your configuration and try again.", delegate: self, cancelButtonTitle: Constants.Okay)
//        sendMessageErrorAlert.show()
//    }
    
//    fileprivate func message()
//    {
//        
//        let messageComposeViewController = MFMessageComposeViewController()
//        messageComposeViewController.messageComposeDelegate = self // Extremely important to set the --messageComposeDelegate-- property, NOT the --delegate-- property
//        
//        messageComposeViewController.recipients = []
//        messageComposeViewController.subject = Constants.Email_Subject
//        messageComposeViewController.body = setupBody()
//        
//        if MFMailComposeViewController.canSendMail() {
//            self.present(messageComposeViewController, animated: true, completion: nil)
//        } else {
//            self.showSendMailErrorAlert()
//        }
//    }
    
//    fileprivate func showSendMailErrorAlert() {
//        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check your e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
//        sendMailErrorAlert.show()
//    }
    
//    fileprivate func setupBody() -> String {
//        var bodyString = String()
//        
//        bodyString = "I've enjoyed the sermon series \""
//        bodyString = bodyString + seriesSelected!.title!
//        bodyString = bodyString + "\" by Tom Pennington and thought you would enjoy it as well."
//        bodyString = bodyString + "\n\nThis series of sermons is available at "
//        bodyString = bodyString + seriesSelected!.url!.absoluteString
//        
//        return bodyString
//    }
    
    fileprivate func setupBodyHTML(_ series:Series?) -> String? {
        var bodyString:String!
        
        if let url = series?.url, let title = series?.title {
            bodyString = "I've enjoyed the sermon series "
            bodyString = bodyString + "<a href=\"" + url.absoluteString + "\">" + title + "</a>"
            bodyString = bodyString + " by " + "Tom Pennington"
            bodyString = bodyString + " from <a href=\"http://www.thewordunleashed.org\">" + "The Word Unleashed" + "</a>"
            bodyString = bodyString + " and thought you would enjoy it as well."
            bodyString = bodyString + "</br>"
        }
        
        return bodyString
    }
    
    fileprivate func addressStringHTML() -> String
    {
        let addressString:String = "</br>Countryside Bible Church</br>250 Countryside Ct.</br>Southlake, TX 76092</br>(817) 488-5381</br><a href=\"mailto:cbcstaff@countrysidebible.org\">cbcstaff@countrysidebible.org</a></br>www.countrysidebible.org"
        
        return addressString
    }
    
    fileprivate func addressString() -> String
    {
        let addressString:String = "\n\nCountryside Bible Church\n250 Countryside Ct.\nSouthlake, TX 76092\nPhone: (817) 488-5381\nE-mail:cbcstaff@countrysidebible.org\nWeb: www.countrysidebible.org"
        
        return addressString
    }
    
//    fileprivate func emailSeries(_ series:Series?)
//    {
//        let bodyString:String! = setupBodyHTML(series)
//        
////        bodyString = bodyString + addressStringHTML()
//        
//        let mailComposeViewController = MFMailComposeViewController()
//        mailComposeViewController.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
//        
//        mailComposeViewController.setToRecipients([])
//        mailComposeViewController.setSubject(Constants.Email_Subject)
//        //        mailComposeViewController.setMessageBody(bodyString, isHTML: false)
//        mailComposeViewController.setMessageBody(bodyString, isHTML: true)
//        
//        if MFMailComposeViewController.canSendMail() {
//            self.present(mailComposeViewController, animated: true, completion: nil)
//        } else {
//            self.showSendMailErrorAlert()
//        }
//    }
    
//    fileprivate func openSeriesOnWeb(_ series:Series?)
//    {
//        if let url = series?.url {
//            if UIApplication.shared.canOpenURL(url as URL) {
//                UIApplication.shared.openURL(url as URL)
//            } else {
//                networkUnavailable("Unable to open url: \(url)")
//            }
//        }
//    }
    
//    fileprivate func openScripture(_ series:Series?)
//    {
//        guard (series?.scripture != nil) else {
//            return
//        }
//        
//        var urlString = Constants.SCRIPTURE_URL.PREFIX + series!.scripture! + Constants.SCRIPTURE_URL.POSTFIX
//        
//        urlString = urlString.replacingOccurrences(of: " ", with: "+", options: NSString.CompareOptions.literal, range: nil)
//        //        println("\(urlString)")
//        
//        if let url = URL(string:urlString) {
//            if UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.openURL(url)
//            } else {
//                networkUnavailable("Unable to open url: \(url)")
//            }
//            //            if Reachability.isConnectedToNetwork() {
//            //                if UIApplication.sharedApplication().canOpenURL(url) {
//            //                    UIApplication.sharedApplication().openURL(url)
//            //                } else {
//            //                    networkUnavailable("Unable to open url: \(url)")
//            //                }
//            //            } else {
//            //                networkUnavailable("Unable to connect to the internet to open: \(url)")
//            //            }
//        }
//    }
    
//    func twitter()
//    {
//        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
//            var bodyString = String()
//            
//            bodyString = "Great sermon series: \"\(seriesSelected!.title ?? "TITLE")\" by \(Constants.Tom_Pennington).  " + seriesSelected!.url!.absoluteString
//            
//            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
//            twitterSheet.setInitialText(bodyString)
//            self.present(twitterSheet, animated: true, completion: nil)
//        } else {
//            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: Constants.Okay, style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
////        if Reachability.isConnectedToNetwork() {
////            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
////                var bodyString = String()
////                
////                bodyString = "Great sermon series: \"\(globals.seriesSelected!.title)\" by \(Constants.Tom_Pennington).  " + Constants.BASE_WEB_URL + String(globals.seriesSelected!.id)
////                
////                let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
////                twitterSheet.setInitialText(bodyString)
////                self.presentViewController(twitterSheet, animated: true, completion: nil)
////            } else {
////                let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
////                alert.addAction(UIAlertAction(title: Constants.Okay, style: UIAlertActionStyle.Default, handler: nil))
////                self.presentViewController(alert, animated: true, completion: nil)
////            }
////        } else {
////            networkUnavailable("Unable to connect to the internet to tweet.")
////        }
//    }
    
//    func facebook()
//    {
//        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
//            var bodyString = String()
//            
//            bodyString = "Great sermon series: \"\(seriesSelected!.title ?? "TITLE")\" by \(Constants.Tom_Pennington).  " + seriesSelected!.url!.absoluteString
//            
//            //So the user can paste the initialText into the post dialog/view
//            //This is because of the known bug that when the latest FB app is installed it prevents prefilling the post.
//            UIPasteboard.general.string = bodyString
//            
//            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
//            facebookSheet.setInitialText(bodyString)
//            self.present(facebookSheet, animated: true, completion: nil)
//        } else {
//            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: Constants.Okay, style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
////        if Reachability.isConnectedToNetwork() {
////            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
////                var bodyString = String()
////                
////                bodyString = "Great sermon series: \"\(globals.seriesSelected!.title)\" by \(Constants.Tom_Pennington).  " + Constants.BASE_WEB_URL + String(globals.seriesSelected!.id)
////                
////                //So the user can paste the initialText into the post dialog/view
////                //This is because of the known bug that when the latest FB app is installed it prevents prefilling the post.
////                UIPasteboard.generalPasteboard().string = bodyString
////
////                let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
////                facebookSheet.setInitialText(bodyString)
////                self.presentViewController(facebookSheet, animated: true, completion: nil)
////            } else {
////                let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
////                alert.addAction(UIAlertAction(title: Constants.Okay, style: UIAlertActionStyle.Default, handler: nil))
////                self.presentViewController(alert, animated: true, completion: nil)
////            }
////        } else {
////            networkUnavailable("Unable to connect to the internet to post to Facebook.")
////        }
//    }

//    func actions()
//    {
//        //        println("action!")
//        
//        // Put up an action sheet
//        
//    if let navigationController = self.storyboard?.instantiateViewController(withIdentifier: Constants.IDENTIFIER.POPOVER_TABLEVIEW) as? UINavigationController,
//        let popover = navigationController.viewControllers[0] as? PopoverTableViewController {
//            navigationController.modalPresentationStyle = .popover
//            //            popover?.preferredContentSize = CGSizeMake(300, 500)
//            
//            navigationController.popoverPresentationController?.permittedArrowDirections = .up
//            navigationController.popoverPresentationController?.delegate = self
//            
//            navigationController.popoverPresentationController?.barButtonItem = actionButton
//            
//            //                popover.navigationItem.title = "Show"
//            
//            popover.navigationController?.isNavigationBarHidden = true
//            
//            popover.delegate = self
//            popover.purpose = .selectingAction
//            
//            var actionMenu = [String]()
//            
//            if ((seriesSelected?.scripture != nil) && (seriesSelected?.scripture != "") && (seriesSelected?.scripture != Constants.Selected_Scriptures)) {
//                actionMenu.append(Constants.Open_Scripture)
//            }
//
//            actionMenu.append(Constants.Open_Series)
//            
//            if (seriesSelected?.sermons != nil) {
//                var sermonsToDownload = 0
//                var sermonsDownloading = 0
//                var sermonsDownloaded = 0
//                
//                for sermon in seriesSelected!.sermons! {
//                    switch sermon.audioDownload!.state {
//                    case .none:
//                        sermonsToDownload += 1
//                        break
//                    case .downloading:
//                        sermonsDownloading += 1
//                        break
//                    case .downloaded:
//                        sermonsDownloaded += 1
//                        break
//                    }
//                }
//                
//                if (sermonsToDownload > 0) {
//                    actionMenu.append(Constants.Download_All)
//                }
//                
//                if (sermonsDownloading > 0) {
//                    actionMenu.append(Constants.Cancel_All_Downloads)
//                }
//                
//                if (sermonsDownloaded > 0) {
//                    actionMenu.append(Constants.Delete_All_Downloads)
//                }
//            }
//            
//            actionMenu.append(Constants.Share)
//            
//            popover.strings = actionMenu
//            
//            popover.showIndex = false //(globals.grouping == .series)
//            popover.showSectionHeaders = false
//            
//            present(navigationController, animated: true, completion: nil)
//        }
//    }

//    override func viewDidLoad()
//    {
//        // Do any additional setup after loading the view.
//        super.viewDidLoad()
//        
//        //Eliminates blank cells at end.
//        tableView.tableFooterView = UIView()
//        tableView.allowsSelection = true
//        
////        tableView.allowsSelection = true
//
//        // Can't do this or selecting a row doesn't work reliably.
////        tableView.estimatedRowHeight = tableView.rowHeight
////        tableView.rowHeight = UITableViewAutomaticDimension
//    }

//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
//    {
//        super.viewWillTransition(to: size, with: coordinator)
//        
////        if (self.view.window == nil) {
////            return
////        }
//        
//        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
//            self.scrollToSermon(self.sermonSelected, select: true, position: UITableViewScrollPosition.none)
//        }) { (UIViewControllerTransitionCoordinatorContext) -> Void in
//            if let view = self.seriesArtAndDescription.subviews[1] as? UITextView {
//                view.scrollRangeToVisible(NSMakeRange(0, 0))
//            }
//
//            if self.navigationController?.visibleViewController == self {
//                self.navigationController?.isToolbarHidden = true
//                
//                if  let hClass = self.splitViewController?.traitCollection.horizontalSizeClass,
//                    let vClass = self.splitViewController?.traitCollection.verticalSizeClass,
//                    let count = self.splitViewController?.viewControllers.count {
//                    if let navigationController = self.splitViewController?.viewControllers[count - 1] as? UINavigationController {
//                        if (hClass == UIUserInterfaceSizeClass.regular) && (vClass == UIUserInterfaceSizeClass.compact) {
//                            navigationController.topViewController?.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
//                        } else {
//                            navigationController.topViewController?.navigationItem.leftBarButtonItem = nil
//                        }
//                    }
//                }
//            }
//        }
//    }
    
//    fileprivate func setupActionsButton()
//    {
//        if (seriesSelected != nil) {
//            actionButton = UIBarButtonItem(title: Constants.FA.ACTION, style: UIBarButtonItemStyle.plain, target: self, action: #selector(MediaViewController.actions))
//            actionButton?.setTitleTextAttributes([NSFontAttributeName:UIFont(name: Constants.FA.name, size: Constants.FA.FONT_SIZE)!], for: UIControlState())
//            
////            actionButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(MediaViewController.actions))
//            
//            self.navigationItem.rightBarButtonItem = actionButton
//        } else {
//            self.navigationItem.rightBarButtonItem = nil
//            actionButton = nil
//        }
//    }
    
//    func showPlaying()
//    {
//        guard Thread.isMainThread else {
//            return
//        }
//        
//        guard (globals.mediaPlayer.playing != nil) else {
//            return
//        }
//        
//        guard (sermonSelected?.series?.sermons?.index(of: globals.mediaPlayer.playing!) != nil) else {
//            return
//        }
//        
//        sermonSelected = globals.mediaPlayer.playing
//        
//        tableView.reloadData()
//        
//        //Without this background/main dispatching there isn't time to scroll correctly after a reload.
//        
//        DispatchQueue.global(qos: .background).async {
//            DispatchQueue.main.async(execute: { () -> Void in
//                self.scrollToSermon(self.sermonSelected, select: true, position: UITableViewScrollPosition.none)
//            })
//        }
//        
//        updateUI()
//    }
    
//    func deviceOrientationDidChange()
//    {
//        if navigationController?.visibleViewController == self {
//            navigationController?.isToolbarHidden = true
//        }
//    }
    
//    override func viewWillAppear(_ animated: Bool)
//    {
//        super.viewWillAppear(animated)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(MediaViewController.deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(MediaViewController.showPlaying), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.SHOW_PLAYING), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(MediaViewController.updateUI), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.PAUSED), object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(MediaViewController.updateUI), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.FAILED_TO_PLAY), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(MediaViewController.updateUI), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.READY_TO_PLAY), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(MediaViewController.setupPlayPauseButton), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.UPDATE_PLAY_PAUSE), object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(MediaViewController.updateView), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.UPDATE_VIEW), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(MediaViewController.clearView), name: NSNotification.Name(rawValue: Constants.NOTIFICATION.CLEAR_VIEW), object: nil)
//        
//        pageControl.isEnabled = true
//        
//        views = (seriesArt: self.seriesArt, seriesDescription: self.seriesDescription)
//        
//        if (seriesSelected == nil) { //  && (globals.seriesSelected != nil)
//            // Should only happen on an iPad on initial startup, i.e. when this view initially loads, not because of a segue.
//            seriesSelected = globals.seriesSelected
//        }
//        
//        sermonSelected = seriesSelected?.sermonSelected
//
//        if (sermonSelected == nil) && (seriesSelected != nil) && (seriesSelected == globals.mediaPlayer.playing?.series) {
//            sermonSelected = globals.mediaPlayer.playing
//        }
//
//        updateUI()
//        
////        println("\(globals.mediaPlayer.currentTime)")
//        
//    }
    
//    override func viewDidAppear(_ animated: Bool)
//    {
//        super.viewDidAppear(animated)
//
////        print("Series Selected: \(seriesSelected?.title) Playing: \(globals.mediaPlayer.playing?.series?.title)")
////        print("Sermon Selected: \(sermonSelected?.series?.title)")
//        
//        //Without this background/main dispatching there isn't time to scroll correctly after a reload.
//        DispatchQueue.global(qos: .userInitiated).async(execute: { () -> Void in
//            DispatchQueue.main.async(execute: { () -> Void in
//                self.scrollToSermon(self.sermonSelected, select: true, position: UITableViewScrollPosition.none)
//            })
//        })
//        
//        if globals.isLoading && (navigationController?.visibleViewController == self) && (splitViewController?.viewControllers.count == 1) {
//            if let navigationController = splitViewController?.viewControllers[0] as? UINavigationController {
//                navigationController.popToRootViewController(animated: false)
//            }
//        }
//    }
    
//    override func viewWillDisappear(_ animated: Bool)
//    {
//        super.viewWillDisappear(animated)
//        
//        removeSliderObserver()
//        removePlayerObserver()
//        
////        for player in players.values {
////            player.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: nil)
////        }
//        
//        NotificationCenter.default.removeObserver(self)
//        
//        sliderObserver?.invalidate()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func flipFromLeft(_ sender: MediaViewController)
//    {
//        //        println("tap")
//        
//        // set a transition style
//        let transitionOptions = UIViewAnimationOptions.transitionFlipFromLeft
//        
//        if let view = self.seriesArtAndDescription.subviews[0] as? UITextView {
//            view.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
//            //            view.scrollRangeToVisible(NSMakeRange(0, 0))  // snaps in to place because it animates by default
//        }
//        
//        UIView.transition(with: self.seriesArtAndDescription, duration: Constants.INTERVAL.VIEW_TRANSITION_TIME, options: transitionOptions, animations: {
//            //            println("\(self.seriesArtAndDescription.subviews.count)")
//            //The following assumes there are only 2 subviews, 0 and 1, and this alternates between them.
//            let frontView = self.seriesArtAndDescription.subviews[0]
//            let backView = self.seriesArtAndDescription.subviews[1]
//            
//            frontView.isHidden = false
//            self.seriesArtAndDescription.bringSubview(toFront: frontView)
//            backView.isHidden = true
//            
//            if frontView == self.seriesArt {
//                self.pageControl.currentPage = 0
//            }
//            
//            if frontView == self.seriesDescription {
//                self.pageControl.currentPage = 1
//            }
//            
//            }, completion: { finished in
//                
//        })
//        
//    }
    
//    func flipFromRight(_ sender: MediaViewController)
//    {
//        //        println("tap")
//        
//        // set a transition style
//        let transitionOptions = UIViewAnimationOptions.transitionFlipFromRight
//        
//        if let view = self.seriesArtAndDescription.subviews[0] as? UITextView {
//            view.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
//            //            view.scrollRangeToVisible(NSMakeRange(0, 0))  // snaps in to place because it animates by default
//        }
//        
//        UIView.transition(with: self.seriesArtAndDescription, duration: Constants.INTERVAL.VIEW_TRANSITION_TIME, options: transitionOptions, animations: {
//            //            println("\(self.seriesArtAndDescription.subviews.count)")
//            //The following assumes there are only 2 subviews, 0 and 1, and this alternates between them.
//            let frontView = self.seriesArtAndDescription.subviews[0]
//            let backView = self.seriesArtAndDescription.subviews[1]
//            
//            frontView.isHidden = false
//            self.seriesArtAndDescription.bringSubview(toFront: frontView)
//            backView.isHidden = true
//            
//            if frontView == self.seriesArt {
//                self.pageControl.currentPage = 0
//            }
//            
//            if frontView == self.seriesDescription {
//                self.pageControl.currentPage = 1
//            }
//            
//            }, completion: { finished in
//                
//        })
//        
//    }
    
//    func flip(_ sender: MediaViewController)
//    {
//        //        println("tap")
//        
//        // set a transition style
////        var transitionOptions:UIViewAnimationOptions!
//        
//        let frontView = self.seriesArtAndDescription.subviews[0]
//        let backView = self.seriesArtAndDescription.subviews[1]
//        
////        if frontView == self.seriesArt {
////            transitionOptions = UIViewAnimationOptions.transitionFlipFromRight
////        }
////        
////        if frontView == self.seriesDescription {
////            transitionOptions = UIViewAnimationOptions.transitionFlipFromLeft
////        }
//
//        if let view = self.seriesArtAndDescription.subviews[0] as? UITextView {
//            view.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
//            //            view.scrollRangeToVisible(NSMakeRange(0, 0))  // snaps in to place because it animates by default
//        }
//
//        frontView.isHidden = false
//        self.seriesArtAndDescription.bringSubview(toFront: frontView)
//        backView.isHidden = true
//
//        if frontView == self.seriesArt {
//            self.pageControl.currentPage = 0
//        }
//        
//        if frontView == self.seriesDescription {
//            self.pageControl.currentPage = 1
//        }
//
////        UIView.transition(with: self.seriesArtAndDescription, duration: Constants.INTERVAL.VIEW_TRANSITION_TIME, options: transitionOptions, animations: {
////            //            println("\(self.seriesArtAndDescription.subviews.count)")
////            //The following assumes there are only 2 subviews, 0 and 1, and this alternates between them.
////            frontView.isHidden = false
////            self.seriesArtAndDescription.bringSubview(toFront: frontView)
////            backView.isHidden = true
////            
////            if frontView == self.seriesArt {
////                self.pageControl.currentPage = 0
////            }
////            
////            if frontView == self.seriesDescription {
////                self.pageControl.currentPage = 1
////            }
////
////            }, completion: { finished in
////                
////        })
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        var destination = segue.destination as UIViewController
        // this next if-statement makes sure the segue prepares properly even
        //   if the MVC we're seguing to is wrapped in a UINavigationController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
//        if let avpc = destination as? UIViewController? {
//            if let identifier = segue.identifier {
//                switch identifier {
//                case "Show Sermon":
//                    if let myCell = sender as? MediaTableViewCell {
//                        let indexPath = seriesSermons!.indexPathForCell(myCell)
//
//                    }
//                    break
//                default:
//                    break
//                }
//            }
//        }
    }

//    fileprivate func setTimeToSlider()
//    {
//        guard (globals.mediaPlayer.duration != nil) else {
//            return
//        }
//        
//        let length = Float(globals.mediaPlayer.duration!.seconds)
//        
//        let timeNow = self.slider.value * length
//        
//        setTimes(timeNow: Double(timeNow),length: Double(length))
//    }
    
//    fileprivate func networkUnavailable(_ message:String?)
//    {
//        if (UIApplication.shared.applicationState == UIApplicationState.active) { // && (self.view.window != nil)
//            dismiss(animated: true, completion: nil)
//            
//            let alert = UIAlertController(title: Constants.Network_Error,
//                message: message,
//                preferredStyle: UIAlertControllerStyle.alert)
//            
//            let action = UIAlertAction(title: Constants.Cancel, style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) -> Void in
//                
//            })
//            alert.addAction(action)
//            
//            present(alert, animated: true, completion: nil)
//        }
//    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
