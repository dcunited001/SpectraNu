//
//  SpectraSharedExamples.swift
//  
//
//  Created by David Conner on 3/12/16.
//
//

import Foundation
import Quick
import Nimble
import Swinject
import Metal
import ModelIO

class SpectraSharedExamples: QuickConfiguration {
    override class func configure(configuration: Configuration) {
        sharedExamples("it has generator args") {
            it("parses generator args") {
                
            }
            
            it("applies generator args") {
                
            }
        }
        
        //        sharedExamples("shared examples that take a context") { (sharedExampleContext: SharedExampleContext) in
        //            it("is passed the correct parameters via the context") {
        //                let callsite = sharedExampleContext()[NSString(string: "callsite")] as! NSString
        //                expect(callsite).to(equal("SharedExamplesSpec"))
        //            }
        //        }
    }
}
