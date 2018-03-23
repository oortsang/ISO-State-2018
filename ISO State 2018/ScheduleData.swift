//
//  ScheduleData.swift
//  UCSO Invitational 2018
//
//  Created by Jung-Sun Yi-Tsang on 12/29/17.
//  Copyright © 2017 bayser. All rights reserved.
//

import Foundation
import UIKit

class EventLabel {
    var name = ""
    var loc = ""
    var time = ""
    var date = "" //optional
    var locCode = -1 //optional -- for linking to the map
    func getTime() -> String! {
        return self.time
    }
    func getTuple() -> (String, String, String) {
        return (self.name, self.loc, self.time)
    }
    func setTuple(setName: String, setLoc: String, setTime: String) {
         (self.name, self.loc, self.time) = (setName, setLoc, setTime)
    }
    //returns a string
    func printString() -> String! {
        return "\(self.time) @ \(self.loc): \(self.name)"
    }
    //returns the textlabel text as well as the detail text
    func printCell(cell: UITableViewCell) -> UITableViewCell {
        let cellCopy = cell
        cellCopy.textLabel?.text = "\(self.name)"
        cellCopy.detailTextLabel?.text = "\(self.time) @ \(self.loc)"
        return cellCopy
    }
    init(name: String, loc: String, time: String) {
        (self.name, self.loc, self.time) = (name, loc, time)
    }
    init(name: String, loc: String, locCode: Int, time: String, date: String) {
        (self.name, self.loc, self.locCode, self.time, self.date) = (name, loc, locCode, time, date)
    }
    init(name: String, loc: String, locCode: Int, time: String) {
        (self.name, self.loc, self.locCode, self.time) = (name, loc, locCode, time)
    }
    init () {}
}

class ScheduleData {
    static var soEvents : [EventLabel] = []
    static var schedEvents : [EventLabel] = [] //arrange by date
    /*
    static func updateHomerooms(dataFile: CSVFile) {
        guard dataFile.file != "" else {return} //don't want the file to be empty!
        ScheduleData.homeroomList = getCol(array: dataFile.data, col: 1) as! [String]
        ScheduleData.homeroom = ScheduleData.homeroomList[EventsData.teamNumber()-1]
        dataFile.save(name: "homerooms")
    }
    */
    
    //returns a list of events in chronological/alphabetical order
    static func orderEvents(eventList: [EventLabel]) -> [EventLabel] {
        return eventList.sorted(by: ScheduleData.comesBefore)
    }
    
    //returns whether first event happens before the second event
    /*TODO: Accept full range of time*/
    static func comesBefore (ev1: EventLabel, ev2: EventLabel) -> Bool {
        //in case time is unknown
        if (ev1.time == "?" || ev2.time == "?") {
            return true
        }
        
        var isBefore = true
        let hourOrder = [7,8,9,10,11,12,1,2,3,4,5,6]
        let separator = {(str: String) -> [String] in return str.components(separatedBy: ":")}
        let hourIndex = {(i: Int) -> Int? in return hourOrder.index(of: i)}
        let (t1, t2) =  (ev1.getTime(), ev2.getTime())
        let (s1, s2) = (separator(t1!), separator(t2!))
        let (h1, h2) = (Int(s1[0])!, Int(s2[0])!)
        let (m1, m2) = (s1[1].first!, s2[1].first!)
        
        isBefore = hourIndex(h1)! < hourIndex(h2)!
        if (hourIndex(h1)! == hourIndex(h2)!) {
            isBefore = m1 < m2
            if m1 == m2 {
                isBefore = ev1.name < ev2.name
            }
        }
        return isBefore
    }
    
    static func stringyTime(hour: Int, mins: Int, ampm: Character) -> String {
        let minString = ((mins<10) ? "0" : "") + String(mins) //add an extra 0 for 1-digit
        let hourString = String(hour)
        let output = "\(hourString):\(minString) \(ampm)M"
        return output
    }
    
    //helper function just for string processing
    static func formatTime(time: String, duration: Int = 50) -> String! {
        var result = ""
        var stdTime = "" //start time but in standardized formatting (i.e. 4:20 PM)
        if time == "" || time == "?" { //don't know
            result = "?"
        } else if time.count > 8 { //don't change
            result = time
        } else { //need to finish formatting
            var ampm: Character = " "
            //determine whether it's AM or PM for various formats
            if time.contains("M") {
                let m = time.index(time.index(of: "M")!, offsetBy: -1)
                ampm = String(time[m]).first!
            } else { // infer
                var hours: Int = 0
                if time.contains(":") {
                    let colon = time.index(of: ":")!
                    hours = Int(String(time[..<colon]))!
                } else { //only a single number
                    hours = Int(String(time))!
                }
                ampm = (hours>=7) ? "A" : "P"
            }
            //standardize and put into "stdTime"
            var startHour: Int, startMins: Int
            if time.contains(":") { //if it's written like 9:00 as opposed to 9
                let colon = time.index(of: ":")!
                let cHours = Int(String(time[..<colon]))! //extract current hour
                
                let startInd = time.index(colon, offsetBy: 1)
                let endInd = time.index(startInd, offsetBy: 2)
                let cMins = Int(String(time[startInd..<endInd]))! //get first two characters after the ":"
                
                startHour = cHours
                startMins = cMins
            } else { //:00 inferred
                var cHour = 0
                if time.contains(" ") {
                    let space = time.index(of: " ")!
                    cHour = Int(String(time[..<space]))!
                } else { //just a number
                    cHour = Int(String(time))!
                }
                startHour = cHour
                startMins = 0
            }
            stdTime = stringyTime(hour: startHour, mins: startMins, ampm: ampm)
            
            //find the end time of the interval
            let mins = duration + startMins
            
            let endHour = startHour + (mins/60 as Int)
            let endMins = mins % 60
            
            //finish the interval
            let endTime = stringyTime(hour: endHour, mins: endMins, ampm: ampm)
            if duration == 0 {
                result = stdTime
            } else if endHour >= 12 { //need to switch AM to PM or PM to AM //assume duration < 24 hours
                result = "\(stdTime) - \(endTime)" //no need to cut anything
            } else { //don't switch AM/PM -- cut off the end of stdTime
                let space = stdTime.index(of: " ")!
                let tmpTime = String(stdTime[..<space]) //looks something like "9:00" with no " AM"
                result = "\(tmpTime) - \(endTime)"
            }
        }
        return result
    }
}
