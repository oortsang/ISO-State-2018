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
    
    override func viewDidLoad() {
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
        return EventsData.roster.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String("(\(row+1)) \(EventsData.roster[row])")
    }
    
    @IBAction func doneButton(_ sender: Any) {
        let row = schoolPicker.selectedRow(inComponent: 0)
        EventsData.currentSchool = row
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
let teamRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Teams")

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
        let results = try teamContext.fetch(teamRequest) as? [NSManagedObject]
        if results!.count > 0 {
            //delete all results
            for object in results! {
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
            if let schoolNumber = (result as AnyObject).value(forKey:"name") as? Int {
                EventsData.currentSchool = schoolNumber
                print("Loaded team: \(EventsData.roster[schoolNumber])")
            }
        }
    }
    catch {
        print("Something went wrong loading the school from disk...")
    }
}
