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
import Swinject

class ViewController: UIViewController {
    
    var device: MTLDevice?
    var library: MTLLibrary?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.device = MTLCreateSystemDefaultDevice()
        self.library = device!.newDefaultLibrary()
        
        // Do any additional setup after loading the view.
        let appBundle = NSBundle(forClass: ViewController.self)
        let xmlData: NSData = S3DXML.readXML(appBundle, filename: "DefaultPipeline")
        let s3d = S3DXML(data: xmlData)
        
        var descMan = DescriptorManager(library: library!)
        descMan.parseS3DXML(s3d)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

