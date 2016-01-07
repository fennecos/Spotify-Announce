//
//  Spotify.swift
//  SpotifyAnnounce
//
//  Created by Emmanuel Garnier on 07/01/16.
//
//

import Cocoa

extension MusicTrack {
    
    init(spotifyNotification: NSNotification) {
        self.init()
        
        let information = spotifyNotification.userInfo!
        
        self.playerState = information["Player State"] as? String
        self.title = information["Name"] as? String
        self.artist = information["Artist"] as? String
        self.album = information["Album"] as? String
        self.id = information["Track ID"] as? String
    }
    
    func downloadedImageFromSpotify(completion: (NSImage? -> Void)) {
        
        let idPrefix = "spotify:track:"
        guard var trackID = self.id else {
            dispatch_async(dispatch_get_main_queue()) { completion(nil) }
            return
        }
        
        if trackID.hasPrefix(idPrefix) {
            let prefixRange = trackID.startIndex..<trackID.startIndex.advancedBy(idPrefix.characters.count)
            trackID.removeRange(prefixRange)
        }
        
        let imageUrl = "https://api.spotify.com/v1/tracks/" + trackID
        
        guard let url = NSURL(string: imageUrl) else {
            dispatch_async(dispatch_get_main_queue()) { completion(nil) }
            return
        }
        
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, _, error) -> Void in
            guard
                let data = data where error == nil,
                let json = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments),
                let artworkURL = self.findImageInSpotifyJson(json) else {
                    dispatch_async(dispatch_get_main_queue()) { completion(nil) }
                    return
            }
            
            self.downloadImage(artworkURL, completion: completion)
            
        }).resume()
    }
    
    private func findImageInSpotifyJson(json: AnyObject) -> NSURL? {
        if
            let album = json["album"] as? [String: AnyObject],
            let images = album["images"] as? [[String: AnyObject]],
            let smallestImage = images.sort({ (first, second) -> Bool in
                guard let firstHeight = first["height"] as? Int, let secondHeight = second["height"] as? Int else {
                    return false
                }
                return firstHeight > secondHeight
            }).last,
            let artworkUrlString = smallestImage["url"] as? String, let artworkUrl = NSURL(string: artworkUrlString) {
                return artworkUrl
        }
        
        return nil
    }
    
    private func downloadImage(url: NSURL, completion: (NSImage? -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, _, error) -> Void in
            guard let data = data where error == nil else {
                dispatch_async(dispatch_get_main_queue()) { completion(nil) }
                return
            }
            let downloadedImage = NSImage(data: data)
            
            dispatch_async(dispatch_get_main_queue()) { completion(downloadedImage) }
        }).resume()
    }
}