//
//  ModelIOTextureGenerators.swift
//  
//
//  Created by David Conner on 3/8/16.
//
//

import Foundation
import Swinject
import ModelIO

public class ModelIOTextureGenerators {
    public static func loadTextureGenerators(container: Container) {
        container.register(TextureGenerator.self, name: "resource_texture_gen") { _ in
            return ResourceTextureGen(container: container)
        }.inObjectScope(.None)
        container.register(TextureGenerator.self, name: "url_texture_gen") { _ in
            return URLTextureGen(container: container)
        }.inObjectScope(.None)
        container.register(TextureGenerator.self, name: "noise_texture_gen") { _ in
            return NoiseTextureGen(container: container)
        }.inObjectScope(.None)
//        container.register(TextureGenerator.self, name: "checkerboard_texture_gen") { _ in
//            return CheckerboardTextGen(container: container)
//        }
        // TODO: DataTextureGen
        // TODO: MDLColorSwatchTexture
        // TODO: MDLNormalMapTexture
        // TODO: MDLSkyCubeTexture
    }
}

//public class DataTextureGen: TextureGenerator {
// TODO: implement a texture generator sourcing NSData
//    init(data pixelData: NSData?,
//    topLeftOrigin topLeftOrigin: Bool,
//    name name: String?,
//    dimensions dimensions: vector_int2,
//    rowStride rowStride: Int,
//    channelCount channelCount: Int,
//    channelEncoding channelEncoding: MDLTextureChannelEncoding,
//    isCube isCube: Bool)
//}

public class ResourceTextureGen: TextureGenerator {
    public var resource: String = "defaultTexture.jpg"
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        processArgs(container, args: args)
    }
    
    public func processArgs(container: Container, args: [String: GeneratorArg] = [:]) {
        if let resource = args["resource"] {
            self.resource = resource.value
        }
    }
    
    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLTexture {
        
        var _resource = self.resource
        
        if let resource = args["resource"] {
            _resource = resource.value
        }
        
        return MDLTexture(named: _resource)!
    }
    
    public func copy(container: Container) -> TextureGenerator {
        let cp = ResourceTextureGen(container: container)
        cp.resource = self.resource
        return cp
    }
}

public class URLTextureGen: TextureGenerator {
// NOTE: how do i set these?  are these determined by the image file?
//    public var dimensions: int2 = int2(100,100)
//    public var name: String?
//    public var channelCount: Int32 = 4
//    public var channelEncoding = MDLTextureChannelEncoding.UInt8
    public var url: NSURL?
    public var name: String?
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        processArgs(container, args: args)
    }
    
    public func processArgs(container: Container, args: [String: GeneratorArg] = [:]) {
        if let urlString = args["url"] {
            self.url = NSURL(fileURLWithPath: urlString.value)
        }
        if let name = args["name"] {
            self.name = name.value
        }
    }
    
    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLTexture {
        var _url: NSURL? = self.url
        var _name: String? = self.name
        
        if let urlString = args["url"] {
            _url = NSURL(fileURLWithPath: urlString.value)
        }
        if let name = args["name"] {
            _name = name.value
        }
        
        return MDLURLTexture(URL: _url!, name: _name)
    }
    
    public func copy(container: Container) -> TextureGenerator {
        let cp = URLTextureGen(container: container)
        
        cp.url = self.url
        cp.name = self.name
        
        return cp
    }
}

public enum NoiseTextureGenType: String {
    case Vector = "Vector"
    case Scalar = "Scalar"
}

public class NoiseTextureGen: NoiseTextureGen {
    public var dimensions: int2 = int2(100,100)
    public var name: String?
    public var channelCount: Int32 = 4
    public var channelEncoding = MDLTextureChannelEncoding.UInt8
    
    public var type = NoiseTextureGenType.Vector
    public var smoothness: Float = 0.80
    public var grayscale: Bool = false
    
    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
        
        //=================================================
        // the Container arg below prevents the source from ever completely indexing
        //   or ever completely compiling (no errors it just sucks CPU 
        //   and NEVER FINISHES)
        //=================================================
        
