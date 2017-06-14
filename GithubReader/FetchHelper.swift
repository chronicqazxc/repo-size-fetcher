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

struct FetchResponse {
    let result: String
    
    func parse() {
        
        guard result.characters.count > 1 else { return }
        
        let formatted = "{\(result.substring(to: result.index(result.endIndex, offsetBy: -2)))}"
        
        if let data = formatted.data(using: .utf8) {
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            print(json ?? "parse faild")
            
            // TODO: Parse size
            if let dic = json as? [AnyHashable : Any] {
                let size = dic["size"]
                print(size ?? "size not found")
            }
        }
    }
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
            
            print("\(log ?? ""): \(ProcessInfo.processInfo.processIdentifier)")
            
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

            let grepOutput = String(data: data, encoding: .utf8) ?? ""
            
            // TODO: Return response
//            let response = FetchResponse(result: grepOutput)
            
            DispatchQueue.main.async {
                
                completeHandler(self.resultText(org: self.request.orginization,
                                                repo: self.request.repo,
                                                size: grepOutput))
            }
        }
    }
    
    func resultText(org:String, repo: String, size: String) -> String {
        return "\(org) - \(repo): \n \(size) \n"
    }
}
