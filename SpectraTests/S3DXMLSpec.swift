//
//  S3DXMLSpec.swift
//  Spectra
//
//  Created by David Conner on 10/17/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

@testable import Spectra
import Foundation
import Quick
import Nimble

//TODO: fix filepath must not be nil error
//let library = device!.newDefaultLibrary()

class S3DXMLSpec: QuickSpec {
    override func spec() {
        
        let device = MTLCreateSystemDefaultDevice()
        let library = device!.newDefaultLibrary()
        let testBundle = NSBundle(forClass: S3DXMLSpec.self)
        let xmlData: NSData = S3DXML.readXML(testBundle, filename: "S3DXMLTest")
        let s3d = S3DXML(data: xmlData)
        
        var descMan = DescriptorManager(library: library!)
        descMan.parseS3DXML(s3d)
        
        describe("DescriptorManager") {
            it("parses enumGroups from XSD") {
                expect(descMan.getMtlEnum("mtlSamplerAddressMode", id: "ClampToEdge") == 0)
            }
        }
        
//        describe("S3DXML") {
//            
//        }

        describe("S3DXMLMTLFunctionNode") {
            let vertName = "basic_color_vertex"
            let fragName = "basic_color_fragment"
            let compName = "test_compute_function"
            
            it("can parse render and compute functions") {
                let vert = descMan.getVertexFunction(vertName)
                expect(vert.name) == vertName
                let frag = descMan.getFragmentFunction(fragName)
                expect(frag.name) == fragName
                let comp = descMan.getComputeFunction("test_compute_function")
                expect(comp.name) == compName
            }
            
//            it("can parse from references") {
//                
//            }
        }

        describe("S3DXMLMTLVertexDescriptorNode") {
            it("can parse the attribute descriptor array") {
                let vertDesc = descMan.getVertexDescriptor("common_vertex_desc")
                expect(vertDesc.attributes[0].format) == MTLVertexFormat.Float4
                expect(vertDesc.attributes[1].offset) == 16
            }
            
            it("can parse the buffer layout descriptor array") {
                let vertDesc = descMan.getVertexDescriptor("common_vertex_desc")
                expect(vertDesc.layouts[0].stepFunction) == MTLVertexStepFunction.PerVertex
                expect(vertDesc.layouts[0].stride) == 48
                expect(vertDesc.layouts[0].stepRate) == 1
            }
            
//            it("can parse from references") {
//                let vertDesc = descMan.vertexDescriptors["common_vertex_desc"]!
//            }
        }
        
        describe("S3DXMLMTLTextureDescriptorNode") {
            it("can parse a MTLVertexDescriptor") {
                let desc = descMan.getTextureDescriptor("texture_desc")
                expect(desc.textureType) == MTLTextureType.Type3D
                expect(desc.pixelFormat) == MTLPixelFormat.RGBA32Float
                expect(desc.width) == 100
                expect(desc.height) == 100
                expect(desc.depth) == 100
                expect(desc.mipmapLevelCount) == 100
                expect(desc.sampleCount) == 100
                expect(desc.arrayLength) == 100
                // desc.resourceOptions
                expect(desc.cpuCacheMode) == MTLCPUCacheMode.WriteCombined
                expect(desc.storageMode) == MTLStorageMode.Shared
//                expect(desc.usage) == MTLTextureUsage.PixelFormatView
            }
            
//            it("can parse from references") {
//                
//            }
        }
        
        describe("S3DXMLMTLSamplerDescriptorNode") {
            it("can parse a sampler descriptor") {
                let desc = descMan.getSamplerDescriptor("sampler_desc")
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
//                TODO: fix lodAverage (unavailable on OSX)
//                expect(desc.lodAverage) == true
                expect(desc.compareFunction) == MTLCompareFunction.Always
            }
        }
        
        describe("S3DXMLMTLStencilDescriptorNode") {
            it("can parse a stencil descriptor") {
                let desc = descMan.getStencilDescriptor("stencil_desc")
                expect(desc.stencilCompareFunction) == MTLCompareFunction.Never
                expect(desc.stencilFailureOperation) == MTLStencilOperation.Replace
                expect(desc.depthFailureOperation) == MTLStencilOperation.IncrementWrap
                expect(desc.depthStencilPassOperation) == MTLStencilOperation.DecrementWrap
            }
        }
        
        describe("S3DXMLMTLDepthStencilDescriptorNode") {
            it("can parse a depth stencil descriptor") {
                let desc = descMan.getDepthStencilDescriptor("depth_stencil_desc")
                expect(desc.depthCompareFunction) == MTLCompareFunction.Never
                expect(desc.depthWriteEnabled) == true
                expect(desc.frontFaceStencil) == descMan.getStencilDescriptor("stencil_desc")
                expect(desc.backFaceStencil) == descMan.getStencilDescriptor("stencil_desc")
            }
        }
        
        describe("S3DXMLMTLRenderPipelineColorAttachmentDescriptorNode") {
            it("can parse a render pipeline color attachment descriptor") {
                let desc = descMan.getColorAttachmentDescriptor("color_attach_desc")
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
        
        describe("S3DXMLMTLRenderPipelineDescriptorNode") {
            it("can parse a render pipeline descriptor") {
                let desc = descMan.getRenderPipelineDescriptor("render_pipeline_desc")
                expect(desc.label) == "render-pipeline-descriptor"
                expect(desc.sampleCount) == 2
                expect(desc.alphaToCoverageEnabled) == true
                expect(desc.alphaToOneEnabled) == true
                expect(desc.rasterizationEnabled) == true
                expect(desc.depthAttachmentPixelFormat) == MTLPixelFormat.Depth32Float
                expect(desc.stencilAttachmentPixelFormat) == MTLPixelFormat.Stencil8
                expect(desc.vertexFunction!.name) == "basic_color_vertex"
                expect(desc.fragmentFunction!.name) == "basic_color_fragment"
                expect(desc.vertexDescriptor) == descMan.getVertexDescriptor("common_vertex_desc")
                expect(desc.colorAttachments[0]) == descMan.getColorAttachmentDescriptor("color_attach_desc")
            }
        }
        
        describe("S3DXMLMTLComputePipelineDescribeNode") {
            it("can parse a compute pipeline descriptor") {
                let desc = descMan.getComputePipelineDescriptor("compute_pipeline_desc")
                expect(desc.label) == "compute-pipeline-descriptor"
                expect(desc.threadGroupSizeIsMultipleOfThreadExecutionWidth) == true
                expect(desc.computeFunction!.name) == "test_compute_function"
            }
        }
        
        describe("S3DXMLMTLClearColorNode") {
            it("can parse a clear color") {
                let color = descMan.getClearColor("clear_color_black")
                expect(color.red) == 0.0
                expect(color.green) == 0.0
                expect(color.blue) == 0.0
                expect(color.alpha) == 1.0
            }
        }
        
        describe("S3DXMLMTLRenderPassColorAttachmentDescriptorNode") {
            it("can parse a render pass color attachment descriptor") {
                let desc = descMan.getRenderPassColorAttachmentDescriptor("rpass_color_attach_desc")
                let clearColor = descMan.getClearColor("clear_color_black")
                
                expect(desc.level) == 1
                expect(desc.slice) == 1
                expect(desc.depthPlane) == 1
                expect(desc.resolveLevel) == 1
                expect(desc.resolveSlice) == 1
                expect(desc.resolveDepthPlane) == 1
                expect(desc.loadAction) == MTLLoadAction.Load
                expect(desc.storeAction) == MTLStoreAction.Store
                expect(desc.clearColor.red) == clearColor.red
                expect(desc.clearColor.alpha) == clearColor.alpha
            }
        }
        
        describe("S3DXMLMTLRenderPassDepthAttachmentDescriptorNode") {
            it("can parse a render pass depth attachment descriptor") {
                let desc = descMan.getRenderPassDepthAttachmentDescriptor("rpass_depth_attach_desc")
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
        
        describe("S3DXMLMTLRenderPassStencilAttachmentDescriptorNode") {
            it("can parse a render pass stencil attachment descriptor") {
                let desc = descMan.getRenderPassStencilAttachmentDescriptor("rpass_stencil_attach_desc")
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
        
        describe("S3DXMLMTLRenderPassDescriptorNode") {
            it("can parse a render pass descriptor") {
                let desc = descMan.getRenderPassDescriptor("render_pass_desc")
                let colorAttach = descMan.getRenderPassColorAttachmentDescriptor("rpass_color_attach_desc")
                let depthAttach = descMan.getRenderPassDepthAttachmentDescriptor("rpass_depth_attach_desc")
                let stencilAttach = descMan.getRenderPassStencilAttachmentDescriptor("rpass_stencil_attach_desc")
                
                expect(desc.colorAttachments[0]) == colorAttach
                expect(desc.depthAttachment) == depthAttach
                expect(desc.stencilAttachment) == stencilAttach
            }
        }
        
    }
}