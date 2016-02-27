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

public typealias SpectraXMLNodeTuple = (construct: Any, meta: [String: Any]?)
// meta is used when the construct returns a monad
// meta should include a function at key: resolve
// - the function should be expected to receive itself as args
// - i.e. meta["resolve"](meta) should resolve to a function to which it can pass the construct function
// - i.e. meta["resolve"](meta)(construct) should return a final object

// meta keys could also include the following for casting:
// - klass: AnyClass?, strukt: Any?, protokol: Any?

// should it be necessary to pass the key here?
public typealias SpectraXMLNodeParser = ((container: Container, node: XMLElement, key: String?, options: [String: Any]) -> SpectraXMLNodeTuple)

public enum SpectraXMLNodeType: String {
    case World = "world"
    case Camera = "camera"
    case StereoscopicCamera = "stereoscopic-camera"
    case VertexAttribute = "vertex-attribute"
    case VertexDescriptor = "vertex-descriptor"
    case Asset = "asset"
    case Material = "material"
    case MaterialProperty = "material-property"
    case ScatteringFunction = "scattering-function"
    case Texture = "texture"
    case TextureFilter = "texture-filter"
    case TextureSampler = "texture-sampler"
    case Light = "light"
    
    public func nodeParser(node: XMLElement, key: String, options: [String:Any] = [:]) -> SpectraXMLNodeParser? {
        
        // Achievement Unlocked: API allows for recursive resolution of variadically structured categories into a final object of any type ... ok well maybe it doesn't quite do this yet
        
        switch self {
        case .World:
            return {(container, node, key, options) in
                let nodeTuple: SpectraXMLNodeTuple = (construct: "a world.  or a (worldFn, meta) tuple", meta: [:])
                return nodeTuple
            }
        case .Camera:
            return {(container, node, key, options) in
                let nodeTuple: SpectraXMLNodeTuple = (construct: "a camera.  or a (cameraFn, meta) tuple", meta: [:])
                return nodeTuple
            }
        case .VertexAttribute:
            return {(container, node, key, options) in
                let vertexAttr = SpectraXMLVertexAttributeNode().parse(container, elem: node, options: options)
                let nodeTuple: SpectraXMLNodeTuple = (construct: vertexAttr, meta: [:])
                return nodeTuple
            }
        case .VertexDescriptor:
            return {(container, node, key, options) in
                let vertexDesc = SpectraXMLVertexDescriptorNode().parse(container, elem: node, options: options)
                let nodeTuple: SpectraXMLNodeTuple = (construct: vertexDesc, meta: [:])
                return nodeTuple
            }
        default: return nil
        }
    }
    
    public func nodeFinalType(parser: Container) -> AnyClass? {
        switch self {
        case .VertexAttribute: return MDLVertexAttribute.self
        case .VertexDescriptor: return MDLVertexDescriptor.self
        default: return nil // custom types must be resolved separately
        }
    }
}

public class SpectraXML {
    var xml: XMLDocument?
    var parser: Container
    
    public init(parser: Container, data: NSData) {
        // NOTE: both this parser and the container injected into the SpectraXMLNodeParser functions
        // - should be able to reference the enum types read from the XSD file
        // - the simplest way to do this is create a container, load the XSD enums onto it, 
        //   - then use this parser container as a parent: nodeParserContainer = Container(parent: parser)
        //   - refer to SpectraXMLSpec for an example
        // - or, if scoping is an issue, apply the enums to both the parser & nodeParser containers
        self.parser = parser
        
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
    
    public class func initParser(parser: Container) -> Container {
        //TODO: how to ensure that typing is consistent?
        // return [fnParse -> Any, fnCast -> MDLType] // this may work
        
        // yes, the design's a bit convoluted, but allows great flexibility!
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
        
        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.VertexAttribute.rawValue) { (r, k: String, node: XMLElement, options: [String: Any]) in
            return SpectraXMLNodeType.VertexAttribute.nodeParser(node, key: k, options: options)!
            }.inObjectScope(.None) // always return a new instance of the closure
        
        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.VertexDescriptor.rawValue) { (r, k: String, node: XMLElement, options: [String:Any]) in
            return SpectraXMLNodeType.VertexDescriptor.nodeParser(node, key: k, options: options)!
            }.inObjectScope(.None) // always return a new instance of the closure
        
//        parser.register(SpectraXMLNodeParser.self, name: SpectraXMLNodeType.World.rawValue) { (r, k: String, node: XMLElement, options: [String: Any]) in
//            return SpectraXMLNodeType.World.nodeParser(node, key: k, options: options)!
//            }.inObjectScope(.None) // always return a new instance of the closure
        
