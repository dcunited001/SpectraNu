//
//  RandomMeshGenerators.swift
//  
//
//  Created by David Conner on 3/5/16.
//
//

@testable import Spectra
import Quick
import Nimble


class RandomMeshGeneratorsSpec: QuickSpec {
    
    func containerGet<T>(container: Container, key: String) -> T? {
        return container.resolve(T.self, name: key)
    }
    
    override func spec() {
        // read xsd
        // read xml
        // ...

        //TODO: describe("Random2DMeshGen") {}
        //TODO: describe("Random3DMeshGen") {}
    }
}

