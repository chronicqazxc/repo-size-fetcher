//
//  ViewController.swift
//  GithubReader
//
//  Created by Wayne, Xiao X. -ND on 6/12/17.
//  Copyright © 2017 Wayne, Xiao X. -ND. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var orginizationLabel: NSTextField! {
        didSet {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NSControlTextDidChange, object: orginization, queue: nil) { [weak self] (notification) in
                if self?.orginization.stringValue == "" {
                    self?.orginizationLabel.stringValue = ""
                } else {
                    self?.orginizationLabel.stringValue = "Orginization"
                }
            }
        }
    }
    
    @IBOutlet weak var repoLabel: NSTextField! {
        didSet {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NSControlTextDidChange, object: repo, queue: nil) { [weak self] (notification) in
                if self?.repo.stringValue == "" {
                    self?.repoLabel.stringValue = ""
                } else {
                    self?.repoLabel.stringValue = "Repo"
                }
            }
        }
    }
    
    @IBOutlet weak var usernameLabel: NSTextField! {
        didSet {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NSControlTextDidChange, object: username, queue: nil) { [weak self] (notification) in
                if self?.username.stringValue == "" {
                    self?.usernameLabel.stringValue = ""
                } else {
                    self?.usernameLabel.stringValue = "Username"
                }
            }
        }
    }
    
    @IBOutlet weak var tokenLabel: NSTextField! {
        didSet {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NSControlTextDidChange, object: token, queue: nil) { [weak self] (notification) in
                if self?.token.stringValue == "" {
                    self?.tokenLabel.stringValue = ""
                } else {
                    self?.tokenLabel.stringValue = "Token"
                }
            }
        }
    }
    
    @IBOutlet weak var orginization: NSTextField! {
        didSet {
            orginization.delegate = self
        }
    }
    
    @IBOutlet weak var repo: NSTextField! {
        didSet {
            repo.delegate = self
        }
    }
    
    @IBOutlet weak var username: NSTextField! {
        didSet {
            username.delegate = self
        }
    }
    
    @IBOutlet weak var token: NSSecureTextField! {
        didSet {
            token.delegate = self
        }
    }
    
    var logFont: NSFont {
        get {
            return NSFont(name: "Avenir-Roman", size: 16.0) ?? NSFont.systemFont(ofSize: 16.0)
        }
    }
    
    @IBOutlet var result: NSTextView! {
        didSet {
            result.textColor = NSColor.white
            result.font = logFont
        }
    }
    
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    @IBOutlet weak var version: NSTextField! {
        didSet {
            version.stringValue = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        }
    }
    
    @IBOutlet weak var fetchButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        indicator.startAnimation(nil)
        // Do any additional setup after loading the view.
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func fetch(_ sender: Any) {
        indicator.isHidden = false
        
        if let control = sender as? NSControl {
            control.isEnabled = false
        }
        
        let fetchRequest = FetchRequest(orginization: orginization.stringValue,
                                        repo: repo.stringValue,
                                        username: username.stringValue,
                                        token: token.stringValue)
        
        let fetchHelper = FetchHelper(request: fetchRequest)
        
        fetchHelper.fetch { [weak self] in
            guard let strongself = self else { return }
            
            strongself.indicator.isHidden = true
            
            if let control = sender as? NSControl {
                control.isEnabled = true
            }

            strongself.result.textStorage?.append(NSAttributedString(string: $0, attributes: [NSForegroundColorAttributeName : NSColor.white,
                                                                                              NSFontAttributeName : strongself.logFont]))
        }
    }
    
    @IBAction func open(_ sender: Any) {
        if let button = sender as? NSButton, let url = URL(string: button.title) {
            NSWorkspace.shared().open(url)
        }
    }

    override func controlTextDidEndEditing(_ obj: Notification) {
        if let number = obj.userInfo?["NSTextMovement"] as? NSNumber, number.intValue == NSReturnTextMovement {
            if fetchButton.isEnabled == true {
                fetch(fetchButton)
            }
        }
    }
}

