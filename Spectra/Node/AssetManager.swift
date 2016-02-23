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
        let spectraEnumData = SpectraXSD.readXSD("SpectraEnums")
        let spectraEnumXSD = SpectraXSD(data: spectraEnumData)
        spectraEnumXSD.parseEnumTypes(container)
    }
    
    public func getEnum(name: String, key: String) -> UInt {
        return container.resolve(SpectraEnum.self, name: name)!.getValue(key)
    }
}

class SpectraEnum {
    let name: String
    var values: [String: UInt]
    
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


// TODO: is there struct value that makes sense here?
// - so, like a single struct value that can be used in case statements
// - but also carries a bit of info about the params of each type?
public enum SpectraVertexAttrType: String {
    // raw values for enums must be literals,
    // - so i can't use the MDLVertexAttribute string values
    case Anisotropy = "anisotropy"
    case Binormal = "binormal"
    case Bitangent = "bitangent"
    case Color = "color"
    case EdgeCrease = "edgeCrease"
    case JointIndices = "jointIndices"
    case JointWeights = "jointWeights"
    case Normal = "normal"
    case OcclusionValue = "occlusionValue"
    case Position = "position"
    case ShadingBasisU = "shadingBasisU"
    case ShadingBasisV = "shadingBasisV"
    case SubdivisionStencil = "subdivisionStencil"
    case Tangent = "tangent"
    case TextureCoordinate = "textureCoordinate"
    
    // can't add this to the SpectraEnums.xsd schema,
    // - at least not directly, since it's not an enum
}

public class SpectraXSD {
    public var xsd: XMLDocument?
    
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
            let enumType = SpectraEnum(elem: enumChild)
            container.register(SpectraEnum.self, name: enumType.name) { _ in
                return enumType
            }
        }
    }
}