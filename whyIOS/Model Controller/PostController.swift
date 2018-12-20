//
//  PostController.swift
//  whyIOS
//
//  Created by Jack Knight on 12/19/18.
//  Copyright © 2018 Jack Knight. All rights reserved.
//

import Foundation

class PostController {
    
    static let baseURL = URL(string: "https://whydidyouchooseios.firebaseio.com/reasons")
    
     static func fetchPosts(completion: @escaping ([Post]?) -> Void) {
        
        guard let unwrappedURL = self.baseURL else { completion (nil); return}
        
        let getterEndPoint = unwrappedURL.appendingPathExtension("json")
        
        var request = URLRequest(url: getterEndPoint)
        request.httpMethod = "GET"
        request.httpBody = nil
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("There was an error fetching posts : \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else { completion(nil) ; return}
            do {
                let jsondecoder = JSONDecoder()
                let decodedDictionary = try jsondecoder.decode([String:Post].self, from: data)
                let decodedPosts = decodedDictionary.compactMap( {$0.value})
                completion(decodedPosts)
            } catch {
                print("The decoder didn't decode :\(error.localizedDescription)")
                completion(nil)
            }
            
        }
        dataTask.resume()
    }
    
    static func createPost(name: String, reason: String, cohort: String, completion: @escaping (Bool) -> Void) {
        
        guard var unwrappedURL = baseURL else { completion (false); return}
        
        unwrappedURL.appendPathComponent(".json")
        
        let newPost = Post(name: name, reason: reason, cohort: cohort)
        
        do {
            let jsonencode = JSONEncoder()
            
            let data = try jsonencode.encode(newPost)
            
            var request = URLRequest(url: unwrappedURL)
            request.httpMethod = "POST"
            request.httpBody = data
            
            let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let error = error {
                    print("Error posting ; \(error)")
                    completion(false)
                    return
                }
                guard data != nil else { completion(false) ; return}
                completion(true)
                
                
            }
            dataTask.resume()
            
        } catch {
            print("There was an error encoding the data ; \(error)")
            completion(false)
            return
        }
        
    }
    
}


