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
    
    public func nodeParser(node: XMLNode, key: String, options: [String:AnyObject] = [:]) -> SpectraXMLNodeParser? {
        
        switch self {
        case .World:
            return {(container, node, key, options) in
                return "world"
            }
        case .Camera:
            return {(container, node, key, options) in
                return "camera"
            }
        case .VertexDescriptor:
            return {(container, node, key, options) in
                return "vertex-descriptor"
            }
        case .VertexAttribute:
            return {(container, node, key, options) in
                return "vertex-attribute"
            }
        default: return nil
        }

    }
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
        
        //TODO: how to ensure that typing is consistent?
        // return [fnParse -> Any, fnCast -> MDLType] // this may work
        
        // yes, the design's a bit convoluted, but allows great flexability!
        // - note: with great flexibility, comes great responsibility!!
        //   - this is true, both from a performance aspect (reference retention) 
        // - as well as from a security aspect (arbitrary execution from remote XML)
        //   - spectra is intended as a LEARNING TOOL ONLY at this point.
        
        // NOTE: you can override default behavior by returning an alternative closure
        // - just do parser.register() and override.
        // - you can also do newParser = Container(parent: parser) 
        //   - and then create a tree of custom parsers (see Swinject docs)
        
        // NOTE: if you do override default behavior for nodes: beware scoping
        // - if you pass node into the closure that's returned, it will stick around
        //   - instead just use node to determine which closure to return
        //   - that closure will get the node anyways
        // - same thing with options: beware retaining a reference
        
        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.World.rawValue) { (r, k: String, node: XMLNode, options: [String:AnyObject]) in
            return SpectraXMLNodeType.World.nodeParser(node, key: k, options: options)!
        }
        
        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.VertexAttribute.rawValue) { (r, k: String, node: XMLNode, options: [String:AnyObject]) in
            return SpectraXMLNodeType.VertexAttribute.nodeParser(node, key: k, options: options)!
        }
        
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