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
        
        if (self.characters.count == 0) {
            return "en_US"
        } else if (self.characters.count < 100) {
            return CFStringTokenizerCopyBestStringLanguage(self as CFString, CFRangeMake(0, self.characters.count)) as String;
        } else {
            return CFStringTokenizerCopyBestStringLanguage(self as CFString, CFRangeMake(0, 100)) as String;
        }
    }
}

extension NSSpeechSynthesizer {
    
    class func bestVoiceForString(string: String) -> String? {
        
        let language = string.languageForString
        
        var voice: String?
        
        if  language.hasPrefix("en") {
            voice = NSSpeechSynthesizer.defaultVoice()
        } else {
            voice = NSSpeechSynthesizer.availableVoices().filter() { NSSpeechSynthesizer.attributesForVoice($0)[NSVoiceLocaleIdentifier]!.hasPrefix(language) }.first ?? voice
        }
        
        return voice;
    }
    
}

extension MusicTrack {
    
    func announce(synthesizer: NSSpeechSynthesizer) {
        
        guard let artist = self.artist else {
            return;
        }
        
        let voice = findBestVoice()
        
        synthesizer.rate = 200;
        synthesizer.volume = 1;
        synthesizer.setVoice(voice)
        
        var textToSpeak = artist
        if let title = self.title {
            textToSpeak += ", " + title
            
            let voice = NSSpeechSynthesizer.bestVoiceForString(title)
            synthesizer.setVoice(voice)
        } else {
            synthesizer.setVoice(nil)
        }
        
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
        
        guard let title = self.title else {
            return nil;
        }
        
        return NSSpeechSynthesizer.bestVoiceForString(title);
    }
}