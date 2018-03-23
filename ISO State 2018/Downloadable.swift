//
//  Downloadables.swift
//  UCSO Invitational 2018
//
//  Created by Jung-Sun Yi-Tsang on 1/2/18.
//  Copyright © 2018 bayser. All rights reserved.
//

import Foundation

class Downloadable {
    let fileCount = 7
    let files: [CSVFile] //initialized in the Downloadable init() function
    let fileNames = ["soevents", "teams", "tests", "builds", "impounds",  "scheduledevents", "locations"]
    var downloadInProgress = false

    //load from disk
    func load() {
        DispatchQueue.main.async {
            for i in 0..<self.fileCount {
                self.files[i].load(fileName: self.fileNames[i])
            }
        }
    }
    
    //start the downloads
    func beginUpdate() {
        //don't start if a download is already in progress
        if self.downloadInProgress {
            print("Download already in progress!")
            return
        } else {
            print("Download NOT already in progress!!!! How shocking!")
        }
        self.downloadInProgress = true
        //save each file
        for i in 0..<self.fileCount {
            self.files[i].downloadFile(sourceURL: CSVFile.addressesList[i])
        }
    }
    
    //save and parse
    func finishUpdate() {
        self.downloadInProgress = false
        self.save()
        self.parse()
    }
    //saves all the tracked files
    func save() {
        DispatchQueue.main.async {
            for i in 0..<self.fileCount {
                self.files[i].save(name: self.fileNames[i])
            }
        }
    }

    //initialize the files
    init() {
        self.files = [CSVFile](repeating: CSVFile(), count: self.fileCount)
        self.load()
        self.beginUpdate()
        //Notification center hasn't started up yet
        self.downloadInProgress = false
    }
    
    //should be pretty quick to run
    func parse() {
        //get into 2d array
        for i in 0..<fileCount {
            self.files[i].parse()
        }
        //put into proper places
        EventsData.completeSOEventList = getCol(array: self.files[0].data, col: 1) as! [String]
        EventsData.soEventProperties = (self.files[0].data as [[String]]).map{
            $0[2...].map{stringToBool(s: $0)}
        }
        EventsData.roster = getCol(array: self.files[1].data, col: 2) as! [String]
        EventsData.homerooms = getCol(array: self.files[1].data, col: 3) as! [String]
        self.prepareSOEvents()
        self.prepareSchedEvents()
    }
    
    //load the scioly events from the downloaded/loaded CSVs into ScheduleData.soEvents
    func prepareSOEvents() -> Void {
        var tmp: [EventLabel] = []
        //add contributions from file 2, testing events
        for i in 0..<self.files[2].data.count {
            let info = self.files[2].data[i]
            let cTB = EventsData.currentTimeBlock()
            let (evName, loc) = (info[1], info[3])
            let locCode = Int(info[4]) ?? -1
            
            let tmpTime = info[4+cTB!]
            let dur = (info[2]=="") ? 50 : Int(info[2])!
            let evTime = ScheduleData.formatTime(time: tmpTime, duration: dur)!
            let entry = EventLabel(name: evName, loc: loc, locCode: locCode, time: evTime)
            tmp.append(entry)
        }
        //add contributions from file 3, self-scheduled events
        for i in 0..<self.files[3].data.count {
            let info = self.files[3].data[i]
            let (evName, loc) = (info[1], info[3])
            let locCode = Int(info[4]) ?? -1
            let ind = 4+EventsData.currentSchool
            let tmpTime = ind>=info.count ? "?" : info[ind] //not pretty yet
            let evTime = ScheduleData.formatTime(time: tmpTime, duration: Int(info[2])!)!
            let entry = EventLabel(name: evName, loc: loc, locCode: locCode, time: evTime)
            tmp.append(entry)
        }
        //add contributions from file 4, the impound times
        for i in 0..<self.files[4].data.count {
            let info = self.files[4].data[i]
            let (evName, loc) = (info[1], info[3])
            let locCode = Int(info[4]) ?? -1
            let evTime = ScheduleData.formatTime(time: info[5], duration: Int(info[2])!)!
            let entry = EventLabel(name: evName, loc: loc, locCode: locCode, time: evTime)
            tmp.append(entry)
        }
        ScheduleData.soEvents = ScheduleData.orderEvents(eventList: tmp) //TODO: REORDER
    }
    
    func prepareSchedEvents() -> Void {
        var tmp: [EventLabel] = []
        //comes directly from file 5, the scheduled events
        for i in 0..<self.files[5].data.count {
            let info = self.files[5].data[i]
            let (evName, evTime, date, loc) = (info[0], info[1], info[2], info[3])
            let locCode = Int(info[4]) ?? -1
            let entry = EventLabel(name: evName, loc: loc, locCode: locCode, time: evTime, date: date)
            tmp.append(entry)
        }
        ScheduleData.schedEvents = ScheduleData.orderEvents(eventList: tmp)
    }
}

/*class Downloadable {
    let homerooms = CSVFile()
    let testEvents = CSVFile()
    let buildEvents = CSVFile()
    var downloadInProgress = false
    
    //start the downloads
    func beginUpdate() {
    	//don't start if a download is already in progress
    	if self.downloadInProgress {
            print("Download already in progress!")
            return
        } else {
            print("Download NOT already in progress!!!! How shocking!")
        }
        self.downloadInProgress = true
        self.homerooms.downloadFile(sourceURL: CSVFile.homeroomAddress)
        self.testEvents.downloadFile(sourceURL: CSVFile.testEventAddress)
        self.buildEvents.downloadFile(sourceURL: CSVFile.buildEventAddress)
    }
    
    //save and parse
    func finishUpdate() {
        self.downloadInProgress = false
        self.save()
        self.parse()
    }
    
    func save() {
        DispatchQueue.main.async {
            self.homerooms.save(name: "homerooms")
            self.testEvents.save(name: "testevents")
            self.buildEvents.save(name: "buildevents")
        }
    }
    
    func parse() {
        self.homerooms.parse()
        self.testEvents.parse()
        self.testEvents.parse()
    }
    func load() {
        DispatchQueue.main.async {
            self.homerooms.load(fileName: "homerooms")
            self.testEvents.load(fileName: "testevents")
            self.buildEvents.load(fileName: "buildevents")
        }
    }
    
    //initialize the files
    init() {
        self.load()
        self.beginUpdate()
        // Notification center hasn't started up yet
        self.downloadInProgress = false
    }
}*/
