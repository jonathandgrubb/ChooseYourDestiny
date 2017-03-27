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
    func listAllAuthors(_ completionHandlerForListAllAuthors: @escaping (_ success: Bool, _ error: Errors?, _ authors: [String]?) -> Void) {
    
        getFileContent(Constants.AuthorsFileName, user: Constants.AuthorsRepoUserID, repo: Constants.AuthorsRepoName) { (success, error, content) in
            
            var parsedResult: AnyObject!

            if let error = error {
                print(error)
                completionHandlerForListAllAuthors(false, error, nil)
                return
            }
                
            if let content = content {
                do {
                    // turn into json object
                    parsedResult = try JSONSerialization.jsonObject(with: content, options: .allowFragments) as AnyObject
                } catch {
                    completionHandlerForListAllAuthors(false, Errors.couldNotConvertToJson, nil)
                    return
                }
            } else {
                // shouldn't happen if error isn't set
                completionHandlerForListAllAuthors(false, Errors.internalError, nil)
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
                        completionHandlerForListAllAuthors(false, Errors.invalidFileFormat, nil)
                        return
                    }
                }
                
                // success!!!
                completionHandlerForListAllAuthors(true, nil, authorList)
                
            } else {
                // couldn't find the author's tag
                completionHandlerForListAllAuthors(false, Errors.invalidFileFormat, nil)
            }
            
        }
    }
    
    
    // get story info
    func getStoryInfo(_ user: String, repo: String, completionHandlerForGetStoryInfo: @escaping (_ success: Bool, _ error: Errors?, _ info: StoryInfo?) -> Void) {
    
        getStoryContent(user, repo: repo) { (success, error, content) in
            
            if let error = error {
                print("getStoryInfo error:\(error) user:\(user) repo:\(repo) ")
                completionHandlerForGetStoryInfo(false, error, nil)
                return
            }
            
            if let content = content,
               let story = content["story"] as? [String:AnyObject],
               let title = story["name"] as? String,
               let rating = story["rating"] as? String,
               let chapters = story["chapters"] as? [[String:AnyObject]] {
                
                let info = StoryInfo(author: user, repo: repo, title: title, numChapters: chapters.count, rating: rating)
                
                completionHandlerForGetStoryInfo(true, nil, info)
                return
                
            } else {
                print("required content missing from story json : \(content)")
                completionHandlerForGetStoryInfo(false, Errors.invalidFileFormat, nil)
                return
            }
        }
    }
    
    
    // get story content
    func getStoryContent(_ user: String, repo: String, completionHandlerForGetStoryContent: @escaping (_ success: Bool, _ error: Errors?, _ content: AnyObject?) -> Void) {
        
        getFileContent(Constants.StoryFileName, user: user, repo: repo) { (success, error, content) in
            
            var parsedResult: AnyObject!
            
            if let error = error {
                print("getStoryContent error:\(error) user:\(user) repo:\(repo) ")
                completionHandlerForGetStoryContent(false, error, nil)
                return
            }
            
            if let content = content {
                do {
                    // turn into json object
                    parsedResult = try JSONSerialization.jsonObject(with: content, options: .allowFragments) as AnyObject
                    completionHandlerForGetStoryContent(true, nil, parsedResult)
                    return
                } catch {
                    completionHandlerForGetStoryContent(false, Errors.couldNotConvertToJson, nil)
                    return
                }
            } else {
                // shouldn't happen if error isn't set
                completionHandlerForGetStoryContent(false, Errors.internalError, nil)
            }
            
        }
    }
    
    
    // list stories for author
    func listStoriesForAuthor(_ user: String, completionHandlerForListStoriesForAuthor: @escaping (_ success: Bool, _ error: Errors?, _ storyNames: [String]?) -> Void) {
        
        // specify params to look for this author's stories
        var parameters = [String:AnyObject]()
        parameters[ParameterKeys.Query] = (ParameterValues.StorySearchTag + "+extension:" + ParameterValues.FileExtFilter + "+user:" + user) as AnyObject
        
        taskForGETMethod(Methods.SearchCode, parameters: parameters) { (result, error) in
            
            // 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForListStoriesForAuthor(false, Errors.networkError, nil)
            } else {
                
                print("raw result: \(result)")
                
                // cast the result into an array of dictionaries
                if let result = result, let items = result["items"] as? [[String:AnyObject]] {
                    
                    var repoNames = [String]()
                    
                    // for every file in the file array
                    for item in items {

                        // if it matched the text within README.md
                        // grab the repository name
                        if let fname = item["name"] as? String, fname == Constants.TagFileName,
                           let repo = item["repository"] as? [String:AnyObject],
                           let repoName = repo["name"] as? String {
                            
                            // add it to the list of repositories for this author...
                            repoNames.append(repoName)
                        }
                    }
                    // success!!!
                    completionHandlerForListStoriesForAuthor(true, nil, repoNames)
                    
                } else {
                    // something wrong with the response
                    if let result = result as? String {
                        print("something is wrong with the response: \(result)")
                    }
                    completionHandlerForListStoriesForAuthor(false, Errors.invalidResponse, nil)
                }
            }
            
        }
    }
    
    
    // get story resource (picture, video, ...)
    func getStoryResource(_ fileRelativePath: String, author: String, repo: String, completionHandlerForGetStoryResource: @escaping (_ success: Bool, _ error: Errors?, _ data: Data?) -> Void) {
        
        getFileContent(fileRelativePath, user: author, repo: repo) { (success, error, content) in
            
            if let error = error {
                print(error)
                completionHandlerForGetStoryResource(false, error, nil)
                return
            }
            
            if content != nil {
                completionHandlerForGetStoryResource(true, nil, content)
            } else {
                // shouldn't happen if error isn't set
                completionHandlerForGetStoryResource(false, Errors.internalError, nil)
                return
            }
            
        }
    }

    
    // get file content
    func getFileContent(_ filePath: String, user: String, repo: String, completionHandlerForGetFileContent: @escaping (_ success: Bool, _ error: Errors?, _ content: Data?) -> Void) {
        
        var pathOnly: String = ""
        var fileName: String?
        
        // split filename on '/'
        let fpArray = filePath.components(separatedBy: "/")
        if fpArray.count > 1 {
            pathOnly = "/" + fpArray[0...(fpArray.count-2)].joined(separator: "/")
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
                completionHandlerForGetFileContent(false, Errors.networkError, nil)
            } else {
                
                // cast the result into an array of dictionaries
                if let files = result as? [[String:AnyObject]] {
                    
                    // for every file in the file array
                    for file in files {
                        
                        // if we find the file name that we're looking for, it has a valid url, and 
                        // we are able to get its content...
                        if let fname = file["name"] as? String, fname == fileName,
                           let contentUrlStr = file["download_url"] as? String,
                           let contentUrl = URL(string: contentUrlStr),
                           let content = try? Data(contentsOf: contentUrl) {
                            
                            // success!!!
                            completionHandlerForGetFileContent(true, nil, content)
                            return
                        }
                        //print("didn't find a match: \(file)")
                    }
                    // didn't find the file
                    completionHandlerForGetFileContent(false, Errors.fileNotFound, nil)
                
                } else {
                    // something wrong with the response
                    if let result = result as? String {
                        print("something is wrong with the response: \(result)")
                    }
                    completionHandlerForGetFileContent(false, Errors.fileNotFound, nil)
                }
            }
            
        }
    }
}
