//
//  Quad.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import simd

public class QuadGenerator: MeshGenerator {
    
    public required init(args: [String: String] = [:]) {
        
    }
    
    public func getData(args: [String: AnyObject] = [:]) -> [String:[float4]] {
        return [
            "pos": getVertices(),
            "rgba": getColorCoords(),
            "tex": getTexCoords()
        ]
    }
    
    public func getDataMaps(args: [String: AnyObject] = [:]) -> [String:[[Int]]] {
        return [
            "triangle_vertex_map": getTriangleVertexMap(),
            "face_vertex_map": getFaceVertexMap(),
            "face_triangle_map": getFaceTriangleMap()
        ]
    }
    
    public func getVertices(args: [String: AnyObject] = [:]) -> [float4] {
        return [
            float4(-1.0, -1.0, 0.0, 1.0),
            float4(-1.0,  1.0, 0.0, 1.0),
            float4( 1.0, -1.0, 0.0, 1.0),
            float4( 1.0,  1.0, 0.0, 1.0)
        ]
    }

    public func getColorCoords(args: [String: AnyObject] = [:]) -> [float4] {
        return [
            float4(1.0, 0.0, 0.0, 1.0),
            float4(0.0, 1.0, 0.0, 1.0),
            float4(0.0, 0.0, 1.0, 1.0),
            float4(1.0, 1.0, 0.0, 1.0)
        ]
    }
    
    public func getTexCoords(args: [String: AnyObject] = [:]) -> [float4] {
        return [
            float4(0.0, 0.0, 0.0, 0.0),
            float4(0.0, 1.0, 0.0, 0.0),
            float4(1.0, 0.0, 0.0, 0.0),
            float4(1.0, 1.0, 0.0, 0.0)
        ]
    }
    
    public func getTriangleVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
        return [
            [0,1,3],
            [3,2,0]
        ]
    }
    
    public func getFaceVertexMap(args: [String: AnyObject] = [:]) -> [[Int]] {
        return [[0,1,2,3]]
    }
    
    public func getFaceTriangleMap(args: [String: AnyObject] = [:]) -> [[Int]] {
        return [[0,1]]
    }
}
