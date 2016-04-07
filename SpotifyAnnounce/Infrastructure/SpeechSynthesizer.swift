//
//  SpeechSynthesizer.swift
//  SpotifyAnnounce
//
//  Created by Emmanuel Garnier on 07/01/16.
//
//

import Cocoa

extension String {
    
    var languageForString:String {
        var language = "en_US"
        
        if !self.isEmpty {
            let range = CFRangeMake(0, min(self.characters.count, 100))
            if let bestLanguage =  CFStringTokenizerCopyBestStringLanguage(self as CFString, range) as String? {
                language = bestLanguage
            }
        }
        return language
    }
}

extension NSSpeechSynthesizer {
    
    class func bestVoiceForString(string: String) -> String? {
        let language = string.languageForString
        
        var voice: String?
        
        if  language.hasPrefix("en") {
            voice = NSSpeechSynthesizer.defaultVoice()
        } else {
            voice = NSSpeechSynthesizer.availableVoices().filter() { NSSpeechSynthesizer.attributesForVoice($0)[NSVoiceLocaleIdentifier]?.hasPrefix(language) == true }.first ?? voice
        }
        
        return voice;
    }
    
}

extension MusicTrack {
    
    func announce(synthesizer: NSSpeechSynthesizer) {
        var stringsToSpeak = [String]()
        
        if let artist = artist {
            stringsToSpeak.append(artist)
        }
        if let title = title {
            stringsToSpeak.append(title)
        }
        let textToSpeak = stringsToSpeak.joinWithSeparator(", ")
    
        let voice = findBestVoice()
        
        synthesizer.rate = 200;
        synthesizer.volume = 1;
        synthesizer.setVoice(voice)
        synthesizer.startSpeakingString(textToSpeak)
    }

    func presentNotification() {
        let notification = NSUserNotification()
        
        notification.title = title
        notification.subtitle = album
        notification.informativeText = artist
        notification.contentImage = artwork
        
        NSUserNotificationCenter.defaultUserNotificationCenter().removeAllDeliveredNotifications()
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    
    private func findBestVoice() -> String? {
        guard let title = title else {
            return nil;
        }
        
        return NSSpeechSynthesizer.bestVoiceForString(title);
    }
}