//
//  FetchHelper.swift
//  GithubReader
//
//  Created by Wayne, Xiao X. -ND on 6/13/17.
//  Copyright © 2017 Wayne, Xiao X. -ND. All rights reserved.
//

import Foundation
import WHCoreServices

protocol Request {
    var apiUrl: String { get }
    var token: String { get }
}

struct FetchRequestOrginization: Request {
    let orginization: String
    let repoName: String
    let token: String
    var apiUrl: String {
        return Service.getPath("GitHubDisney", token: ["orginization": orginization, "repoName": repoName]) ?? ""
    }
}

struct FetchRequestGitUrl: Request {
    let gitUrl: String
    let token: String
    var apiUrl: String {
        var split = gitUrl.split(separator: "/")
        let repoName = String(split.removeLast())
        let orginization = String(split.removeLast())
        return Service.getPath("GitHubDisney", token: ["orginization": orginization, "repoName": repoName]) ?? ""
    }
}

struct FetchResponse {
    let data: Data
}

class FetchHelper {
    let request: Request
    
    deinit {
        print("fetcher deinit")
    }
    
    init(request: Request) {
        self.request = request
    }
    
    func fetch(log: String? = #function, completeHandler: @escaping (Data?)->()) {
        
//        let gitUrl = selectStatus.currentSelect == .orgnization ? "https://github.disney.com/api/v3/repos/\(request.orginization)/\(request.repo)" : self.gitUrl!.stringValue
        
        guard let url = URL(string: self.request.apiUrl) else {
                completeHandler(nil)
                return
        }
        Service.shared.get(url: url, token: self.request.token) { (data, response, error) in
            if let data = data {
                completeHandler(data)
            } else {
                completeHandler(nil)
            }
        }
    }
}
