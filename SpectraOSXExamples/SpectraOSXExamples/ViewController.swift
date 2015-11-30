//
//  ViewController.swift
//  SpectraOSXExamples
//
//  Created by David Conner on 11/30/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Cocoa
import SpectraOSX

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Spectra.foo()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

