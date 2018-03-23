//
//  ModalEventPicker.swift
//  UCSO Invitational 2018
//
//  Created by Jung-Sun Yi-Tsang on 12/28/17.
//  Copyright © 2017 bayser. All rights reserved.
//

import UIKit

class ModalEventPicker: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var eventPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventPicker.dataSource = self
        eventPicker.delegate = self
    }

    func numberOfComponents(in eventPicker: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //return EventsData.completeList[component]
        return EventsData.completeSOEventList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EventsData.completeSOEventList[row]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //add the current selection into the events list
    @IBAction func addButton(_ sender: Any) {
        let row = eventPicker.selectedRow(inComponent: 0)
        let newEvent = EventsData.completeSOEventList[row]
        if !(EventsData.selectedList.contains(newEvent)) {
            print("\(newEvent) added!")
            EventsData.selectedList.append(newEvent)
            addEvent(eventName: newEvent)
            //NotificationCenter.default.post(name: .reloadSchoolName, object: nil)
            
            cancelButton(addButton)
        } else {
            let alert = UIAlertController(title: "Event Seletion", message: "You've already selected this event", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title:
                    NSLocalizedString("Ok", comment: "Default action"),
                    style: .default)
            )
            self.present(alert, animated: true, completion: nil)
            //how to execute something after user presses ok??
        }
    }

    @IBAction func cancelButton(_ sender: Any) {
        //print(EventsData.selectedList)
        //sendNotificationToUpdate()
        self.dismiss(animated: true, completion: nil)
    }
    
    /*func sendNotificationToUpdate() -> Void {
        NotificationCenter.default.post(name: .reload, object: nil)
    }*/
}
