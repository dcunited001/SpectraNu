//
//  ModelIOMeshUsageSpec.swift
//  SpectraOSX
//
//  Created by David Conner on 2/21/16.
//  Copyright © 2016 Spectra. All rights reserved.
//

@testable import Spectra
import Foundation
import Quick
import Nimble

class ModelIOMeshUsageSpec: QuickSpec {
    
    // NOTE: this spec is really for my benefit, so I can play around with some MDLMeshBuffer examples.  i need to determine the following:
    // - how to create/structure MDLVertexDescriptors & how best to read the definitions for these in via XML
    // - how to combinate MDLVertexAttribute's for mesh buffers.  how to adapt for differing lengths for the same type of attribute
    // - how to convert from 'structure of arrays' format to 'array of structures' format, when altering mesh or adding an attribute or something.
    // - how to convert from MDLVertexDescriptor to MTLVertexDescriptor.  can i automate this?  all of it (even binding that descriptor's definition to the shaders? swift seemed to not be capable of this)
    // - how to structure dependency injection for geometry
    
    override func spec() {
        
        describe("MDLVertexAttribute") {
            
        }
        
        describe("MDLVertexDescriptor") {
            
        }
        
        describe("MDLMeshBufferData") {
            it("parses enumGroups from XSD") {

            }
        }
    }
}
