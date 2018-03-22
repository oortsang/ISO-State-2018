//
//  eventsData.swift
//  UCSO Invitational 2018
//
//  Created by Jung-Sun Yi-Tsang on 12/28/17.
//  Copyright © 2017 bayser. All rights reserved.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext
let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")

class EventsData: NSObject {
    static var list:[String] = []
    static let completeList = ["Anatomy & Physiology", "Astronomy", "Chemistry Lab", "Disease Detectives", "Dynamic Planet", "Ecology", "Experimental Design", "Fermi Questions", "Forensics", "Game On", "Helicopters", "Herpetology", "Hovercraft", "Materials Science", "Microbe Mission", "Mission Possible", "Mousetrap Vehicle", "Optics", "Remote Sensing", "Rocks & Minerals", "Thermodynamics", "Towers", "Write It Do It", "Density Lab (Trial)", "Picture This (Trial)"]
    static let selfScheduled = ["Helicopters", "Hovercraft", "Mission Possible", "Mousetrap Vehicle", "Towers"]
    static var currentSchool = "Sylvania Southview High School - Team A"
    static let roster = ["Sylvania Southview High School - Team A", "Sylvania Southview High School - Team B", "Sylvania Northview - Team A", "Carmel High School - Team A", "Carmel High School - Team B", "St. Ignatius High School - Team A", "St. Ignatius High School - Team B", "Glenbrook South High School - Team A", "Glenbrook South High School - Team B", "Glenbard West High School - Team A", "Glenbard West High School - Team B", "Crystal Lake Central High School - Team A", "Crystal Lake Central High School - Team B", "Joliet West High School - Team B", "Joliet West High School - Team A", "Ladue Horton Watkins High school - Team A", "Waubonsie Valley High School - Team A", "Waubonsie Valley High School - Team B", "Evergreen Park Community High School - Team A", "Adlai E. Stevenson High School - Team A", "Adlai E. Stevenson High School - Team B", "Alcott College Prep - Team A", "Alcott College Prep - Team B", "University of Chicago Laboratory Schools - Team A", "University of Chicago Laboratory Schools - Team B", "Ogden International - Team A", "Lyons Township High - Team A", "Lyons Township High - Team B", "Jones College Prep - Team A", "John Hersey High School - Team A", "Walter Payton College Prep - Team A", "Walter Payton College Prep - Team B", "Northside College Prep - Team A", "Northside College Prep - Team B", "OPRF - Team A", "OPRF - Team B", "John Hancock College Prep HS - Team A", "British International School of Chicago, South Loop - Team A", "Saint Ignatius College prep - Team A", "Saint Ignatius College prep - Team B"]
    static func teamNumber() -> Int! {
        return 1+roster.index(of: EventsData.currentSchool)!
    }
    static func isSelfScheduled(evnt: String) -> Bool! {
        return EventsData.selfScheduled.contains(evnt)
    }
    //returns the currently selected events that require impounds
    static func impoundList() -> [String] {
        var tmpList: [String] = []
        for event in EventsData.list {
            if selfScheduled.contains(event) || event == "Thermodynamics" {
                tmpList.append(event)
            }
        }
        return tmpList.sorted()
    }
}

func hasHovercraft() -> Bool {
    //print(EventsData.list)
    return EventsData.list.contains("Hovercraft")
}

//fetches events from CoreData
func loadEvents() -> Void {
    request.returnsObjectsAsFaults = false
    do {
        let results = try context.fetch(request)
        if results.count > 0 {
            var tmpRes = [String]()
            for result in results {
                if let eventName = (result as AnyObject).value(forKey:"event") as? String {
                    tmpRes.append(eventName)
                }
            }
            EventsData.list = tmpRes
        }
    }
    catch {
        print("Something went wrong with the request...")
    }
}

//Dumps everything to storage
func firstSaveEvents() -> Void {
    for eachEvent in EventsData.list {
        addEvent(eventName: eachEvent)
    }
}

//Save the event list in storage
func saveEvents() -> Void {
    clearEvents() //for convenience
    for eachEvent in EventsData.list {
        addEvent(eventName: eachEvent)
    }
}


//add an event with CoreData
func addEvent(eventName: String) -> Void {
    let newEventThing = NSEntityDescription.insertNewObject(forEntityName: "Events", into: context)
    newEventThing.setValue (eventName, forKey: "event")
    do {
        try context.save()
        print("Saved!")
    }
    catch {
        print("Something went wrong with adding an event")
    }
}

//removes the first occurrence of an event
func removeEvent(eventName: String, indexPath: IndexPath) -> Bool {
    EventsData.list.remove(at: indexPath.row)
    let tmp = request.predicate
    request.predicate = NSPredicate(format: "event = %@", eventName) //??
    var res : Bool = false
    do {
        let results = try context.fetch(request) as? [NSManagedObject]
        if results!.count > 0 {
            let object = results!.first
            //print("Removed \(String(describing: object))")
            context.delete(object!)
            res = true
        }
    } catch {
        print("Something went wrong deleting the event \(eventName)")
    }
    request.predicate = tmp //undo what just happened
    return res
}
//remove all events
func clearEvents() -> Void {
    do {
        let results = try context.fetch(request) as? [NSManagedObject]
        if results!.count > 0 {
            //delete all results
            for object in results! {
                //print("Removed \(object)")
                context.delete(object)
            }
        }
    } catch {
        print("Something went wrong clearing out all the events")
    }
}

