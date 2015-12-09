//
//  ViewController.swift
//  Spectra-iOSExample
//
//  Created by David Conner on 12/9/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import UIKit
import Spectra
import Fuzi

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Spectra.foo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

