//
//  Spectra_OSXTests.swift
//  Spectra-OSXTests
//
//  Created by David Conner on 11/28/15.
//  Copyright © 2015 Spectra. All rights reserved.
//

@testable import SpectraOSX
import Quick
import Nimble

class SpectraOSXTests: QuickSpec {
    override func spec() {
        expect(Spectra.foo()).to(beTrue())
    }
}
