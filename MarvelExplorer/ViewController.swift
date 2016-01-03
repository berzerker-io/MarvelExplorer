//
//  ViewController.swift
//  MarvelExplorer
//
//  Created by Benoit Sarrazin on 2016-01-02.
//  Copyright © 2016 Berzerker Design. All rights reserved.
//

import CoreData
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
                let coreDataDelta = processCoreData(json)
                let realmDelta = processRealm(json)
                
                print("--------------------------------------------------")
                print(" RESULTS\n")
                print("  Core Data: \(coreDataDelta)")
                print("  -   Realm: \(realmDelta)")
                print("__________________________________________________")
                print("      Total: \(coreDataDelta - realmDelta)")
                print("--------------------------------------------------\n\n")
            }
        } catch let error as NSError {
            print("Error: \(error.code) \(error.localizedDescription) \(error.userInfo)")
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
        print("--------------------------------------------------")
        print(" BEGIN CORE DATA\n")
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
            Stack.saveContext() // Moving this line out of the loop makes Core Data faster than Realm
        }
        
        let end = NSDate()
        let delta = end.timeIntervalSinceDate(start)
        print(" Start: \(start.timeIntervalSince1970)")
        print("   End: \(end.timeIntervalSince1970)")
        print(" Delta: \(delta)")
        print("--------------------------------------------------\n\n")
        return delta
    }
    
    private func processRealm(dictionaries: [[String: AnyObject]]) -> NSTimeInterval {
        print("--------------------------------------------------")
        print(" BEGIN REALM\n")
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
                
                // [BS] Jan 3, 2016
                // This can be done outside of the loop and decreases the time significantly.
                // However, the goal is the compare Core Data and Realm equally.
                // If you move line 77 (`Stack.saveContext()`) out of the loop,
                // you should also move this out of the loop and use the `characters` array.
                
                //characters.append(character)
                try realm.write({ () -> Void in
                    realm.add(character)
                })
            }
        } catch let error as NSError {
            print("Error: \(error.code) \(error.localizedDescription) \(error.userInfo)")
        }
        
        let end = NSDate()
        let delta = end.timeIntervalSinceDate(start)
        print(" Start: \(start.timeIntervalSince1970)")
        print("   End: \(end.timeIntervalSince1970)")
        print(" Delta: \(delta)")
        print("--------------------------------------------------\n\n")
        return delta
    }
}

