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
    static var selectedList: [Int] = [] //for the events on the event picker; store as an index of EventsData.completeSOEventList
    static var completeSOEventList: [String] = []
    static var soEventNumbers: [Int] = [] //stores the Event Numbers in the same order as they appear in ED.copmleteSOEventList
    static var soEventProperties: [[Bool]] = [] //store division (if C), trial, test, self-scheduled, impound info
    static var roster: [String] = [] //load up outside
    static var officialNumbers: [Int] = [] //real official numbers
    static var currentSchool = 0 //This is actually different from the team number because of the fact that there's division B and C -- use a unique identifier internally
    static var currentHomeroomLocCode = -1//fill externally
    static var div: Character = "C" // "B" or "C"
    
    
    static func teamNumber() -> Int {
        return Int(DLM.dlFiles.files[1].data[currentSchool][1])!
    }
    
    //get current division as a bool: true for C, false for B
    static func curDivC() -> Bool {
        //return stringToBool(s: DLM.dlFiles.files[1].data[currentSchool][2])
        return stringToBool(s: String(div))
    }
    
    //get current schoool's time block
    static func currentTimeBlock() -> Int? {
        let teamInfo = DLM.dlFiles.files[1].data
        return Int(teamInfo[currentSchool][6])
    }
    //completeSOEventList = ["Anatomy & Physiology", "Astronomy", "Chemistry Lab", "Disease Detectives", "Dynamic Planet", "Ecology", "Experimental Design", "Fermi Questions", "Forensics", "Game On", "Helicopters", "Herpetology", "Hovercraft", "Materials Science", "Microbe Mission", "Mission Possible", "Mousetrap Vehicle", "Optics", "Remote Sensing", "Rocks & Minerals", "Thermodynamics", "Towers", "Write It Do It"]
    //soEventProperties = ...
    
    //fxns to return a list of events with (or without) a given property
    static func eventsThat(have: Bool, prop: Int) -> [(Int, String)] {
        var tmp:[(Int, String)] = []
        let propList = getCol(array: soEventProperties, col: prop) as! [Bool]
        for i in 0..<completeSOEventList.count {
            if have == propList[i] {
                tmp.append((i, completeSOEventList[i]))
            }
        }
        return tmp
    }
    
    static func divCEvents() -> [(Int, String)] {
        return eventsThat(have: true, prop: 0)
    }
    static func divBEvents() -> [(Int, String)] {
        return eventsThat(have: false, prop: 0)
    }
    static func trialEventList() -> [(Int, String)] {
        return eventsThat(have: true, prop: 1)
    }
    static func testEventList() -> [(Int, String)] {
        return eventsThat(have: true, prop: 2)
    }
    static func selfScheduledEventList() -> [(Int, String)] {
        return eventsThat(have: true, prop: 3)
    }
    static func impoundEventList() -> [(Int, String)] {
        return eventsThat(have: true, prop: 4)
    }

    //these fxns identify if a given event is a trial/test/self-scheduled/impound event
    static func thisEvent(evnt: Int, has: Bool, prop: Int) -> Bool? {
        var result: Bool? = nil //same as Optional.none
        if (soEventProperties.count > evnt) && (soEventProperties[evnt].count > prop) {
            result = (has == soEventProperties[evnt][prop])
        }
        return result
    }
    
    static func isDivC(evnt: Int) -> Bool? {
        return thisEvent(evnt: evnt, has: true, prop: 0)
    }
    static func isDivB(evnt: Int) -> Bool? {
        return thisEvent(evnt: evnt, has: false, prop: 0)
    }
    static func isTrial(evnt: Int) -> Bool? {
        return thisEvent(evnt: evnt, has: true, prop: 1)
    }
    static func isTest(evnt: Int) -> Bool? {
        return thisEvent(evnt: evnt, has: true, prop: 2)
    }
    static func isSelfScheduled(evnt: Int) -> Bool? {
        return thisEvent(evnt: evnt, has: true, prop: 3)
    }
    static func isImpounded(evnt: Int) -> Bool? {
        return thisEvent(evnt: evnt, has: true, prop: 4)
    }
    
    static func lookupEventName(evNumber: Int) -> String! {
        let i = EventsData.soEventNumbers.index(of: evNumber) //the event name will be in the ith position
        return EventsData.completeSOEventList[i!]
    }
}

func stringToBool(s: String) -> Bool {
    if s == "1" || s.uppercased() == "C" || s.uppercased() == "Y" {return true} //takes care of div C/div B stuff easily
    else {return false}
}

//fetches events from CoreData
func loadEvents() -> Void {
    request.returnsObjectsAsFaults = false
    do {
        let results = try context.fetch(request)
        if results.count > 0 {
            var tmpRes = [Int]()
            for result in results {
                if let eventNum = (result as AnyObject).value(forKey:"event") as? Int {
                    if !tmpRes.contains(eventNum) {
                        tmpRes.append(eventNum)
                    }
                }
            }
            EventsData.selectedList = tmpRes
        }
    }
    catch {
        print("Something went wrong with the request...")
    }
}

//Dumps everything to storage
func firstSaveEvents() -> Void {
    for eachEvent in EventsData.selectedList {
        addEvent(eventNum: eachEvent)
    }
}

//Save the event list in storage
func saveEvents() -> Void {
    clearEvents() //for convenience
    for eachEvent in EventsData.selectedList {
        addEvent(eventNum: eachEvent)
    }
}


//add an event with CoreData as well as ScheduleData's list
//eventNum  is the internal event number code (converted when added in ModalEventPicker.swift)
func addEvent(eventNum: Int) -> Void {
    //adds to EventsData version
    //EventsData.selectedList.append(eventNum) //already there-- we're adding FROM EventsData!!
    
    //add to ScheduleData list
    //let evNum = Int(DLM.dlFiles.files[0].data[eventNum][0])!
    guard let evLabel = ScheduleData.getEventFromNumber(evNum: eventNum) else {
        print("Couldn't add event! Maybe the files aren't available")
        return
    }
    ScheduleData.selectedSOEvents.append(evLabel)
    
    //save to CoreData
    let newEventThing = NSEntityDescription.insertNewObject(forEntityName: "Events", into: context)
    newEventThing.setValue (eventNum, forKey: "event")
    do {
        try context.save()
        print("Saved!")
    }
    catch {
        print("Something went wrong with adding an event")
    }
}

//removes the first occurrence of an event
func removeEvent(eventNum: Int, indexPath: IndexPath) -> Bool {
    
    //remove from ScheduleData.selectedSOEvents
    for i in 0..<ScheduleData.selectedSOEvents.count {
        if eventNum == ScheduleData.selectedSOEvents[i].num {
            ScheduleData.selectedSOEvents.remove(at: i)
            break
        }
    }
    
    //remove from EventsData.selectedList
    EventsData.selectedList.remove(at: indexPath.row)
    
    //remove from Core Data storage
    let tmp = request.predicate //just storing for later
    request.predicate = NSPredicate(format: "event = %ld", eventNum) //??
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
        print("Something went wrong deleting the event #\(eventNum)")
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

