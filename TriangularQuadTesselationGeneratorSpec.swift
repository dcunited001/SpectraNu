//
//  TriangularQuadTesselationGeneratorSpec.swift
//  
//
//  Created by David Conner on 12/14/15.
//
//

@testable import Spectra
import Foundation
import Quick
import Nimble


class TriangularQuadLatticeGeneratorSpec: QuickSpec {
    override func spec() {
        
        let device = MTLCreateSystemDefaultDevice()
        let library = device!.newDefaultLibrary()
        let testBundle = NSBundle(forClass: S3DXMLSpec.self)
        let xmlData: NSData = S3DXML.readXML(testBundle, filename: "S3DXMLTest")
        let xml = S3DXML(data: xmlData)
        
        var descriptorManager = SpectraDescriptorManager(library: library!)
        descriptorManager = xml.parse(descriptorManager)
        
        describe("TriangularQuadLatticeGenerator") {
//            it("tesselates an existing quad") {
//                //TODO: implement and test
//            }
        }
    }
}