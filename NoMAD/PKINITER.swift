//
//  PKINITER.swift
//  NoMAD
//
//  Created by Joel Rennich on 2/11/17.
//  Copyright © 2017 Trusource Labs. All rights reserved.
//

import Foundation

// helper functions if NoMAD is being used with PKINITER

//
// Find out if PKINITER is stashed in the App bundle
//

func findPKINITer() -> Bool {

    let selfServiceFileManager = FileManager.default
    let bundlePath = Bundle.main.resourcePath
    print("***" + bundlePath! + "***")
    if selfServiceFileManager.fileExists(atPath: bundlePath! + "/PKINITer.app") {
        myLogger.logit(.info, message:"Enabling PKINIT functionality")
        return true
    } else {
        return false
    }
}

//
// Launch PKINITer with the -nomad flag to slightly change behavior
//

func launchPKINITer() {

        let selfServiceFileManager = FileManager.default
        let bundlePath = Bundle.main.resourcePath

        // build the options
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.arguments = ["-nomad", "-n", defaults.string(forKey: Preferences.userPrincipal)!]
    configuration.activates = false
    let pkinitPathURL = URL(fileURLWithPath: bundlePath! + "/PKINITer.app")

    NSWorkspace.shared.openApplication(at: pkinitPathURL, configuration: configuration) { (app, error) in
        if let error = error {
            myLogger.logit(.base, message: "Unable to launch PKINITer: \(error)")
        }
    }
    
}