        return parser
    }
    
    public func parse(container: Container, options: [String: Any] = [:]) {
        for child in xml!.root!.children {
            let (tag, key) = (child.tag!, child.attributes["key"])

            let nodeParser = self.parser.resolve(SpectraXMLNodeParser.self, arguments: (tag, key, child, options))!
            
            // TODO: resolve custom types
            //            parser.resolve(AnyClass.self, name: self.rawValue)
            
            let nodeTuple = nodeParser(container: container, node: child, key: key, options: options)
            
            // TODO: use options to set ObjectScope (default to .Container?)
            
            // TODO: recursively resolve non-final types in tuple:
            // - i.e. if some monad returns instead of concrete value,
            //   - then try to resolve the monad (should metadata also be returned?)
            //   - this may be a feature to implement down the road
            // - it can be resolved by returning either a tuple with metadata
            //   - or a hash of [String: Any], but the tuple is superior
            //   - tuple: (SpectraMonadType, [String: Any])
            // - but i still would have to perform type resolution on the [String: Any]
            //   - if the tupal is to be useful and dynamic
            
        }
    }
}

public class SpectraXMLSimd {
    
    public static func parseDoubles(str: String) -> [Double] {
        let valStrs = str.characters.split { $0 == " " }.map(String.init)
        return valStrs.map() { Double($0)! }
    }
    
    public static func parseInts(str: String) -> [Int] {
        let valStrs = str.characters.split { $0 == " " }.map(String.init)
        return valStrs.map() { Int($0)! }
    }
    
    public static func parseInt32s(str: String) -> [Int32] {
        let valStrs = str.characters.split { $0 == " " }.map(String.init)
        return valStrs.map() { Int32($0)! }
    }
    
    public static func parseFloats(str: String) -> [Float] {
        let valStrs = str.characters.split { $0 == " " }.map(String.init)
        return valStrs.map() { Float($0)! }
    }
    
    public static func parseFloat2(str: String) -> float2 {
        return float2(parseFloats(str))
    }
    
    public static func parseInt2(str: String) -> int2 {
        return int2(parseInt32s(str))
    }
    
    public static func parseFloat3(str: String) -> float3 {
        return float3(parseFloats(str))
    }
    
    public static func parseInt3(str: String) -> int3 {
        return int3(parseInt32s(str))
    }
    
    public static func parseFloat4(str: String) -> float4 {
        return float4(parseFloats(str))
    }
    
    public static func parseInt4(str: String) -> int4 {
        return int4(parseInt32s(str))
    }
}

public protocol SpectraXMLNode {
    typealias NodeType
    
    // TODO: why not attach elem, etc. as attributes? scoping?
    
    func parse(container: Container, elem: XMLElement, options: [String: Any]) -> NodeType
}

public class SpectraXMLAssetNode: SpectraXMLNode {
    public typealias NodeType = MDLAsset
    
    public func parse(container: Container, elem: XMLElement, options: [String: Any]) -> NodeType {
        let urlString = elem.attributes["url"]!
        var vertexDesc: MDLVertexDescriptor?
        
        if let vertexDescKey = elem.attributes["vertex-descriptor-ref"] {
            vertexDesc = container.resolve(MDLVertexDescriptor.self, name: vertexDescKey)
        }
        
        if let bufferAllocKey = elem.attributes["mesh-buffer-allocator-ref"] {
            // TODO: buffer allocation
        }
        
        let asset = MDLAsset()
        
        // TODO: set asset properties
        
        return asset
    }
}

public class SpectraXMLVertexAttributeNode: SpectraXMLNode {
    public typealias NodeType = MDLVertexAttribute
    
    public func parse(container: Container, elem: XMLElement, options: [String: Any]) -> NodeType {
        let vertexAttr = MDLVertexAttribute()
        
        // TODO: determine which of these are required
        // TODO: abstract this logic, so if user overrides the closure,
        // - they don't need to reimplement basics
        
        if let name = elem.attributes["name"] {
            vertexAttr.name = name
        }
        if let format = elem.attributes["format"] {
            let enumVal = container.resolve(SpectraEnum.self, name: "mdlVertexFormat")!.getValue(format)
            vertexAttr.format = MDLVertexFormat(rawValue: enumVal)!
        }
        if let offset = elem.attributes["offset"] {
            vertexAttr.offset = Int(offset)!
        }
        if let bufferIndex = elem.attributes["bufferIndex"] {
            vertexAttr.bufferIndex = Int(bufferIndex)!
        }
        if let initializationValue = elem.attributes["initialization-value"] {
            vertexAttr.initializationValue = SpectraXMLSimd.parseFloat4(initializationValue)
        }
        
        return vertexAttr
    }
}

public class SpectraXMLVertexDescriptorNode: SpectraXMLNode {
    public typealias NodeType = MDLVertexDescriptor
    
