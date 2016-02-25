//
//  SpectraXMLSpec.swift
//  
//
//  Created by David Conner on 2/23/16.
//
//

import Foundation
import Quick
import Nimble
import ModelIO
import Fuzi
import Spectra
import simd

class SpectraXMLSpec: QuickSpec {
    
    override func spec() {
        let testBundle = NSBundle(forClass: SpectraXMLSpec.self)
        let xmlData: NSData = SceneGraphXML.readXML(testBundle, filename: "SceneGraphXMLTest")
        let spectraXML = SpectraXML(data: xmlData)
        
        describe("vertex-attribute") {
            it("can parse vertex attribute nodes") {
                
            }
        }
        
        describe("vertex-descriptor") {
            it("can parse vertex descriptor nodes") {
                
            }
        }
        
        describe("world-view") {
            it("can parse world view nodes") {
                
            }
        }
        
        describe("camera") {
            it("can parse camera nodes") {
                
            }
        }
        
        describe("perspective") {
            it("can parse perspective nodes") {
                
            }
        }
    }
}


