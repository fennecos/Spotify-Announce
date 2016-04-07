//
//  AppDelegate.swift
//  SpotifyAnnounce
//
//  Created by Emmanuel Garnier on 04/01/16.
//
//

import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let synthesizer = NSSpeechSynthesizer()
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        NSUserDefaults.standardUserDefaults().registerDefaults()
        
        setUpStatusBarItem()
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.updateTrackInfoFromSpotify(_:)), name: "com.spotify.client.PlaybackStateChanged", object: nil)
    }


    func updateTrackInfoFromSpotify(notification: NSNotification) {
        synthesizer.stopSpeakingAtBoundary(.WordBoundary)
        
        var track = MusicTrack(spotifyNotification: notification)
        
        if track.playerState != "Playing" {
            return;
        }
        
        track.downloadedImageFromSpotify() { (image) -> Void in
            track.artwork = image
            
            track.presentNotification()
            
            if NSUserDefaults.standardUserDefaults().vocalAnnounceEnabled {
                track.announce(self.synthesizer)
            }
        }
    }
    
    // MARK: Status Bar
    
    func setUpStatusBarItem() {
        let icon = NSImage(named: "ic_status_bar")
        icon?.template = true
        
        statusItem.image = icon
        statusItem.menu = statusMenu
    }
    
    @IBAction func toggleVocalAnnounce(item: NSMenuItem) {
        let enabled = NSUserDefaults.standardUserDefaults().vocalAnnounceEnabled
        NSUserDefaults.standardUserDefaults().vocalAnnounceEnabled = !enabled
    }
    
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(AppDelegate.toggleVocalAnnounce) {
            menuItem.state = NSUserDefaults.standardUserDefaults().vocalAnnounceEnabled == true ? NSOnState: NSOffState
        }
        return true;
    }
}

extension NSUserDefaults {
    struct NSUserDefaultsKeys {
        static let vocalAnnounceEnabledKey = "vocalAnnounceEnabled"
    }
    
    var vocalAnnounceEnabled: Bool {
        get {
            let enabled = NSUserDefaults.standardUserDefaults().boolForKey(NSUserDefaultsKeys.vocalAnnounceEnabledKey)
            
            return enabled
        }
        set {
             NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: NSUserDefaultsKeys.vocalAnnounceEnabledKey)
        }
    }
    
    func registerDefaults() {
        self.registerDefaults([NSUserDefaultsKeys.vocalAnnounceEnabledKey: true])
    }
}