//
//  TriangularQuadTesselationGenerator.swift
//  Pods
//
//  Created by David Conner on 10/22/15.
//
//

import Foundation
import simd

public class TriangularQuadTesselationGenerator: MeshGenerator {
    
    var rowCount: Int = 10
    var colCount: Int = 10
    
    public required init(args: [String: String] = [:]) {
        if let rCount = args["rowCount"] {
            rowCount = Int(rCount)!
        }
        if let cCount = args["colCount"] {
            colCount = Int(cCount)!
        }
    }
    
    public func getData(args: [String: AnyObject] = [:]) -> [String:[float4]] {
        return [
            "pos": getVertices(args),
            "rgba": getColorCoords(args),
            "tex": getTexCoords(args)
        ]
    }
    
    public func getDataMaps(args: [String: AnyObject] = [:]) -> [String:[[Int]]] {
        return [
            "triangle_vertex_map": getTriangleVertexMap(args),
            "face_vertex_map": getFaceTriangleMap(args)
        ]
    }
    
    public func getVertices(args: [String: AnyObject] = [:]) -> [float4] {
        return []
    }
    public func getColorCoords(args: [String: AnyObject] = [:]) -> [float4] {
        return []
    }
    public func getTexCoords(args: [String: AnyObject] = [:]) -> [float4] {
        return []
    }
    public func getTriangleVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
        return []
    }
    public func getFaceTriangleMap(args: [String: AnyObject] = [:]) -> [[Int]] {
        return []
    }
}