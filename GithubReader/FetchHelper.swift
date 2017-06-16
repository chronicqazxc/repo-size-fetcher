//
//  FetchHelper.swift
//  GithubReader
//
//  Created by Wayne, Xiao X. -ND on 6/13/17.
//  Copyright © 2017 Wayne, Xiao X. -ND. All rights reserved.
//

import Foundation

struct FetchRequest {
    let gitUrl: String
    let username: String
    let token: String
}

struct FetchResponse {
    let data: Data
}

class FetchHelper {
    let request: FetchRequest
    
    deinit {
        print("fetcher deinit")
    }
    
    init(request: FetchRequest) {
        self.request = request
    }
    
    func fetch(log: String? = #function, completeHandler: @escaping (Data?)->()) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            print("\(log ?? ""): \(ProcessInfo.processInfo.processIdentifier)")
            
            let pipe = Pipe()
            let file = pipe.fileHandleForReading
            
            let task = Process()
            task.launchPath = "/bin/bash"
            
            guard let path = Bundle.main.path(forResource: "fetch",
                                              ofType: "sh") else {
                                                print("shell not found")
                                                completeHandler(nil)
                                                return
            }
            
            task.arguments = [path,
                              self.request.gitUrl,
                              self.request.username,
                              self.request.token]
            
            task.standardOutput = pipe
            task.launch()
            
            let data = file.readDataToEndOfFile()
            
            file.closeFile()
            
            completeHandler(data)
        }
    }
}
