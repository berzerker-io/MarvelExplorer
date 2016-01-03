//
//  CoreDataCharacter+CoreDataProperties.swift
//  MarvelExplorer
//
//  Created by Benoit Sarrazin on 2016-01-03.
//  Copyright © 2016 Berzerker Design. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CoreDataCharacter {

    @NSManaged var desc: String?
    @NSManaged var id: NSNumber?
    @NSManaged var modified: NSDate?
    @NSManaged var name: String?
    @NSManaged var resourceURI: String?

}
