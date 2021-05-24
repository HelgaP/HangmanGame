//
//  FetchData.swift
//  HangmanProject
//
//  Created by Irina Perepelkina on 14.05.2021.
//  Copyright © 2021 Irina Perepelkina. All rights reserved.
//

import Foundation


class Model {
 
 func createWordsArray () -> [String]? {
    
    guard let path = Bundle.main.path(forResource: "wordsForGame", ofType: "txt") else {
        print("Can find a path to a named text file")
        return nil
    }
    
    do {
        let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        let array = text.components(separatedBy: "\n")
        return array
    }
    catch {
        print("Can't open text file")
        return nil
    }
    
 }
    
         
    func createTermObjects (word: String, completion: @escaping (Result<Term>) -> Void) {
        
        guard let encodedString = word.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            print("Failed to encode string")
            return
        }
            print("Encoded string is \(encodedString)")
                guard let urlObject = URL(string: "https://wordsapiv1.p.rapidapi.com/words/\(encodedString)") else {
                    print("Failed to create url object for string: \(encodedString)")
                    return
        }
        
                let headers = [
                    "x-rapidapi-key": "40b45cc08cmshd595aa761dad16cp167862jsn7be33d4a3c92",
                    "x-rapidapi-host": "wordsapiv1.p.rapidapi.com"
                ]
            
                let request = NSMutableURLRequest(url: urlObject, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
                
                request.httpMethod="GET"
                request.allHTTPHeaderFields = headers
                
                let session = URLSession.shared // Set up connection?
            // It seems to be just a definition of a function but not the actual call
                let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
                    print("Got inside closure of dataTask for word \(word)")
                    if error != nil || data == nil {
                        print("Function returns due to an error\(error) or nil data received")
                        return
                    }
                    else {
                        do {
                            print("Got inside a do-block")
                            // decode JSON to receive definition and synonym for a word
                            var output = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                            guard let results = output["results"] as? [[String:Any]] else {
                                print("No results found while parsing JSON object")
  
                                return
                            }
                            var definition = results[0]["definition"] as! String?
                            var synonyms = results[0]["synonyms"] as! [String]?
                            
                            if definition != nil && synonyms?[0] != nil {
                                var newTerm = Term()
                                newTerm.term = word
                                newTerm.description = definition
                                newTerm.synonim = synonyms?[0]
                                completion(.success(newTerm))
                                print("term \(newTerm.description) is appended")
                            }
                            else {print("Either definition or synonim is invalid")}

                        }
                        catch {
                            print("Failed to parse JSON object")
                        }
                    }
                }
                dataTask.resume()
        
    }// create function bracket
}// class bracket

