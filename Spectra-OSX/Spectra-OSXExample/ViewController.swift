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
import Swinject

class ViewController: NSViewController {
    
    var device: MTLDevice?
    var library: MTLLibrary?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: tie device/library to those initialized in containers
        
        self.device = MTLCreateSystemDefaultDevice()
        self.library = device!.newDefaultLibrary()

        // Do any additional setup after loading the view.
        let appBundle = NSBundle(forClass: ViewController.self)
        let xml = MetalParser.readXML(appBundle, filename: "DefaultPipeline", bundleResourceName: nil)!
        
        let metaContainer = MetalParser.initMetalEnums(Container())
        MetalParser.initMetal(metaContainer)
        
        let metalParser = MetalParser(parentContainer: metaContainer)
        metalParser.parseXML(xml)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

