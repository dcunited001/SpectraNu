//
//  ViewController.swift
//  SpectraiOSExamples
//
//  Created by David Conner on 11/30/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import UIKit
import SpectraiOS

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
