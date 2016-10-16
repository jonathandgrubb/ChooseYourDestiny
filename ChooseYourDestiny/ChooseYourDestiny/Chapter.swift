//
//  Chapter.swift
//  ChooseYourDestiny
//
//  Created by Jonathan Grubb on 7/17/16.
//  Copyright © 2016 Jonathan Grubb. All rights reserved.
//

import Foundation
import CoreData


class Chapter: NSManagedObject {

    convenience init(id: String, name: String, text: String, isFirstChapter: Bool?, pic_path: String?, vid_path: String?, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entityForName("Chapter", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.id = id
            self.name = name
            self.text = text
            self.picture_path = pic_path
            self.video_path = vid_path
            if let first = isFirstChapter where first == true {
                self.is_first_chapter = "true"
            } else {
                self.is_first_chapter = "false"
            }
            
        } else {
            fatalError("Unable to find Entity name!")
        }
        
    }
    
}
