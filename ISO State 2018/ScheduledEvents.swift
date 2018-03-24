//
//  ScheduledEvents.swift
//  ISO State 2018
//
//  Created by Jung-Sun Yi-Tsang on 3/24/18.
//  Copyright © 2018 bayser. All rights reserved.
//

import UIKit


class SchedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
//class SchedViewController: UITableViewController {
    @IBOutlet weak var SchedView: UITableView!
    
    let list = ["cycle", "elcyc"]
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(ScheduleData.schedEvents)
        return ScheduleData.schedEvents.count
        //return list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "schedule", for: indexPath)
        print(ScheduleData.schedEvents)
        cell = (ScheduleData.schedEvents[indexPath.row] as EventLabel).printCell(cell: cell)
        //cell.textLabel?.text = list[indexPath.row]
        return cell
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SchedView.reloadData()
    }
    
}
