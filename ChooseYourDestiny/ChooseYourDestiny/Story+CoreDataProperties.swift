//
//  Story+CoreDataProperties.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 7/17/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Story {

    @NSManaged var picture: NSData?
    @NSManaged var rating: String?
    @NSManaged var id: String?
    @NSManaged var video: NSData?
    @NSManaged var summary: String?
    @NSManaged var chapter: NSSet?

}