        processArgs(container: Container, args: args)
    }
    
    public func processArgs(container: Container, args: [String: GeneratorArg] = [:]) {
        if let name = args["name"] {
            self.name = name
        }
        if let dimensions = args["dimensions"] {
            self.dimensions = SpectraSimd.parseInt2(dimensions.value)
        }
        if let channelCount = args["channel_count"] {
            self.channelCount = Int32(channelCount.value)
        }
        if let channelEncoding = args["channel_encoding"] {
            let enumVal = container.resolve(SpectraEnum.self, name: "mdlTextureChannelEncoding")!.getValue(channelEncoding.value)
            self.channelEncoding = MDLTextureChannelEncoding(rawValue: enumVal)
        }
        if let type = args["type"] {
            self.type = NoiseTextureGenType(rawValue: type.value)
        }
        if let smoothness = args["smoothness"] {
            self.smoothness = Float(smoothness.value)
        }
        if let grayscale = args["grayscale"] {
            let valAsBool = NSString(string: grayscale.value).boolValue
            self.grayscale = valAsBool
        }
    }
    
    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLTexture {
        if self.type == .Vector {
            return MDLNoiseTexture(self.smoothness,
                                   name: self.name,
                                   textureDimensions: self.dimensions,
                                   channelEncoding: self.channelEncoding)
        } else {
            return MDLNoiseTexture(self.smoothness,
                                   name: self.name,
                                   textureDimensions: self.dimensions,
                                   channelCount: self.channelCount,
                                   channelEncoding: self.channelEncoding,
                                   grayscale: self.grayscale)
        }
    }
    
    public func copy(container: Container) -> TextureGenerator {
        let cp = NoiseTextureGen(container: container)
        
        cp.dimensions = self.dimensions
        cp.name = self.name
        cp.channelCount = self.channelCount
        cp.channelEncoding = self.channelEncoding
        
        cp.type = self.type
        cp.smoothness = self.smoothness
        cp.grayscale = self.grayscale
        
        return cp
    }
}

//public class CheckerboardTextureGen: TextureGenerator {
//    public var dimensions: int2 = int2(100,100)
//    public var name: String?
//    public var channelCount: Int32 = 4
//    public var channelEncoding = MDLTextureChannelEncoding.UInt8
//    
//    public var divisions: Float = 8
//    public var color1: CGColor = CGColorCreateRGB(0,0,0.0,1.0)
//    public var color2: CGColor = CGColorCreateRGB(0.875,0.875,0.875,1.0)
//    
//    public required init(container: Container, args: [String: GeneratorArg] = [:]) {
//        processArgs(container: container, args: args)
//    }
//    
//    public func processArgs(container: Container, args: [String: GeneratorArg] = [:]) {
//        if let divisions = args["divisions"] {
//            self.divisions = Float(divisions.value)
//        }
//        if let color1 = args["color1"] {
//            let intColor = SpectraSimd.parseInt4(color1.value)
//            self.color1 = FGColorCreateRGB(intColor[0]/255.0, intColor[1]/255.0, intColor[2]/255.0, intColor[3]/255.0)
//        }
//        if let color2 = args["color2"] {
//            let intColor = SpectraSimd.parseInt4(color1.value)
//            self.color2 = FGColorCreateRGB(intColor[0]/255.0, intColor[1]/255.0, intColor[2]/255.0, intColor[3]/255.0)
//        }
//        if let name = args["name"] {
//            self.name = name
//        }
//        if let dimensions = args["dimensions"] {
//            self.dimensions = SpectraSimd.parseInt2(dimensions.value)
//        }
//        if let channelCount = args["channel_count"] {
//            self.channelCount = Int32(channelCount)
//        }
//        if let channelEncoding = args["channel_encoding"] {
//            let enumVal = container.resolve(SpectraEnum.self, name: "mdlTextureChannelEncoding")!.getValue(channelEncoding.value)
//            self.channelEncoding = MDLTextureChannelEncoding(rawValue: enumVal)
//        }
//    }
//    
//    public func generate(container: Container, args: [String: GeneratorArg] = [:]) -> MDLTexture {
//        return MDLCheckerboardTexture(divisions: self.division,
//            name: self.name,
//            dimensions: self.dimensions,
//            channelCount: self.channelCount,
//            channelEncoding: self.channelEncoding,
//            color1: self.color1,
//            color2: self.color2)
//    }
//    
//    public func copy(container: Container) -> TextureGenerator {
//        let cp = CheckerboardTextureGen(container: container)
//        
//        cp.dimensions = self.dimensions
//        cp.name = self.name
//        cp.channelCount = self.channelCount
//        cp.channelEncoding = self.channelEncoding
//        
//        cp.divisions = self.divisions
//        cp.color1 = self.color1
//        cp.color2 = self.color2
//        
//        return cp
//    }
//}