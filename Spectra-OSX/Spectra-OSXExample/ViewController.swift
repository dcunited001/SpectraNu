//
//  ViewController.swift
//  Spectra-OSXExample
//
//  Created by David Conner on 12/9/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

import Cocoa
import Spectra
import Fuzi
import Metal

class ViewController: NSViewController {
    
    var device: MTLDevice?
    var library: MTLLibrary?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        library = device!.newDefaultLibrary()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

