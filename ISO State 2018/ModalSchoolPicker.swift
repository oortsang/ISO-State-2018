//
//  ModalSchoolPicker.swift
//  UCSO Invitational 2018
//
//  Created by Jung-Sun Yi-Tsang on 12/28/17.
//  Copyright © 2017 bayser. All rights reserved.
//

import UIKit
import CoreData

class ModalSchoolPicker: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var schoolPicker: UIPickerView!
    
    var numDivB: Int = 0
    var officialTeamNums: [Int] = []
    var officialTeamNames: [String] = []

    func updateValues() {
        let teamsData = DLM.dlFiles.files[1].data
        let internalTeamNumbers = (getCol(array: teamsData, col: 0) as! [String]).map{Int($0)!}
        let divBTeams = EventsData.divXTeams(div: "B")
        numDivB = divBTeams.count
        print("\(EventsData.roster) teams loaded")
        //unrigorous... but assume internal team numbering is 1-indexed and uninterrupted
        //var actualIndices = Array(0..<internalTeamNumbers.count).map{ $0 - (($0<numDivB) ? 0 : numDivB)}
        
        
        //var actualIndices: [Int] = [] //for going from row-entry-order to database-order
        //for division B events
        //yeah... this isn't efficient but there's not much time
        /*for i in 0..<numDivB {
            actualIndices.append(internalTeamNumbers.index(of: i)!)
        }
        for i in 0..<(teamsData.count - numDivB) {
            actualIndices.append(internalTeamNumbers.index(of: i)!)
        }*/
        //officialTeamNums  = actualIndices.map{EventsData.officialNumbers[$0]}
        //officialTeamNames = actualIndices.map{EventsData.roster[$0]}
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateValues()
    }
    
    override func viewDidLoad() {
        self.updateValues()
        super.viewDidLoad()
        schoolPicker.dataSource = self
        schoolPicker.delegate = self
        //set default value, but beware that this is zero-indexed
        //let sNumber0 = EventsData.roster.index(of: EventsData.currentSchool)!
        let sNumber0 = EventsData.currentSchool
        schoolPicker.selectRow(sNumber0, inComponent: 0, animated: false)
    }
    
    func numberOfComponents(in eventPicker: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //let divTeams = EventsData.divXTeams(div: EventsData.div) //retrieve the appropriate team list
        return EventsData.roster.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //return String("(\(EventsData.teamNumber())) \(EventsData.roster[row])")
        //get the internal team number corresponding to the entry in question
        /*let divTeams = EventsData.divXTeams(div: EventsData.div)
        let internalTeamNum = divTeams[row]
        
        //want to get the official number now
        //first we need to find the actual index (rather than the internal one)
        let teamsData = DLM.dlFiles.files[1].data
        let internalNumberList = (getCol(array: teamsData, col: 0) as! [String]).map{Int($0)!}
        let actualIndex = internalNumberList.index(of: internalTeamNum)!
        let officialTeamNum = EventsData.officialNumbers[actualIndex]
        
        let teamNumStr = "(\(officialTeamNum)\(EventsData.div)) "
        let teamEntry = teamNumStr + EventsData.roster[actualIndex]
        return teamEntry*/
        
        //let teamNumStr = "(\(officialTeamNums[row])\(row<numDivB ? "B" : "C")) "
        //return teamNumStr + officialTeamNames[row]
        
        let realNum = row
        let teamNumStr = "(\(EventsData.officialNumbers[realNum])\(row<numDivB ? "B" : "C")) "
        return teamNumStr + EventsData.roster[realNum]
        
    }
    
    @IBAction func doneButton(_ sender: Any) {
        let row = schoolPicker.selectedRow(inComponent: 0)
        EventsData.currentSchool = row
        EventsData.div = row<numDivB ? "B" : "C"
        
        print("Selected Division: \(EventsData.div)")
        print("Internal Number: \(EventsData.currentSchool)")
        print("Official Number: \(EventsData.officialNumbers[row])")
        
        saveSelectedSchool(currentSchool: row) //save
        
        //sendSchoolNotificationToUpdate()
        self.dismiss(animated: true, completion: nil)
    }
    
    /*func sendSchoolNotificationToUpdate() -> Void {
        NotificationCenter.default.post(name: .reloadSchoolName, object: nil)
    }*/
    
}


let teamAppDelegate = UIApplication.shared.delegate as! AppDelegate
let teamContext = teamAppDelegate.persistentContainer.viewContext
let teamRequest = NSFetchRequest<Teams>(entityName: "Teams")

//write current school to disk
func saveSelectedSchool(currentSchool: Int) -> Void {
    clearSchools()
    let newTeam = NSEntityDescription.insertNewObject(forEntityName: "Teams", into: teamContext)
    newTeam.setValue (currentSchool, forKey: "number")
    do {
        try teamContext.save()
        //print("teamContext saved properly")
    }
    catch {
        print("Something went wrong with adding a team")
    }
}

//clear team names from disk
func clearSchools() -> Void {
    do {
        let results = try teamContext.fetch(teamRequest) as [NSManagedObject]
        if results.count > 0 {
            //delete all results
            for object in results {
                //print("Removed \(object)")
                teamContext.delete(object)
            }
        }
    } catch {
        print("Something went wrong clearing out all the teams from disk")
    }
}

//load school from disk
func loadSchoolName() -> Void {
    teamRequest.returnsObjectsAsFaults = false
    do {
        let results = try teamContext.fetch(teamRequest)
        if results.count > 0 {
            let result = results.first
            /*if let schoolNumber = (result as AnyObject).value(forKey:"name") as? Int {
                EventsData.currentSchool = schoolNumber
                print("Loaded team: \(EventsData.roster[schoolNumber])")
            }*/
            EventsData.currentSchool = Int(result!.number)
            //print("Loaded team: \(EventsData.roster[EventsData.currentSchool])")
        }
    }
    catch {
        print("Something went wrong loading the school from disk...")
    }
}
