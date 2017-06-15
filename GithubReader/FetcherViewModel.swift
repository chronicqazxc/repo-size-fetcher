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
    
    private var orginization: NSTextField?
    private var repo: NSTextField?
    private var username: NSTextField?
    private var token: NSTextField?
    private var result: NSTextView?
    
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
    
    init(orginization: NSTextField,
         repo: NSTextField,
         username: NSTextField,
         token: NSTextField,
         result: NSTextView) {
        self.orginization = orginization
        self.repo = repo
        self.username = username
        self.token = token
        self.result = result
    }
    
    func fetch(log: String? = #function, completeHandler: @escaping ()->()) {

        guard let orginization = orginization,
            let repo = repo,
            let username = username,
            let token = token else {
                return
        }
        
        let fetchRequest = FetchRequest(orginization: orginization.stringValue,
                                        repo: repo.stringValue,
                                        username: username.stringValue,
                                        token: token.stringValue)
        
        let fetchHelper = FetchHelper(request: fetchRequest)
        
        fetchHelper.fetch { [weak self] (result) in
            
            guard let strongself = self else {
                completeHandler()
                return
            }
            
            strongself.parse(data: result) {
                completeHandler()
            }
        }
    }
    
    func parse(data: Data, completeHandler: ()->()) {
        
        guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) else { return }
        guard let json = jsonData as? [AnyHashable : Any] else { return }
        
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
