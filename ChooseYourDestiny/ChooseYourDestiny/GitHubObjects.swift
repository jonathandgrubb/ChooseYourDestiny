//
//  GitHubObjects.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 10/15/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import Foundation

extension GitHubClient {
    
    // MARK: GitHub
    struct StoryInfo {
        var author : String
        var repo : String
        var title : String
        var numChapters : Int
        var rating : String
    }
    
}
