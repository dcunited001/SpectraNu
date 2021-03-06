//
//  MetalNodeSpec.swift
//  Spectra
//
//  Created by David Conner on 10/17/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

@testable import Spectra
import Foundation
import Quick
import Nimble
import Swinject

//TODO: fix filepath must not be nil error
//let library = device!.newDefaultLibrary()

class MetalNodeSpec: QuickSpec {
    override func spec() {
        
        let device = MTLCreateSystemDefaultDevice()
        let library = device!.newDefaultLibrary()
        let testBundle = NSBundle(forClass: MetalNodeSpec.self)
        let xml = MetalParser.readXML(testBundle, filename: "S3DXMLTest", bundleResourceName: nil)!

        let metadataContainer = MetalParser.initMetalEnums(Container())
        let metalParser = MetalParser(parentContainer: metadataContainer)
        metalParser.parseXML(xml)
        
        let metalContainer = Container()
        MetalParser.initMetal(metalContainer)
        
        describe("MetalParser") {
            it("reads the Metal Enums from the XSD File") {
                
            }
        }
        
        describe("MetalNode") {
            
            describe("resolveMtlDevice") {
                let vert = metalParser.getVertexFunction("basic_color_vertex")
                let nodes = metalParser.nodes
                
                // monads, monads, monads
                // - oooh i want a thing like that ... but i only have this =[
                //   ... how do i get that kind of thing?
            
                it("resolves given metal container only by creating new default device object") {
                    let inj: [String: Container] = [:]
                    let ops: [String: Any] = [:]
                    let dev = vert.resolveMtlDevice(inj, options: ops)
                    expect(dev) is MTLDevice
                }
                
                it("resolves given metal container and device_id") {
                    let inj: [String: Container] = ["metal": metalContainer]
                    let ops: [String: Any] = ["device_container": "metal",
                                              "device_id": "default"]
                    let dev = vert.resolveMtlDevice(inj, options: ops)
                    expect(dev) is MTLDevice
                }
                
                it("resolves given 'device' in options") {
                    let inj: [String: Container] = [:]
                    let ops: [String: Any] = ["device": device]
                    let dev = vert.resolveMtlDevice(inj, options: ops)
                    expect(dev) is MTLDevice
                }
            }
            
            // TODO: create LibraryNode and move to generate()?
            describe("resolveMtlLibrary") {
                let vert = metalParser.getVertexFunction("basic_color_vertex")
                let nodes = metalParser.nodes
                
                it("resolves given no args by creating new default device object") {
                    let inj: [String: Container] = [:]
                    let ops: [String: Any] = [:]
                    let lib = vert.resolveMtlLibrary(inj, options: ops)
                    expect(lib) is MTLLibrary
                }
                
                it("resolves given a metal container and 'library_id'") {
                    let inj: [String: Container] = ["metal": metalContainer]
                    let ops: [String: Any] = ["library_container": "metal",
                                              "library_id": "default"]
                    let lib = vert.resolveMtlLibrary(inj, options: ops)
                    expect(lib) is MTLLibrary
                }
                
                it("resolves from the nodes container when it can't find 'library_id' in metal container") {
                    let inj: [String: Container] = ["metal": nodes]
                    let ops: [String: Any] = ["library_container": "metal"]
                    let lib = vert.resolveMtlLibrary(inj, options: ops)
                    expect(lib) is MTLLibrary
                }
                
                it("resolves given 'library' in options") {
                    let inj: [String: Container] = ["metal": nodes]
                    let ops: [String: Any] = ["library_container": "metal"]
                    let lib = vert.resolveMtlLibrary(inj, options: ops)
                    expect(lib) is MTLLibrary
                    // TODO: need to compare lib vs library (but labels are not set)
                }
            }
        }
        
//        describe("LibraryNode") {
//            it("parses given a *.metallib file name")
//            it("parses given the location of *.metallib file data")
//            it("parses given the location of a *.metal source string")
//            it("parses given the location of *.metal source data")
        // TODO: also test generation of each method
//        }

        describe("FunctionNode") {
            let vertName = "basic_color_vertex"
            let fragName = "basic_color_fragment"
            let compName = "test_compute_function"
            let vert = metalParser.getVertexFunction(vertName)
            let frag = metalParser.getFragmentFunction(fragName)
            let comp = metalParser.getComputeFunction("test_compute_function")
            
            it("can parse render and compute functions") {
                expect(vert.name) == vertName
                expect(frag.name) == fragName
                expect(comp.name) == compName
            }
            
            // it("generates functions")
            it("generates a MTLFunction with various injected options") {
                // can specify the combination of a "metal" container & "device_id"
                let nodes = metalParser.nodes
                let inj: [String: Container] = ["metal": nodes]
                let ops: [String: Any] = [:]
                let fnVert = vert.generate(inj, options: ops)
                expect(fnVert.name) == vertName
                
                // can specify the combination of a "library" container and ...
                let inj2: [String: Container] = [:]
                let ops2: [String: Any] = ["device": device]
                let fnVert2 = vert.generate(inj2, options: ops2)
                expect(fnVert2.name == vertName)
            }
        }

        describe("VertexDescriptorNode") {
            it("can parse the attribute descriptor array") {
                let vertDesc = metalParser.getVertexDescriptor("common_vertex_desc")
                expect(vertDesc.attributes[0].format) == MTLVertexFormat.Float4
                expect(vertDesc.attributes[1].offset) == 16
            }
            
            it("can parse the buffer layout descriptor array") {
                let vertDesc = metalParser.getVertexDescriptor("common_vertex_desc")
                expect(vertDesc.layouts[0].stepFunction) == MTLVertexStepFunction.PerVertex
                expect(vertDesc.layouts[0].stride) == 48
                expect(vertDesc.layouts[0].stepRate) == 1
            }
            
//            it("can parse from references") {
//                let vertDesc = metalParser.vertexDescriptors["common_vertex_desc"]!
//            }
            
            // it("generates vertex descriptors")
        }
        
        // TODO: MTLVertexAttributeDescriptor
        // TODO: MTLVertexBufferLayoutDescriptor
        
        describe("TextureDescriptorNode") {
            it("can parse a MTLVertexDescriptor") {
                let resourceOpts: MTLResourceOptions = [.CPUCacheModeDefaultCache, .CPUCacheModeWriteCombined]
                let textureUsage: MTLTextureUsage = [.ShaderRead, .ShaderWrite, .PixelFormatView]
                let desc = metalParser.getTextureDescriptor("texture_desc")
                expect(desc.textureType) == MTLTextureType.Type3D
                expect(desc.pixelFormat) == MTLPixelFormat.RGBA32Float
                expect(desc.width) == 100
                expect(desc.height) == 100
                expect(desc.depth) == 100
                expect(desc.mipmapLevelCount) == 100
                expect(desc.sampleCount) == 100
                expect(desc.arrayLength) == 100
                expect(desc.resourceOptions) == resourceOpts
                expect(desc.cpuCacheMode) == MTLCPUCacheMode.WriteCombined
                expect(desc.storageMode) == MTLStorageMode.Shared
                expect(desc.usage) == textureUsage
            }
            
//            it("can parse from references") {
//                
//            }
            
            // it("generates a texture descriptor")
        }

        describe("SamplerDescriptorNode") {
            it("can parse a sampler descriptor") {
                let desc = metalParser.getSamplerDescriptor("sampler_desc")
                expect(desc.minFilter) == MTLSamplerMinMagFilter.Linear
                expect(desc.magFilter) == MTLSamplerMinMagFilter.Linear
                expect(desc.mipFilter) == MTLSamplerMipFilter.Linear
                expect(desc.maxAnisotropy) == 10
                expect(desc.sAddressMode) == MTLSamplerAddressMode.Repeat
                expect(desc.tAddressMode) == MTLSamplerAddressMode.MirrorRepeat
                expect(desc.rAddressMode) == MTLSamplerAddressMode.ClampToZero
                expect(desc.normalizedCoordinates) == false
                expect(desc.lodMinClamp) == 1.0
                expect(desc.lodMaxClamp) == 10.0
                #if os(iOS)
                expect(desc.lodAverage) == true
                #endif
                expect(desc.compareFunction) == MTLCompareFunction.Always
            }
            
            // it("generates a sampler descriptor")
        }
        
        describe("StencilDescriptorNode") {
            it("can parse a stencil descriptor") {
                let desc = metalParser.getStencilDescriptor("stencil_desc")
                expect(desc.stencilCompareFunction) == MTLCompareFunction.Never
                expect(desc.stencilFailureOperation) == MTLStencilOperation.Replace
                expect(desc.depthFailureOperation) == MTLStencilOperation.IncrementWrap
                expect(desc.depthStencilPassOperation) == MTLStencilOperation.DecrementWrap
                expect(desc.readMask) == 7
                expect(desc.writeMask) == 7
            }
            
            // it("generates a stencil descriptor")
        }

        describe("DepthStencilDescriptorNode") {
            let desc = metalParser.getDepthStencilDescriptor("depth_stencil_desc")
            
            it("can parse a depth stencil descriptor") {
                expect(desc.depthCompareFunction) == MTLCompareFunction.Never
                expect(desc.depthWriteEnabled) == true
                expect(desc.frontFaceStencil!.stencilCompareFunction) == metalParser.getStencilDescriptor("stencil_desc").stencilCompareFunction
                expect(desc.frontFaceStencil!.depthStencilPassOperation) == metalParser.getStencilDescriptor("stencil_desc").depthStencilPassOperation
                expect(desc.backFaceStencil!.stencilCompareFunction) == metalParser.getStencilDescriptor("stencil_desc").stencilCompareFunction
                expect(desc.backFaceStencil!.depthStencilPassOperation) == metalParser.getStencilDescriptor("stencil_desc").depthStencilPassOperation
            }
            
            it("generates a depth stencil descriptor") {
//                let leftStencilOptions = [:]
//                let rightStencilOptions = [:]
//                let inj = SpectraInjected(inj: ["metal": metalContainer, "nodes": nodes],
//                                          options: [
//                                            "left_stencil_desc": leftStencilOptions,
//                                            "right_stencil_desc": rightStencilOptions])
                
                
            }
        }
        
        describe("RenderPipelineColorAttachmentDescriptorNode") {
            it("can parse a render pipeline color attachment descriptor") {
                let desc = metalParser.getRenderPipelineColorAttachmentDescriptor("color_attach_desc")
                expect(desc.blendingEnabled) == true
                expect(desc.sourceRGBBlendFactor) == MTLBlendFactor.Zero
                expect(desc.destinationRGBBlendFactor) == MTLBlendFactor.SourceColor
                expect(desc.rgbBlendOperation) == MTLBlendOperation.Subtract
                expect(desc.sourceAlphaBlendFactor) == MTLBlendFactor.BlendAlpha
                expect(desc.destinationAlphaBlendFactor) == MTLBlendFactor.OneMinusBlendAlpha
                expect(desc.alphaBlendOperation) == MTLBlendOperation.Max
                expect(desc.pixelFormat) == MTLPixelFormat.BGRA8Unorm
            }
        }
        
        describe("RenderPipelineDescriptorNode") {
            it("can parse a render pipeline descriptor") {
                let desc = metalParser.getRenderPipelineDescriptor("render_pipeline_desc")
                expect(desc.label) == "render-pipeline-descriptor"
                expect(desc.sampleCount) == 2
                expect(desc.alphaToCoverageEnabled) == true
                expect(desc.alphaToOneEnabled) == true
                expect(desc.rasterizationEnabled) == false
                expect(desc.depthAttachmentPixelFormat) == MTLPixelFormat.Depth32Float
                expect(desc.stencilAttachmentPixelFormat) == MTLPixelFormat.Stencil8
                expect(desc.vertexFunction!.name) == "basic_color_vertex"
                expect(desc.fragmentFunction!.name) == "basic_color_fragment"
                expect(desc.vertexDescriptor!.attributes.count) == 4
                expect(desc.colorAttachmentDescriptors[0].sourceRGBBlendFactor) == .Zero
                expect(desc.colorAttachmentDescriptors[0].rgbBlendOperation) == .Subtract
            }
        }
        
        describe("ComputePipelineDescribeNode") {
            it("can parse a compute pipeline descriptor") {
                let desc = metalParser.getComputePipelineDescriptor("compute_pipeline_desc")
                expect(desc.label) == "compute-pipeline-descriptor"
                expect(desc.threadGroupSizeIsMultipleOfThreadExecutionWidth) == true
                expect(desc.computeFunction!.name) == "test_compute_function"
            }
        }
        
        describe("ClearColorNode") {
            it("can parse a clear color") {
                let color = metalParser.getClearColor("clear_color_black")
                expect(color.red) == 0.0
                expect(color.green) == 0.0
                expect(color.blue) == 0.0
                expect(color.alpha) == 1.0
            }
        }
        
        describe("RenderPassColorAttachmentDescriptorNode") {
            it("can parse a render pass color attachment descriptor") {
                let desc = metalParser.getRenderPassColorAttachmentDescriptor("rpass_color_attach_desc")
                let clearColor = metalParser.getClearColor("clear_color_black")
                
                expect(desc.level) == 1
                expect(desc.slice) == 1
                expect(desc.depthPlane) == 1
                expect(desc.resolveLevel) == 1
                expect(desc.resolveSlice) == 1
                expect(desc.resolveDepthPlane) == 1
                expect(desc.loadAction) == MTLLoadAction.Load
                expect(desc.storeAction) == MTLStoreAction.Store
                expect(desc.clearColor!.red) == clearColor.red
                expect(desc.clearColor!.alpha) == clearColor.alpha
            }
        }
        
        describe("RenderPassDepthAttachmentDescriptorNode") {
            it("can parse a render pass depth attachment descriptor") {
                let desc = metalParser.getRenderPassDepthAttachmentDescriptor("rpass_depth_attach_desc")
                expect(desc.level) == 1
                expect(desc.slice) == 1
                expect(desc.depthPlane) == 1
                expect(desc.resolveLevel) == 1
                expect(desc.resolveSlice) == 1
                expect(desc.resolveDepthPlane) == 1
                expect(desc.loadAction) == MTLLoadAction.Load
                expect(desc.storeAction) == MTLStoreAction.Store
                expect(desc.clearDepth) == 2.0
//                TODO: MTLMultisampleDepthResolveFilter not available in iOS
//                expect(desc.depthResolveFilter) == MTLMultisampleDepthResolveFilter.Min
            }
        }
        
        describe("RenderPassStencilAttachmentDescriptorNode") {
            it("can parse a render pass stencil attachment descriptor") {
                let desc = metalParser.getRenderPassStencilAttachmentDescriptor("rpass_stencil_attach_desc")
                expect(desc.level) == 1
                expect(desc.slice) == 1
                expect(desc.depthPlane) == 1
                expect(desc.resolveLevel) == 1
                expect(desc.resolveSlice) == 1
                expect(desc.resolveDepthPlane) == 1
                expect(desc.loadAction) == MTLLoadAction.Load
                expect(desc.storeAction) == MTLStoreAction.Store
                expect(desc.clearStencil) == 0
            }
        }
        
        describe("RenderPassDescriptorNode") {
            it("can parse a render pass descriptor") {
                let desc = metalParser.getRenderPassDescriptor("render_pass_desc")
                let colorAttach = metalParser.getRenderPassColorAttachmentDescriptor("rpass_color_attach_desc")
                let depthAttach = metalParser.getRenderPassDepthAttachmentDescriptor("rpass_depth_attach_desc")
                let stencilAttach = metalParser.getRenderPassStencilAttachmentDescriptor("rpass_stencil_attach_desc")
                
                expect(desc.colorAttachments[0].level) == colorAttach.level
                expect(desc.colorAttachments[0].clearColor) == colorAttach.clearColor
                expect(desc.depthAttachment!.level) == depthAttach.level
                expect(desc.depthAttachment!.clearDepth) == depthAttach.clearDepth
                expect(desc.stencilAttachment!.level) == stencilAttach.level
                expect(desc.stencilAttachment!.clearStencil) == stencilAttach.clearStencil
            }
        }
    }
}