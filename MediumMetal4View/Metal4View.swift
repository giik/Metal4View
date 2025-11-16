//
// ContentView.swift
//
// Created for MediumMetal4View
//     on 11/14/25
//     by GIIK Web Development

import MetalKit
import SwiftUI

struct Metal4View: NSViewRepresentable {
  // Implements drawing.
  func makeCoordinator() -> Metal4ViewCoordinator { Metal4ViewCoordinator() }

  // The wrapped MTKView.
  func makeNSView(context: Context) -> MTKView {
    let view = MTKView()
    view.delegate = context.coordinator
    view.device = context.coordinator.device
    return view
  }

  func updateNSView(_ view: MTKView, context: Context) {
    view.clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    // Calling draw explicitly not needed.
    view.needsDisplay = true
  }
}

class Metal4ViewCoordinator: NSObject, MTKViewDelegate {
  var device: MTLDevice
  var commandQueue: MTL4CommandQueue
  var commandBuffer: MTL4CommandBuffer
  var library: MTLLibrary
  var allocator: MTL4CommandAllocator
  var argTableDescriptor: MTL4ArgumentTableDescriptor
  // Because its instantiation must be deferred.
  var pipelineState: MTLRenderPipelineState!

  override init() {
    guard let d = MTLCreateSystemDefaultDevice(),
          let queue = d.makeMTL4CommandQueue(),
          let cmdBuffer = d.makeCommandBuffer(),
          let lib = d.makeDefaultLibrary(),
          let alloc = d.makeCommandAllocator()
    else {
      fatalError("unable to create metal artifacts")
    }
    self.device = d
    self.commandQueue = queue
    self.commandBuffer = cmdBuffer
    self.library = lib
    self.allocator = alloc

    let arg = MTL4ArgumentTableDescriptor()
    arg.label = "Arguments"
    arg.maxBufferBindCount = 1
    self.argTableDescriptor = arg

    super.init()
  }

  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    // Because we only want to do it on the first go.
    guard self.pipelineState == nil else { return }

    // Create pipeline state
    let vertexFunction = self.library.makeFunction(name: "vertex_f")
    let fragmentFunction = self.library.makeFunction(name: "fragment_f")
    let descriptor = MTLRenderPipelineDescriptor()
    descriptor.vertexFunction = vertexFunction
    descriptor.fragmentFunction = fragmentFunction
    // This will most likely be .bgra8Unorm
    descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
    do {
      self.pipelineState = try self.device.makeRenderPipelineState(descriptor: descriptor)
    } catch {
      fatalError(error.localizedDescription)
    }
  }

  // The general structure is beginning one or more buffers, encoding drawing
  // commands, and ending the encoding and buffers.
  // Next, the buffers are committed after calling waitForDrawable.
  // Finally, we signal the drawabble and present it.
  func draw(in view: MTKView) {
    guard let drawable = view.currentDrawable else { return }
    commandBuffer.beginCommandBuffer(allocator: allocator)
    guard let descriptor = view.currentMTL4RenderPassDescriptor,
          let encoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: descriptor)
    else {
      fatalError("unable to create encoder")
    }

    // Draw calls.
    encoder.setRenderPipelineState(pipelineState)
    encoder.drawPrimitives(primitiveType: .point, vertexStart: 0, vertexCount: 1)

    encoder.endEncoding()
    commandBuffer.endCommandBuffer()
    commandQueue.waitForDrawable(drawable)
    commandQueue.commit([commandBuffer])
    commandQueue.signalDrawable(drawable)
    drawable.present()
  }
}
