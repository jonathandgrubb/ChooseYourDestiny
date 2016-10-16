//
//  Choice+CoreDataProperties.swift
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

extension Choice {

    @NSManaged var chapter_id: String?
    @NSManaged var text: String?
    @NSManaged var chapter: Chapter?

}
