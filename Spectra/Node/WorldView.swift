//
//  WorldView.swift
//  Pods
//
//  Created by David Conner on 10/20/15.
//
//

import simd

public protocol WorldView: class {
    var uniforms: Uniformable { get set }
    // TODO: add activeCamera?
}

public class BaseWorldView: WorldView {
    public var uniforms: Uniformable
    
    public init() {
        uniforms = BaseUniforms()
    }
}

//public class WorldUniforms {
//    public var uniformScale = float4()
//    public var uniformPosition = float4()
//    public var uniformRotation = float4()
//    
//    public init() {
//        setUniformableDefaults()
//    }
//    
//    public func setUniformableDefaults() {
//        uniformScale = float4(1.0, 1.0, 1.0, 1.0)
//        uniformPosition = float4(0.0, 0.0, 1.0, 1.0)
//        uniformRotation = float4(1.0, 1.0, 1.0, 90)
//    }
//}