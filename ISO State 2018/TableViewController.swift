//
//  TableViewController.swift
//  UCSO Invitational 2018
//
//  Created by Jung-Sun Yi-Tsang on 12/28/17.
//  Copyright © 2017 bayser. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    //reload table data when it's opened
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadTableData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: .reload, object: nil)
        let edit = self.editButtonItem
        let space = UIBarButtonItem(title: "  ", style: .plain, target: self, action: nil)
        let clear = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearAll))
        self.navigationItem.rightBarButtonItems = [edit, space, clear]
        self.navigationItem.title = "Choose Events"
        //print(EventsData.list)
        loadEvents()
        self.cleanDuplicates()
    }
    
    //reloads the soevent table data
    func reloadTableData() {
        tableView.reloadData()
    }
    
    //procedure for clearing everything
    @objc func clearAll() {
        EventsData.selectedList = []
        clearEvents()
        tableView.reloadData()
        //NotificationCenter.default.post(name: .reloadSchoolName, object: nil)
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventsData.selectedList.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel!.text = EventsData.selectedList[indexPath.row]
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source as well as core data
            let delEvent = tableView.cellForRow(at: indexPath)!.textLabel!.text!
            _ = removeEvent(eventName: delEvent, indexPath: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        //sendNotificationToUpdateSched()
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let eventA = EventsData.selectedList[fromIndexPath.row]
        EventsData.selectedList.remove(at: fromIndexPath.row)
        EventsData.selectedList.insert(eventA, at: to.row)
        saveEvents() //preserve order
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
 
    //get rid of duplicate entries
    //also saves to disk
    func cleanDuplicates() {
        var tmp: [String] = [] //will store the new string
        for ev in EventsData.selectedList {
            if !tmp.contains(ev) {
                tmp.append(ev)
            }
        }
        EventsData.selectedList = tmp
        saveEvents()
    }
    
    /*func sendNotificationToUpdateSched() -> Void {
        NotificationCenter.default.post(name: .reloadSchoolName, object: nil)
    }*/
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        saveEvents()
    }
 

}
