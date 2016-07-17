//
//  GitHubConstants.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 7/17/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import Foundation

extension GitHubClient {
    
    // MARK: GitHub
    struct Endpoint {
        static let APIScheme = "https"
        static let APIHost = "api.github.com"
        static let APIPath = "/"
    }
    
    // MARK: Constants
    struct Constants {
        static let AuthorsFileName = "authors.json"
        static let AuthorsRepoUserID = "jonathandgrubb"
        static let AuthorsRepoName = "ChooseYourDestiny-authors"
        static let TagFileName = "README.md"
    }
    
    // MARK: Errors
    enum Errors {
        case NetworkError
        case LoginFailed
        case LogoutFailed
        case RequiredContentMissing
        case FileNotFound
        case InvalidFileFormat
        case CouldNotConvertToJson
        case InternalError
        case InvalidResponse
    }
    
    // MARK: Methods
    struct Methods {
        static let RepoContents = "repos/{user}/{repo}/contents{dir}"
        static let SearchCode = "search/code"
    }
    
    // MARK: URLKeys
    struct URLKeys {
        static let UserID = "user"
        static let RepoName = "repo"
        static let DirName = "dir"
    }
    
    // MARK: Flickr Parameter Keys
    struct ParameterKeys {
        static let Query = "q"
    }
    
    // MARK: Flickr Parameter Values
    struct ParameterValues {
        static let StorySearchTag = "ChooseYourDestiny"
        static let FileExtFilter = "md"
        
    }

}