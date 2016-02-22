//
//  MeshGenerator.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import Metal
import ModelIO
import simd

public protocol MeshGenerator {
    //    func flattenMap(vertexMap: OrderedDictionary<Int, [Int]>) -> [Int]
    func generate(args: [String: AnyObject]) -> MDLMesh
    
//    func getVertices() -> [float4]
//    func getColorCoords() -> [float4]
//    func getTexCoords() -> [float4]
//    func getTriangleVertexMap() -> [[Int]]
//    func getFaceTriangleMap() -> [[Int]]

    init(args: [String: String])
}
