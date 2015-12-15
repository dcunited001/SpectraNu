//
//  MeshGenerator.swift
//  Pods
//
//  Created by David Conner on 10/3/15.
//
//

import Metal
import simd

public protocol MeshGenerator {
    //    func flattenMap(vertexMap: OrderedDictionary<Int, [Int]>) -> [Int]
    func generate(args: [String: AnyObject]) -> Mesh
    func getData(args: [String: AnyObject]) -> [String:[float4]]
    func getDataMaps(args: [String: AnyObject]) -> [String:[[Int]]]
    
//    func getVertices() -> [float4]
//    func getColorCoords() -> [float4]
//    func getTexCoords() -> [float4]
//    func getTriangleVertexMap() -> [[Int]]
//    func getFaceTriangleMap() -> [[Int]]

    init(args: [String: String])
}

extension MeshGenerator {
//    func flattenMap(vertexMap: OrderedDictionary<Int, [Int]>) -> [Int] {
//        //TODO: are maps ordered in swift?
//        return vertexMap.  .reduce([]) {  }
//    }
    
    //TODO: move to individual generators?
    public func generate(args: [String: AnyObject]) -> Mesh {
        let mesh = BaseMesh()
        mesh.data = getData(args)
        mesh.dataMaps = getDataMaps(args)
        return mesh
    }
    
}