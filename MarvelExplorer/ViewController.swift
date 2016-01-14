//
//  ViewController.swift
//  MarvelExplorer
//
//  Created by Benoit Sarrazin on 2016-01-02.
//  Copyright © 2016 Berzerker Design. All rights reserved.
//

import CoreData
import Log
import RealmSwift
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var json: [[String: AnyObject]]?
    
    private var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            json = try processJSON()
            if let json = self.json {
                Log.trace("--------------------------------------------------")
                let coreDataWriteDelta = processCoreData(json)
                let realmWriteDelta = processRealm(json)
                Log.trace("")
                Log.trace("\tResults\n")
                Log.trace("\t\tCore Data: \(coreDataWriteDelta)")
                Log.trace("\t\t-   Realm: \(realmWriteDelta)")
                Log.trace("__________________________________________________")
                Log.warning("\t\tTotal: \(coreDataWriteDelta - realmWriteDelta)")
                Log.trace("--------------------------------------------------\n\n")
                
                
                Log.trace("--------------------------------------------------")
                let coreDataReadDelta = readCoreData()
                let realmReadDelta = readRealm()
                Log.trace("")
                Log.trace("\tResults\n")
                Log.trace("\t\tCore Data: \(coreDataReadDelta)")
                Log.trace("\t\t-   Realm: \(realmReadDelta)")
                Log.trace("__________________________________________________")
                Log.warning("\t\tTotal: \(coreDataReadDelta - realmReadDelta)")
                Log.trace("--------------------------------------------------\n\n")
            }
        } catch let error as NSError {
            Log.error("\(error.code) \(error.localizedDescription) \(error.userInfo)")
        }
    }
    
    // MARK: - Data Processing
    
    private func processJSON() throws -> [[String: AnyObject]]? {
        guard let url = NSBundle.mainBundle().URLForResource("marvel", withExtension: "json") else { return nil }
        guard let data = NSData(contentsOfURL: url) else { return nil }
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
        return json as? [[String : AnyObject]]
    }
    
    private func processCoreData(dictionaries: [[String: AnyObject]]) -> NSTimeInterval {
        Log.trace("")
        Log.trace("\tInserting into Core Data\n")
        let start = NSDate()
        let context = Stack.managedObjectContext
        for dictionary in dictionaries {
            let id = (dictionary["id"] as? Int) ?? 0
            let name = (dictionary["name"] as? String) ?? "Unknown Marvel Character"
            let desc = (dictionary["description"] as? String) ?? "This Marvel character has no description."
            let modified = (dictionary["modified"] as? String) ?? "1970-01-01T00:00:00-0000"
            let resourceUI = (dictionary["resourceURI"] as? String) ?? "https://marvel.com"
            
            let character = NSEntityDescription.insertNewObjectForEntityForName("Character", inManagedObjectContext: context) as? CoreDataCharacter
            character?.name = name
            character?.id = id
            character?.desc = desc
            character?.modified = dateFormatter.dateFromString(modified)
            character?.resourceURI = resourceUI
        }
        Stack.saveContext()
        
        let end = NSDate()
        let delta = end.timeIntervalSinceDate(start)
        Log.trace("\t\tStart:\t\(start.timeIntervalSince1970)")
        Log.trace("\t\tEnd:\t\(end.timeIntervalSince1970)")
        Log.info("\t\tDelta:\t\(delta)")
        return delta
    }
    
    private func processRealm(dictionaries: [[String: AnyObject]]) -> NSTimeInterval {
        Log.trace("")
        Log.trace("\tInserting into Realm\n")
        let start = NSDate()
        do {
            let realm = try Realm()
            var characters = [RealmCharacter]()
            for dictionary in dictionaries {
                let id = (dictionary["id"] as? Int) ?? 0
                let name = (dictionary["name"] as? String) ?? "Unknown Marvel Character"
                let desc = (dictionary["description"] as? String) ?? "This Marvel character has no description."
                let modified = (dictionary["modified"] as? String) ?? "1970-01-01T00:00:00-0000"
                let resourceUI = (dictionary["resourceURI"] as? String) ?? "https://marvel.com"
                
                let character = RealmCharacter()
                character.name = name
                character.id = id
                character.desc = desc
                character.modified = dateFormatter.dateFromString(modified) ?? character.modified
                character.resourceURI = resourceUI
                characters.append(character)
            }
            try realm.write({ () -> Void in
                realm.add(characters)
            })
        } catch let error as NSError {
            Log.error("\(error.code) \(error.localizedDescription) \(error.userInfo)")
        }
        
        let end = NSDate()
        let delta = end.timeIntervalSinceDate(start)
        Log.trace("\t\tStart:\t\(start.timeIntervalSince1970)")
        Log.trace("\t\tEnd:\t\(end.timeIntervalSince1970)")
        Log.info("\t\tDelta:\t\(delta)")
        return delta
    }
    
    private func readCoreData() -> NSTimeInterval {
        Log.trace("")
        Log.trace("\tReading from Core Data\n")
        let start = NSDate()
        var result: [CoreDataCharacter]?
        do {
            let request = NSFetchRequest(entityName: "Character")
            result = try Stack.managedObjectContext.executeFetchRequest(request) as? [CoreDataCharacter]
        } catch let error as NSError {
            Log.error("\(error.code) \(error.localizedDescription) \(error.userInfo)")
        }
        let end = NSDate()
        let delta = end.timeIntervalSinceDate(start)
        Log.trace("\t\tStart:\t\(start.timeIntervalSince1970)")
        Log.trace("\t\tEnd:\t\(end.timeIntervalSince1970)")
        Log.info("\t\tDelta:\t\(delta)")
        Log.trace("\t\tCount:\t\(result!.count) records")
        return delta
    }
    
    private func readRealm() -> NSTimeInterval {
        Log.trace("")
        Log.trace("\tReading from Realm\n")
        let start = NSDate()
        var result: Results<RealmCharacter>?
        do {
            result = try Realm().objects(RealmCharacter.self)
            
        } catch let error as NSError {
            Log.error("\(error.code) \(error.localizedDescription) \(error.userInfo)")
        }
        let end = NSDate()
        let delta = end.timeIntervalSinceDate(start)
        Log.trace("\t\tStart:\t\(start.timeIntervalSince1970)")
        Log.trace("\t\tEnd:\t\(end.timeIntervalSince1970)")
        Log.info("\t\tDelta:\t\(delta)")
        Log.trace("\t\tCount:\t\(result!.count) records")
        return delta
    }
}