    public func parse(container: Container, elem: XMLElement, options: [String : Any]) -> NodeType {
        var vertexDesc = MDLVertexDescriptor()
        
        // if user specified a parent descriptor, find it and copy it
        // - any named property will be overwritten
        if let parentDescriptor = elem.attributes["parent-descriptor"] {
            let parentDesc = container.resolve(MDLVertexDescriptor.self, name: parentDescriptor)!
            vertexDesc = MDLVertexDescriptor(vertexDescriptor: parentDesc)
        }
        
        let attributeSelector = "vertex-attributes > vertex-attribute"
        for (idx, el) in elem.css(attributeSelector).enumerate() {
            if let ref = el.attributes["ref"] {
                let vertexAttr = container.resolve(MDLVertexAttribute.self, name: ref)!
                vertexDesc.addOrReplaceAttribute(vertexAttr)
            } else {
                let vertexAttr = SpectraXMLVertexAttributeNode().parse(container, elem: el, options: options)
                vertexDesc.addOrReplaceAttribute(vertexAttr)
            }
        }
        
        // TODO: possibly split this into "packed-stride" and "packed-offset"
        // TODO: decide whether more complicated, nested layouts should be allowed
        if let packedLayout = elem.attributes["packed-layout"] where NSString(string: packedLayout).boolValue {
            vertexDesc.setPackedOffsets()
            vertexDesc.setPackedStrides()
        } else {
            // ensure that buffer indices are set
            // - and all buffer offsets are zero'd
            // -
        }
        
        return vertexDesc
    }
}

//TODO: public class SpectraXMLWorldNode: SpectraXMLNode
//TODO: public class SpectraXMLMeshNode: SpectraXMLNode
//TODO: public class SpectraXMLMeshGeneratorNode: SpectraXMLNode
//TODO: public class SpectraXMLObjectNode: SpectraXMLNode

//============================================================
// TODO: decide how to handle inheritance
// - use separate node classes for each instance 
//   - this would be appropriate for some, like MDLCamera & Stereoscopic (except phys lens & phys imaging)
//   - but gets cumbersome for other classes, like MDLTexture, etc.
//   - and isn't extensible
// - there's also the mesh-generator pattern from the original SceneGraphXML
//   - this draws from a map of monads passed in and executes the one for a specific type, if found

public struct SpectraPhysicalLensParams {
    // TODO: determine which are required and which are not
    public var key: String?
    public var barrelDistorion: Float?
    public var fisheyeDistorion: Float?
    public var opticalVignetting: Float?
    public var chromaticAberration: Float?
    public var focalLength: Float?
    public var fStop: Float?
    public var apertureBladeCount: Int?
//    public var bokehKernelWithSize: vector_int2 -> MDLTexture
    public var maximumCircleOfConfusion: Float?
    public var focusDistance: Float?
    public var shutterOpenInterval: NSTimeInterval?
}

public class SpectraXMLPhysicalLensNode: SpectraXMLNode {
    public typealias NodeType = SpectraPhysicalLensParams
    
    public func parse(container: Container, elem: XMLElement, options: [String: Any]) -> NodeType {
        return SpectraPhysicalLensParams()
    }
}

public struct SpectraPhysicalImagingSurfaceParams {
    // TODO: determine which are required and which are not
    public var key: String?
    public var sensorVerticalAperture: Float?
    public var sensorAspect: Float?
    public var sensorEnlargement: vector_float2?
    public var sensorShift: vector_float2?
    public var flash: vector_float3?
    public var exposure: vector_float3?
    public var exposureCompression: vector_float2?
}

public class SpectraXMLPhysicalImagingSurfaceNode: SpectraXMLNode {
    public typealias NodeType = SpectraPhysicalImagingSurfaceParams
    
    public func parse(container: Container, elem: XMLElement, options: [String: Any]) -> NodeType {
        return SpectraPhysicalImagingSurfaceParams()
    }
}

public class SpectraXMLCameraNode: SpectraXMLNode {
    public typealias NodeType = MDLCamera
    
    public func parse(container: Container, elem: XMLElement, options: [String: Any]) -> NodeType {
        let cam = MDLCamera()
        
        // TODO: the following are required.  make them optional with defaults?
        let nearVisibility = elem.attributes["near-visibility-distance"]!
        let farVisibility = elem.attributes["far-visibility-distance"]!
        let fieldOfView = elem.attributes["field-of-view"]!
        
        if let lookAt = elem.attributes["look-at"] {
            //TODO: fix the float3()
//            cam.lookAt(Float(lookAt)!, from: Float(elem.attributes["look-from"]))
        }
        
        return cam
    }
}

// TODO: public class SpectraXMLTextureNode: SpectraXMLNode {
// TODO: public class SpectraXMLTextureFilterNode: SpectraXMLNode {
// TODO: public class SpectraXMLTextureSamplerNode: SpectraXMLNode {
// TODO: public class SpectraXMLLightNode: SpectraXMLNode {
// TODO: public class SpectraXML ... etc
// TODO: public class SpectraXMLMaterialNode: SpectraXMLNode {
// TODO: public class SpectraXMLMaterialPropertyNode: SpectraXMLNode {
// TODO: public class SpectraXMLScatteringFunctionNode: SpectraXMLNode {
// TODO: public class .. voxel array?  maybe a generator
// TODO: public class .. voxel morphism (morphology in 3D)



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