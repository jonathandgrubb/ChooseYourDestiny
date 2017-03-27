//
//  Story+CoreDataProperties.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 10/16/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Story {

    @NSManaged var id: String?
    @NSManaged var picture: Data?
    @NSManaged var rating: String?
    @NSManaged var summary: String?
    @NSManaged var video: Data?
    @NSManaged var name: String?
    @NSManaged var picture_path: String?
    @NSManaged var video_path: String?
    @NSManaged var author: String?
    @NSManaged var repo: String?
    @NSManaged var chapter: NSSet?

}
