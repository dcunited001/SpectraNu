//
//  XSD.swift
//  
//
//  Created by David Conner on 3/9/16.
//
//

import Foundation
import Fuzi
import Swinject

public class SpectraEnum {
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

    public func getValue(id: String) -> UInt {
        return values[id]!
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
    public class func readXSD(filename: String) -> XMLDocument? {
        let bundle = NSBundle(forClass: MetalXSD.self)
        let path = bundle.pathForResource(filename, ofType: "xsd")
        let data = NSData(contentsOfFile: path!)
        
        do {
            return try XMLDocument(data: data!)
        } catch let err as XMLError {
            switch err {
            case .ParserFailure, .InvalidData: print(err)
            case .LibXMLError(let code, let message): print("libxml error code: \(code), message: \(message)")
            default: break
            }
        } catch let err {
            print("error: \(err)")
        }
        return nil
    }

    public func parseXSD(xsd: XMLDocument, container: Container = Container()) -> Container {
        let enumTypesSelector = "xs:simpleType[mtl-enum=true]"

        for enumChild in xsd.css(enumTypesSelector) {
            let enumType = SpectraEnum(elem: enumChild)
            container.register(SpectraEnum.self, name: enumType.name) { _ in
                return enumType
            }
        }
        
        return container
    }
}