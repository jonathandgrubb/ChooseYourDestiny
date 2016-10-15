//
//  GitHubConvenience.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 7/17/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import Foundation

extension GitHubClient {
    
    
    // list all authors
    func listAllAuthors(completionHandlerForListAllAuthors: (success: Bool, error: Errors?, authors: [String]?) -> Void) {
    
        getFileContent(Constants.AuthorsFileName, user: Constants.AuthorsRepoUserID, repo: Constants.AuthorsRepoName) { (success, error, content) in
            
            var parsedResult: AnyObject!

            if let error = error {
                print(error)
                completionHandlerForListAllAuthors(success: false, error: error, authors: nil)
                return
            }
                
            if let content = content {
                do {
                    // turn into json object
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(content, options: .AllowFragments)
                } catch {
                    completionHandlerForListAllAuthors(success: false, error: Errors.CouldNotConvertToJson, authors: nil)
                    return
                }
            } else {
                // shouldn't happen if error isn't set
                completionHandlerForListAllAuthors(success: false, error: Errors.InternalError, authors: nil)
                return
            }
            
            // make a list of the authors
            if let authors = parsedResult["authors"] as? [[String:AnyObject]] {
                
                var authorList = [String]()
                for author in authors {
                    if let name = author["name"] as? String {
                        authorList.append(name)
                    } else {
                        // invalid element... of the names isn't there
                        completionHandlerForListAllAuthors(success: false, error: Errors.InvalidFileFormat, authors: nil)
                        return
                    }
                }
                
                // success!!!
                completionHandlerForListAllAuthors(success: true, error: nil, authors: authorList)
                
            } else {
                // couldn't find the author's tag
                completionHandlerForListAllAuthors(success: false, error: Errors.InvalidFileFormat, authors: nil)
            }
            
        }
    }
    
    // get story info
    func getStoryInfo(filePath: String, user: String, repo: String, completionHandlerForGetStoryInfo: (success: Bool, error: Errors?, content: StoryInfo?) -> Void) {
    
        getStoryContent(filePath, user: user, repo: repo) { (success, error, content) in
            
            if let error = error {
                print(error)
                completionHandlerForGetStoryInfo(success: false, error: error, content: nil)
                return
            }
            
            if let content = content,
               let story = content["story"] as? [String:AnyObject],
               let title = story["name"] as? String,
               let rating = story["rating"] as? String,
               let chapters = story["chapters"] as? [String:AnyObject] {
                
                let info = StoryInfo(author: user, title: title, numChapters: chapters.count, rating: rating)
                
                completionHandlerForGetStoryInfo(success: true, error: nil, content: info)
                
            } else {
                print("required content missing from story json : \(content)")
                completionHandlerForGetStoryInfo(success: false, error: Errors.InvalidFileFormat, content: nil)
            }
        }
    }
    
