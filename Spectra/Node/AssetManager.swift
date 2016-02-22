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

// manages meshs, before they are pushed into a scene graph
public class AssetManager {
    public var container: Container
    
    public init() {
        container = Container()
        let spectraEnumData = SpectraXSD.readXSD("SpectraEnums")
        xsd.parseEnumTypes(container)
    }
}

class SpectraEnum {
    let name: String
    let values: [String: UInt]
    
    public init(elem: XMLElement) {
        values = [:]
        name = elem.attributes["name"]!
        let valuesSelector = "xs:restriction > xs:enumeration"
        for child in elem.css(valuesSelector) {
            let val = child.attributes["id"]!
            let key = child.attributes["value"]!
            self.values[key] = UInt(val)
        }
    }
    
    public func getValue(key: String) -> UInt {
        return values[key]!
    }
}

public class SpectraXSD {
    
    public var xsd: XMLDocument?
    var enumTypes: [String: S3DMtlEnum] = [:]
    
    public init(data: NSData) {
        do {
            xsd = try XMLDocument(data: data)
        } catch let err as XMLError {
            switch err {
            case .ParserFailure, .InvalidData: print(err)
            case .LibXMLError(let code, let message): print("libxml error code: \(code), message: \(message)")
            default: break
            }
        } catch let err {
            print("error: \(err)")
        }
    }
    
    public class func readXSD(filename: String) -> NSData {
        let bundle = NSBundle(forClass: S3DXSD.self)
        let path = bundle.pathForResource(filename, ofType: "xsd")
        let data = NSData(contentsOfFile: path!)
        return data!
    }
    
    public func parseEnumTypes(container: Container) {
        let enumTypesSelector = "xs:simpleType[mtl-enum=true]"
        
        for enumChild in xsd!.css(enumTypesSelector) {
            let enumType = S3DMtlEnum(elem: enumChild)
            container.register(S3DMtlEnum.self, name: enumType.name) { _ in
                return enumType
            }
        }
    }
}