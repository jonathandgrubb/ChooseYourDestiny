//
//  Chapter+CoreDataProperties.swift
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

extension Chapter {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var is_first_chapter: NSNumber?
    @NSManaged var text: String?
    @NSManaged var picture: NSData?
    @NSManaged var video: NSData?
    @NSManaged var story: Story?
    @NSManaged var choice: NSSet?

}