    // get story content
    func getStoryContent(filePath: String, user: String, repo: String, completionHandlerForGetStoryContent: (success: Bool, error: Errors?, content: AnyObject?) -> Void) {
        
        getFileContent(filePath, user: user, repo: repo) { (success, error, content) in
            
            var parsedResult: AnyObject!
            
            if let error = error {
                print(error)
                completionHandlerForGetStoryContent(success: false, error: error, content: nil)
                return
            }
            
            if let content = content {
                do {
                    // turn into json object
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(content, options: .AllowFragments)
                    completionHandlerForGetStoryContent(success: true, error: nil, content: parsedResult)
                    return
                } catch {
                    completionHandlerForGetStoryContent(success: false, error: Errors.CouldNotConvertToJson, content: nil)
                    return
                }
            } else {
                // shouldn't happen if error isn't set
                completionHandlerForGetStoryContent(success: false, error: Errors.InternalError, content: nil)
            }
            
        }
    }
    
    
    // list stories for author
    func listStoriesForAuthor(user: String, completionHandlerForListStoriesForAuthor: (success: Bool, error: Errors?, storyNames: [String]?) -> Void) {
        
        // specify params to look for this author's stories
        var parameters = [String:AnyObject]()
        parameters[ParameterKeys.Query] = (ParameterValues.StorySearchTag + "+extension:" + ParameterValues.FileExtFilter + "+user:" + user) as AnyObject
        
        taskForGETMethod(Methods.SearchCode, parameters: parameters) { (result, error) in
            
            // 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForListStoriesForAuthor(success: false, error: Errors.NetworkError, storyNames: nil)
            } else {
                
                // cast the result into an array of dictionaries
                if let items = result["items"] as? [[String:AnyObject]] {
                    
                    var repoNames = [String]()
                    
                    // for every file in the file array
                    for item in items {

                        // if it matched the text within README.md
                        // grab the repository name
                        if let fname = item["name"] as? String where fname == Constants.TagFileName,
                           let repo = item["repository"] as? [String:AnyObject],
                           let repoName = repo["name"] as? String {
                            
                            // add it to the list of repositories for this author...
                            repoNames.append(repoName)
                        }
                    }
                    // success!!!
                    completionHandlerForListStoriesForAuthor(success: true, error: nil, storyNames: repoNames)
                    
                } else {
                    // something wrong with the response
                    if let result = result as? String {
                        print("something is wrong with the response: \(result)")
                    }
                    completionHandlerForListStoriesForAuthor(success: false, error: Errors.InvalidResponse, storyNames: nil)
                }
            }
            
        }
    }
    
    
    // get file content
    func getFileContent(filePath: String, user: String, repo: String, completionHandlerForGetFileContent: (success: Bool, error: Errors?, content: NSData?) -> Void) {
        
        var pathOnly: String = ""
        var fileName: String?
        
        // split filename on '/'
        let fpArray = filePath.componentsSeparatedByString("/")
        if fpArray.count > 1 {
            pathOnly = "/" + fpArray[0...(fpArray.count-2)].joinWithSeparator("/")
            fileName = fpArray.last
        } else {
            fileName = filePath
        }
        
        // specify params (if any)
        let parameters = [String:AnyObject]()
        
        // build the method
        var mutableMethod: String = Methods.RepoContents
        mutableMethod = ClientCommon.subtituteKeyInMethod(mutableMethod, key: URLKeys.UserID, value: user)!
        mutableMethod = ClientCommon.subtituteKeyInMethod(mutableMethod, key: URLKeys.RepoName, value: repo)!
        mutableMethod = ClientCommon.subtituteKeyInMethod(mutableMethod, key: URLKeys.DirName, value: pathOnly)!
        
        taskForGETMethod(mutableMethod, parameters: parameters) { (result, error) in
            
            // 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForGetFileContent(success: false, error: Errors.NetworkError, content: nil)
            } else {
                
                // cast the result into an array of dictionaries
                if let files = result as? [[String:AnyObject]] {
                    
                    // for every file in the file array
                    for file in files {
                        
                        // if we find the file name that we're looking for, it has a valid url, and 
                        // we are able to get its content...
                        if let fname = file["name"] as? String where fname == fileName,
                           let contentUrlStr = file["downloadUrl"] as? String,
                           let contentUrl = NSURL(string: contentUrlStr),
                           let content = NSData(contentsOfURL: contentUrl) {
                            
                            // success!!!
                            completionHandlerForGetFileContent(success: true, error: nil, content: content)
                            return
                        }
                    }
                    // didn't find the file
                    completionHandlerForGetFileContent(success: false, error: Errors.FileNotFound, content: nil)
                
                } else {
                    // something wrong with the response
                    if let result = result as? String {
                        print("something is wrong with the response: \(result)")
                    }
                    completionHandlerForGetFileContent(success: false, error: Errors.FileNotFound, content: nil)
                }
            }
            
        }
    }
}