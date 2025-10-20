//
//  PreferencesWindow.swift
//  NoMAD
//
//  Created by Joel Rennich on 4/21/16.
//  Copyright © 2016 Trusource Labs. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func doTheNeedfull()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {

    var delegate: PreferencesWindowDelegate?

    // The UI controls are connected with simple SharedDefaults bindings.
    // This means that they stay syncronized with the Defaults system and we
    // don't need to get into messing with state checking when loading the window.

    @IBOutlet weak var ADDomainTextField: NSTextField!
    @IBOutlet weak var KerberosRealmField: NSTextField!
    @IBOutlet weak var x509CAField: NSTextField!
    @IBOutlet weak var TemplateField: NSTextField!
    @IBOutlet weak var ButtonNameField: NSTextField!
    @IBOutlet weak var HotKeyField: NSTextField!
    @IBOutlet weak var CommandField: NSTextField!
    @IBOutlet weak var SecondsToRenew: NSTextField!
    
    // Local Password Sync text fields
    @IBOutlet weak var LocalPasswordSyncDontSyncLocalUsersField: NSTextField!
    @IBOutlet weak var LocalPasswordSyncDontSyncNetworkUsersField: NSTextField!
    
    // Help configuration fields
    @IBOutlet weak var GetHelpTypePopUp: NSPopUpButton!
    @IBOutlet weak var GetHelpOptionsField: NSTextField!

    // Check boxes
    @IBOutlet weak var UseKeychain: NSButton!
    @IBOutlet weak var RenewTickets: NSButton!
    @IBOutlet weak var ShowHome: NSButton!
    
    // Local Password Sync options
    @IBOutlet weak var LocalPasswordSync: NSButton!
    @IBOutlet weak var LocalPasswordSyncOnMatchOnly: NSButton!
    @IBOutlet weak var LocalPasswordSyncDontSyncLocalUsers: NSButton!
    @IBOutlet weak var LocalPasswordSyncDontSyncNetworkUsers: NSButton!

    override var windowNibName: NSNib.Name? {
        return NSNib.Name("PreferencesWindow")
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
        
        // Set default values for Local Password Sync preferences if they don't exist
        setLocalPasswordSyncDefaults()
        
        // Load array preferences into text fields as comma-separated strings
        loadUserListArraysIntoTextFields()
        
        // Set up help type popup
        setupHelpTypePopUp()
        
        self.disableManagedPrefs()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {

        // Make sure we have an AD Domain. Either require the user to enter one
        // or quit.
        if ADDomainTextField.stringValue == "" {
            let alertController = NSAlert()
            alertController.messageText = "The AD Domain needs to be filled out."
            alertController.addButton(withTitle: "OK")
            alertController.addButton(withTitle: "Quit NoMAD")
            alertController.beginSheetModal(for: self.window!) { response in
                if response.rawValue == 1001 {
                    NSApp.terminate(self)
                }
            }
            return false
        }
        return true
    }

    func windowWillClose(_ notification: Notification) {
        // Force any active text field to save its value
        self.window?.makeFirstResponder(nil)
        
        // Convert text fields back to arrays and save
        convertUserListTextFieldsToArrays()
        
        // If no Kerberos realm has been entered, assume it's the same as the AD Domain.
        if KerberosRealmField.stringValue == "" {
            defaults.set(ADDomainTextField.stringValue.uppercased(), forKey: Preferences.kerberosRealm)
        }

        // double check that we have a Kerberos Realm

        if defaults.string(forKey: Preferences.kerberosRealm) == "" || defaults.string(forKey: Preferences.kerberosRealm) == nil {
            defaults.set(defaults.string(forKey: Preferences.aDDomain)?.uppercased(), forKey: Preferences.kerberosRealm)
        }

        // update the Chrome configuration

        if defaults.bool(forKey: Preferences.configureChrome) {
            configureChrome()
        }

        NotificationCenter.default.post(updateNotification)
    }

    /// Disable the UI for managed preferences.
    ///
    /// Because of naming disparities we are cycling through the controls in
    /// the `contentView` of the window and looking at their `identifier` keys.
    /// These keys are set to the same string as the preference value they
    /// control.
    func disableManagedPrefs() {
        guard let controls = self.window?.contentView?.subviews else {
            myLogger.logit(.debug, message: "Preference window somehow drew without any controls.")
            return
        }
        //MARK: TODO This smells to be overly clever. We should find a simpler way.
        for object in controls {
            let identifier = object.identifier
            if defaults.objectIsForced(forKey: identifier!.rawValue) {
                switch object.className {
                case "NSTextField":
                    let textField = object as! NSTextField
                    textField.isEnabled = false
                case "NSButton":
                    let button = object as! NSButton
                    button.isEnabled = false
                default:
                    return
                }
            }
        }
    }

    func configureChrome() {

        // create new instance of defaults for com.google.Chrome

        let chromeDefaults = UserDefaults.init(suiteName: "com.google.Chrome")
        var chromeDomain = defaults.string(forKey: Preferences.configureChromeDomain) ?? defaults.string(forKey: Preferences.aDDomain)!

        // add the wildcard

        chromeDomain = "*" + chromeDomain

        var change = false

        // find the keys and add the domain

        let chromeAuthServer = chromeDefaults?.string(forKey: "AuthServerWhitelist")
        var chromeAuthServerArray = chromeAuthServer?.components(separatedBy: ",")

        if chromeAuthServerArray != nil {
            if !((chromeAuthServerArray?.contains(chromeDomain))!) {
                chromeAuthServerArray?.append(chromeDomain)
                change = true
            }
        } else {
            chromeAuthServerArray = [chromeDomain]
            change = true
        }

        let chromeAuthNegotiate = chromeDefaults?.string(forKey: "AuthNegotiateDelegateWhitelist")
        var chromeAuthNegotiateArray = chromeAuthNegotiate?.components(separatedBy: ",")

        if chromeAuthNegotiateArray != nil {
            if !((chromeAuthNegotiateArray?.contains(chromeDomain))!) {
                chromeAuthNegotiateArray?.append(chromeDomain)
                change = true
            }
        } else {
            chromeAuthNegotiateArray = [chromeDomain]
            change = true
        }

        // write it back

        if change {
            chromeDefaults?.set(chromeAuthServerArray?.joined(separator: ","), forKey: "AuthServerWhitelist")
            chromeDefaults?.set(chromeAuthNegotiateArray?.joined(separator: ","), forKey: "AuthNegotiateDelegateWhitelist")
        }
    }
    
    // MARK: - Local Password Sync Helper Methods
    
    /// Set default values for Local Password Sync preferences if they don't exist
    func setLocalPasswordSyncDefaults() {
        // Register defaults for our new preferences
        let localPasswordSyncDefaults: [String: Any] = [
            Preferences.localPasswordSync: false,
            Preferences.localPasswordSyncOnMatchOnly: false,
            Preferences.localPasswordSyncDontSyncLocalUsers: [],
            Preferences.localPasswordSyncDontSyncNetworkUsers: []
        ]
        
        defaults.register(defaults: localPasswordSyncDefaults)
        
        // Also set up help defaults if they don't exist
        setupHelpDefaults()
    }
    
    /// Set up default help configuration
    func setupHelpDefaults() {
        let helpDefaults: [String: Any] = [
            Preferences.getHelpType: "URL",
            Preferences.getHelpOptions: "http://www.apple.com/support"
        ]
        
        defaults.register(defaults: helpDefaults)
    }
    
    /// Load user list arrays from preferences into text fields as comma-separated strings
    func loadUserListArraysIntoTextFields() {
        // Load LocalPasswordSyncDontSyncLocalUsers array into text field
        if let localUsers = defaults.array(forKey: Preferences.localPasswordSyncDontSyncLocalUsers) as? [String] {
            LocalPasswordSyncDontSyncLocalUsersField?.stringValue = localUsers.joined(separator: ", ")
        }
        
        // Load LocalPasswordSyncDontSyncNetworkUsers array into text field  
        if let networkUsers = defaults.array(forKey: Preferences.localPasswordSyncDontSyncNetworkUsers) as? [String] {
            LocalPasswordSyncDontSyncNetworkUsersField?.stringValue = networkUsers.joined(separator: ", ")
        }
    }
    
    /// Convert comma-separated text fields back to arrays in preferences
    func convertUserListTextFieldsToArrays() {
        // Convert LocalPasswordSyncDontSyncLocalUsers text field to array
        if let localUsersField = LocalPasswordSyncDontSyncLocalUsersField {
            let localUsersString = localUsersField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !localUsersString.isEmpty {
                let localUsersArray = localUsersString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                defaults.set(localUsersArray, forKey: Preferences.localPasswordSyncDontSyncLocalUsers)
            } else {
                defaults.set([], forKey: Preferences.localPasswordSyncDontSyncLocalUsers)
            }
        }
        
        // Convert LocalPasswordSyncDontSyncNetworkUsers text field to array
        if let networkUsersField = LocalPasswordSyncDontSyncNetworkUsersField {
            let networkUsersString = networkUsersField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !networkUsersString.isEmpty {
                let networkUsersArray = networkUsersString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                defaults.set(networkUsersArray, forKey: Preferences.localPasswordSyncDontSyncNetworkUsers)
            } else {
                defaults.set([], forKey: Preferences.localPasswordSyncDontSyncNetworkUsers)
            }
        }
    }
    
    // MARK: - Help Configuration Helper Methods
    
    /// Set up the help type popup button
    func setupHelpTypePopUp() {
        // Don't populate items here if using bindings - they should be set in IB
        // But ensure we have the current value loaded
        if GetHelpTypePopUp?.itemTitles.isEmpty == true {
            GetHelpTypePopUp?.addItems(withTitles: ["URL", "Path", "App"])
        }
        
        // Set current selection
        let currentType = defaults.string(forKey: Preferences.getHelpType) ?? "URL"
        GetHelpTypePopUp?.selectItem(withTitle: currentType)
        
        // Set current help options
        GetHelpOptionsField?.stringValue = defaults.string(forKey: Preferences.getHelpOptions) ?? "http://www.apple.com/support"
        
        // Set initial placeholder
        updateHelpOptionsPlaceholder(currentType)
    }
    
    /// Update placeholder text for help options field
    func updateHelpOptionsPlaceholder(_ selectedType: String) {
        switch selectedType {
        case "URL":
            GetHelpOptionsField?.placeholderString = "https://your-company.atlassian.net/wiki/spaces/IT/pages/macOS-Support"
        case "Path":
            GetHelpOptionsField?.placeholderString = "/usr/bin/open /Applications/Remote Desktop.app"
        case "App":
            GetHelpOptionsField?.placeholderString = "/Applications/Remote Desktop.app"
        default:
            GetHelpOptionsField?.placeholderString = ""
        }
    }
    
    /// Handle help type popup selection change
    @IBAction func helpTypeChanged(_ sender: NSPopUpButton) {
        let selectedType = sender.selectedItem?.title ?? "URL"
        defaults.set(selectedType, forKey: Preferences.getHelpType)
        
        // Update placeholder text
        updateHelpOptionsPlaceholder(selectedType)
    }
    
    /// Handle help options field change
    @IBAction func helpOptionsChanged(_ sender: NSTextField) {
        defaults.set(sender.stringValue, forKey: Preferences.getHelpOptions)
    }
}
