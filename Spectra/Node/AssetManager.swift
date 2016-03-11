//
//  SceneManager.swift
//  
//
//  Created by David Conner on 2/22/16.
//
//

import Foundation
import Metal
import ModelIO
import Swinject
import Fuzi

// manages meshs, before they are pushed into a scene graph
public class AssetManager {
    public var container: Container = Container()
    
    public init() {
        let spectraEnumXSD = SpectraXSD.readXSD("SpectraEnums")
        let spectraXSD = SpectraXSD()
        container = spectraXSD.parseXSD(spectraEnumXSD, container: container)
    }
    
    public func getEnum(name: String, key: String) -> UInt {
        return container.resolve(SpectraEnum.self, name: name)!.getValue(key)
    }
}

