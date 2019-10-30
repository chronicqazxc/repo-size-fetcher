//
//  ViewController.swift
//  GithubReader
//
//  Created by Wayne, Hsiao on 6/12/17.
//  Copyright © 2017 Wayne, Hsiao. All rights reserved.
//

import Cocoa

class Status {
    enum Select: Int {
        case orgnization = 1, githubUrl
    }
    
    var currentSelect: Select = .orgnization
    
    init(currentSelect: Select) {
        self.currentSelect = currentSelect
    }
    
}

class ViewController: NSViewController, NSTextFieldDelegate, NSTabViewDelegate {
    
    var selectStatus = Status(currentSelect: .orgnization)
    
    @IBOutlet weak var tabView: NSTabView! {
        didSet {
            tabView.delegate = self
        }
    }
    
    @IBOutlet weak var gitUrlLabel: NSTextField! {
        didSet {
            gitUrlLabel.stringValue = ""
            
            NotificationCenter.default.addObserver(forName: NSControl.textDidChangeNotification, object: gitUrl, queue: nil) { [weak self] (notification) in
                if self?.gitUrl.stringValue == "" {
                    self?.gitUrlLabel.stringValue = ""
                } else {
                    self?.gitUrlLabel.stringValue = "Git URL"
                }
            }
        }
    }
    
    @IBOutlet weak var orginizationLabel: NSTextField! {
        didSet {
            NotificationCenter.default.addObserver(forName: NSControl.textDidChangeNotification, object: orginization, queue: nil) { [weak self] (notification) in
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
            repoLabel.becomeFirstResponder()
            
            NotificationCenter.default.addObserver(forName: NSControl.textDidChangeNotification, object: repo, queue: nil) { [weak self] (notification) in
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
            NotificationCenter.default.addObserver(forName: NSControl.textDidChangeNotification, object: username, queue: nil) { [weak self] (notification) in
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
            NotificationCenter.default.addObserver(forName: NSControl.textDidChangeNotification, object: token, queue: nil) { [weak self] (notification) in
                if self?.token.stringValue == "" {
                    self?.tokenLabel.stringValue = ""
                } else {
                    self?.tokenLabel.stringValue = "Token"
                }
            }
        }
    }
    
    @IBOutlet weak var gitUrl: NSTextField! {
        didSet {
            gitUrl.delegate = self
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
    
    @IBOutlet var result: NSTextView! {
        didSet {
            result.textColor = NSColor.white
            result.font = logFont
        }
    }
    
    @IBOutlet weak var indicator: NSProgressIndicator! {
        didSet {
            indicator.isHidden = true
            indicator.startAnimation(nil)
        }
    }
    
    @IBOutlet weak var version: NSTextField! {
        didSet {
            version.stringValue = "v:\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
        }
    }
    
    @IBOutlet weak var fetchButton: NSButton!
    
    var logFont: NSFont {
        get {
            return NSFont(name: "Avenir-Roman", size: 16.0) ?? NSFont.systemFont(ofSize: 16.0)
        }
    }
    
    var dateFormatter: DateFormatter {
        get {
            let dateFormatter = DateFormatter()
            // http://nsdateformatter.com
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss\n\n"
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter
        }
    }
    
    var viewModel: FetcherViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel = FetcherViewModel(gitUrl: gitUrl,
                                     orginization: orginization,
                                     repo: repo,
                                     username: username,
                                     token: token,
                                     result: result,
                                     selectStatus: selectStatus)
        
        NotificationCenter.default.addObserver(forName: NSControl.textDidEndEditingNotification, object: nil, queue: nil) { [weak self] (notification) in
            if let number = notification.userInfo?["NSTextMovement"] as? NSNumber, number.intValue == NSReturnTextMovement {
                
                if let fetchButton = self?.fetchButton, fetchButton.isEnabled == true {
                    self?.fetch(fetchButton)
                }
            }
        }
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
        
        guard let viewModel = viewModel else { return }
        
        viewModel.fetch {
            [weak self] in
            
            guard let strongself = self else { return }

            if Thread.isMainThread {
                strongself.fetchComplete(sender: sender)
            } else {
                DispatchQueue.main.async {
                    strongself.fetchComplete(sender: sender)
                }
            }
        }
    }
    
    func fetchComplete(sender: Any? = nil) {
        indicator.isHidden = true
        
        if let control = sender as? NSControl {
            control.isEnabled = true
        }
        
        result?.textStorage?.append(formattedResult())
        
        let range = NSMakeRange(result.attributedString().string.count , 0)
        result?.scrollRangeToVisible(range)
    }
    
    @IBAction func open(_ sender: Any) {
        if let button = sender as? NSButton, let url = URL(string: button.title) {
            NSWorkspace.shared.open(url)
        }
    }
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        
        if let select = tabViewItem?.identifier as? String {
            selectStatus.currentSelect = Status.Select(rawValue: Int(select)!) ?? .orgnization
        }

    }
    
    func formattedResult() -> NSMutableAttributedString {
        
        let result = NSMutableAttributedString(string:"")
        
        guard let viewModel = viewModel else {
            return result
        }
        
        result.append(formattedAttributedStringFrom(viewModel: viewModel, title: "Origin"))
        result.append(formattedAttributedStringFrom(viewModel: viewModel.parent, title: "Parent"))
//        result.append(formattedAttributedStringFrom(viewModel: viewModel.source, title: "Source"))

        result.append(NSMutableAttributedString(string:"\(dateFormatter.string(from: Date()))",
            attributes:[NSAttributedString.Key.foregroundColor : NSColor.cyan,
                        NSAttributedString.Key.font : logFont]))

        return result
    }
    
    func formattedAttributedStringFrom(viewModel: FetcherViewModel?, title: String) -> NSMutableAttributedString {
        guard let viewModel = viewModel else {
            return NSMutableAttributedString(string: "")
        }
        
        let result = NSMutableAttributedString(string: "")
        let titleTuple = formatted(title: "[\(title)]\n",
                                    titleColor: NSColor.green,
                                    value: "")
        result.append(titleTuple.title)
        result.append(titleTuple.value)
        
        let fullNameTuple = formatted(title: "Full name: ", value: "\(viewModel.fullName)\n")
        result.append(fullNameTuple.title)
        result.append(fullNameTuple.value)
        
        let sizeTuple = formatted(title: "Size: ", value: "\(viewModel.formattedSize)\n")
        result.append(sizeTuple.title)
        result.append(sizeTuple.value)
        
        let cloneUrlTuple = formatted(title: "Clone url: ", value: "\(viewModel.cloneUrl)\n")
        cloneUrlTuple.value.addAttributes([NSAttributedString.Key.link: viewModel.cloneUrl], range: NSMakeRange(0, viewModel.cloneUrl.count))
        result.append(cloneUrlTuple.title)
        result.append(cloneUrlTuple.value)
        
        return result
    }
    
    func formatted(title: String, titleColor: NSColor? = nil,
                   value: String, valueColor: NSColor? = nil) -> (title: NSMutableAttributedString, value: NSMutableAttributedString) {

        return (NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor : titleColor ?? NSColor.yellow,
                                                                      NSAttributedString.Key.font : logFont]),
                NSMutableAttributedString(string: value, attributes: [NSAttributedString.Key.foregroundColor : valueColor ?? NSColor.white,
                                                                      NSAttributedString.Key.font : logFont]))
    }
}

