//
//  Spectra.swift
//  
//
//  Created by David Conner on 11/28/15.
//
//

import Foundation
import simd

public class Spectra {
    
}

public class SpectraSimd {
    
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
    
    public static func compareFloat2(a: float2, with b: float2) -> Bool {
        return (a.x == b.x) && (a.y == b.y)
    }
    
    public static func compareFloat3(a: float3, with b: float3) -> Bool {
        return ((a.x == b.x) && (a.y == b.y) && (a.z == b.z))
    }
    
    public static func compareFloat4(a: float4, with b: float4) -> Bool {
        return (a.x == b.x) && (a.y == b.y) && (a.z == b.z) && (a.w == b.w)
    }
    
    public static func compareInt2(a: int2, with b: int2) -> Bool {
        return (a.x == b.x) && (a.y == b.y)
    }
    
    public static func compareInt3(a: int3, with b: int3) -> Bool {
        return ((a.x == b.x) && (a.y == b.y) && (a.z == b.z))
    }
    
    public static func compareInt4(a: int4, with b: int4) -> Bool {
        return (a.x == b.x) && (a.y == b.y) && (a.z == b.z) && (a.w == b.w)
    }
}

