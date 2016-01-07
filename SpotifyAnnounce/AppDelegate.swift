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
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: "updateTrackInfoFromSpotify:", name: "com.spotify.client.PlaybackStateChanged", object: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
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
            track.announce(self.synthesizer)
        }
    }
}