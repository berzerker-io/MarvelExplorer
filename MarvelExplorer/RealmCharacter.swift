//
//  RealmCharacter.swift
//  MarvelExplorer
//
//  Created by Benoit Sarrazin on 2016-01-03.
//  Copyright © 2016 Berzerker Design. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCharacter: Object {
    
    dynamic var desc = ""
    dynamic var id = 0
    dynamic var modified = NSDate(timeIntervalSince1970: 0)
    dynamic var name = ""
    dynamic var resourceURI = ""
    
}
