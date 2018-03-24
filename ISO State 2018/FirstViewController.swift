//
//  FirstViewController.swift
//  UCSO Invitational 2018
//
//  Created by Jung-Sun Yi-Tsang on 12/10/17.
//  Copyright © 2017 bayser. All rights reserved.
//

import UIKit
import MapKit

class FirstViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //DLM.dlFiles.manualStart()
        
        //let centerLoc = CLLocationCoordinate2DMake(41.79, -87.6)
        //let mapSpan = MKCoordinateSpanMake(0.01, 0.01)
        let centerLoc = CLLocationCoordinate2DMake(41.79, -87.599)
        let mapSpan = MKCoordinateSpanMake(0.015, 0.015)
        let mapRegion = MKCoordinateRegion(center: centerLoc, span: mapSpan)
        self.map.setRegion(mapRegion, animated: true)
        
        MyList.initiate()
        for pt in MyList.locPoints {
            self.map.addAnnotation(pt)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

