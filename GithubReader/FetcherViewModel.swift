//
//  FetcherViewModel.swift
//  GithubReader
//
//  Created by Wayne, Xiao X. -ND on 6/15/17.
//  Copyright © 2017 Wayne, Xiao X. -ND. All rights reserved.
//

import Cocoa

private let kFullName = "full_name"
private let kSize = "size"
private let kCloneUrl = "clone_url"
private let kParent = "parent"
private let kSource = "source"

class FetcherViewModel {

    private(set) var fullName = ""
    private(set) var size = 0
    
    var formattedSize: String {
        get {
            return ByteCountFormatter.string(fromByteCount: Int64(size*1024), countStyle: .binary)
        }
    }
    
    private(set) var cloneUrl = ""
    private(set) var parent: FetcherViewModel?
    private(set) var source: FetcherViewModel?
    
    private var gitUrl: NSTextField?
    private var orginization: NSTextField?
    private var repo: NSTextField?
    private var username: NSTextField?
    private var token: NSTextField?
    private var result: NSTextView?
    private var selectStatus: Status?
    
    private init(data: [AnyHashable : Any]) {
        fullName = data[kFullName] as? String ?? ""
        size = data[kSize] as? Int ?? 0
        cloneUrl = data[kCloneUrl] as? String ?? ""
        
        if let parent = data[kParent] as? [AnyHashable : Any] {
            self.parent = FetcherViewModel(data: parent)
        }
        
        if let source = data[kSource] as? [AnyHashable : Any] {
            self.source = FetcherViewModel(data: source)
        }
    }
    
    init(gitUrl: NSTextField,
         orginization: NSTextField,
         repo: NSTextField,
         username: NSTextField,
         token: NSTextField,
         result: NSTextView,
         selectStatus: Status) {
        self.gitUrl = gitUrl
        self.orginization = orginization
        self.repo = repo
        self.username = username
        self.token = token
        self.result = result
        self.selectStatus = selectStatus
    }
    
    func fetch(log: String? = #function, completeHandler: @escaping ()->()) {

        guard let selectStatus = selectStatus else { return }
        
        switch selectStatus.currentSelect {
            case .orgnization:
                guard let _ = orginization,
                    let _ = repo,
                    let _ = username,
                    let _ = token else {
                        completeHandler()
                        return
            }
            
        case .githubUrl:
            guard let _ = self.gitUrl,
                let _ = username,
                let _ = token else {
                    completeHandler()
                    return
            }
        }

        let gitUrl = selectStatus.currentSelect == .orgnization ? "http://\(orginization!.stringValue)/\(repo!.stringValue).git" : self.gitUrl!.stringValue
        
        let fetchRequest = FetchRequest(gitUrl: gitUrl,
                                        username: username!.stringValue,
                                        token: token!.stringValue)
        
        let fetchHelper = FetchHelper(request: fetchRequest)
        
        fetchHelper.fetch { [weak self] (result) in
            
            guard let strongself = self else {
                completeHandler()
                return
            }
            
            if let result = result {
                strongself.parse(data: result) {
                    completeHandler()
                }
            } else {
                completeHandler()
            }
        }
    }
    
    func parse(data: Data, completeHandler: ()->()) {
        
        guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) else {
            completeHandler()
            return
        }
        
        guard let json = jsonData as? [AnyHashable : Any] else {
            completeHandler()
            return
        }
        
        fullName = json[kFullName] as? String ?? ""
        size = json[kSize] as? Int ?? 0
        cloneUrl = json[kCloneUrl] as? String ?? ""
        
        if let parent = json[kParent] as? [AnyHashable : Any] {
            self.parent = FetcherViewModel(data: parent)
        } else {
            parent = nil
        }
        
        if let source = json[kSource] as? [AnyHashable : Any] {
            self.source = FetcherViewModel(data: source)
        } else {
            source = nil
        }
        
        completeHandler()
    }
}
