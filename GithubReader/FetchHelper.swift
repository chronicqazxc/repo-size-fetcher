//
//  FetchHelper.swift
//  GithubReader
//
//  Created by Wayne, Xiao X. -ND on 6/13/17.
//  Copyright © 2017 Wayne, Xiao X. -ND. All rights reserved.
//

import Foundation

struct FetchRequest {
    let orginization: String
    let repo: String
    let username: String
    let token: String
}

class FetchHelper {
    let request: FetchRequest
    
    deinit {
        print("fetcher deinit")
    }
    
    init(request: FetchRequest) {
        self.request = request
    }
    
    func fetch(log: String? = #function, completeHandler: @escaping (String)->()) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            print("\(log): \(ProcessInfo.processInfo.processIdentifier)")
            
            let pipe = Pipe()
            let file = pipe.fileHandleForReading
            
            let task = Process()
            task.launchPath = "/bin/bash"
            
            guard let path = Bundle.main.path(forResource: "fetch",
                                              ofType: "sh") else {
                                                print("shell not found")
                                                return
            }
            
            task.arguments = [path,
                              self.request.orginization,
                              self.request.repo,
                              self.request.username,
                              self.request.token]
            
            task.standardOutput = pipe
            task.launch()
            
            let data = file.readDataToEndOfFile()
            
            file.closeFile()
            
            let grepOutput = String(data: data, encoding: .utf8)
            print(grepOutput ?? "")
            
            DispatchQueue.main.async {
                
                completeHandler(self.resultText(org: self.request.orginization,
                                                repo: self.request.repo,
                                                size: grepOutput ?? ""))
            }
        }
    }
    
    func resultText(org:String, repo: String, size: String) -> String {
        return "\(org) - \(repo): \(size) \n"
    }
}
