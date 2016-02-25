//
//  SpectraXML.swift
//  
//
//  Created by David Conner on 2/22/16.
//
//

import Foundation
import Fuzi
import Swinject
import ModelIO

public enum SpectraXMLNodeType: String {
    case World = "world"
    case Camera = "camera"
    case VertexDescriptor = "vertex-descriptor"
    case VertexAttribute = "vertex-attribute"
    case Asset = "asset"
    case Material = "material"
    case MaterialProperty = "material-property"
    case Texture = "texture"
    case Mesh = "mesh"
}

// TODO: how to specify monadic behavior with xml?

public typealias SpectraXMLNodeParser = ((container: Container, node: XMLNode, key: String, options: [String: AnyObject]) -> Any)

//public class SpectraXMLNodeParser {
//    var parser: ((node: XMLNode, key: String, options: [String: AnyObject]) -> Any)?
//    
//    public init() {
//        
//    }
//}
//
//typealias FooStringer = ((String) -> Any)

public class SpectraXML {
    var xml: XMLDocument?
    var parser: Container
    
    public init(data: NSData, parser: Container? = SpectraXML.initParser()) {
        self.parser = parser!
        
        do {
            xml = try XMLDocument(data: data)
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
    
    public class func initParser() -> Container {
        var parser = Container()
        
        // TODO: what's the type here? type could be:
        // - a specific node type SpectraFooXMLNode (use same pattern as before (yuck))
        // - a closure type: (foo: Bar) -> MDLBaz)
        
        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.World.rawValue) { (r, k: String) in
//            let parser: SpectraXMLNodeParser =
            return { (container, node, key, options) in
                return "foo"
            }
        }
        
//            { (r: Container, key: String, options: [String: AnyObject]) in
//            return "welllll fuck"
//            return { (node: XMLNode, options: [String: AnyObject]) in
//                // do node things, return shit
//            }
//        }
        
        return parser
    }
    
    public func parse(container: Container, options: [String: AnyObject] = [:]) {
        for child in xml!.root!.children {
            let (tag, key) = (child.tag!, child.attributes["key"])
            
            switch SpectraXMLNodeType(rawValue: tag)! {
            case .World: break
            case .Camera: break
            case .VertexDescriptor: break
            case .VertexAttribute: break
            default: break
            }
        }
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