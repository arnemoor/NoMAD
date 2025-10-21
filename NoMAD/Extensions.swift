//
//  Extensions.swift
//  NoMAD
//
//  Created by Boushy, Phillip on 10/4/16.
//  Copyright © 2016 Trusource Labs. All rights reserved.
//

import Foundation

extension NSWindow {
    func forceToFrontAndFocus(_ sender: AnyObject?) {
        NSApp.activate(ignoringOtherApps: true)
        self.makeKeyAndOrderFront(sender);
    }
}

extension String {
    var translate: String {
        return Localizator.sharedInstance.translate(self)
    }

    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }

    func containsIgnoringCase(_ find: String) -> Bool {
        return self.range(of: find, options: NSString.CompareOptions.caseInsensitive) != nil
    }

}

// Global helper to get localized text with optional preference override
// This ensures consistent behavior: preference override > Languages.plist translation
func localizedMenuTitle(key: String, preferenceKey: String) -> String {
    let defaults = UserDefaults.standard
    if let customText = defaults.string(forKey: preferenceKey), !customText.isEmpty {
        return customText
    }
    return key.translate
}
