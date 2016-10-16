//
//  Choice.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 7/17/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import Foundation
import CoreData


class Choice: NSManagedObject {

    convenience init(text: String, chapterId: String, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entityForName("Choice", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.text = text
            self.chapter_id = chapterId
        } else {
            fatalError("Unable to find Entity name!")
        }
        
    }
}
