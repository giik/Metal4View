//
// ContentView.swift
//
// Created for MediumMetal4View
//     on 11/14/25
//     by GIIK Web Development

import MetalKit
import SwiftUI

struct Metal4View: NSViewRepresentable {
  // Needed to resolve the color value (will be set by parent).
  @Environment(\.self) var environment
  var color: Color

  // Implements drawing.
  func makeCoordinator() -> Metal4ViewCoordinator { Metal4ViewCoordinator() }

  // The wrapped MTKView.
  func makeNSView(context: Context) -> MTKView {
    let view = MTKView()
    view.delegate = context.coordinator
    view.device = context.coordinator.device
    return view
  }

  // Called by SwiftUI when the view needs an update, incl. because the value
  // of the bound environment changed. Gives us a chance to signal that drawing
  // is needed.
  func updateNSView(_ view: MTKView, context: Context) {
    let resolved = self.color.resolve(in: self.environment)
    view.clearColor = MTLClearColor(
      red: Double(resolved.red),
      green: Double(resolved.green),
      blue: Double(resolved.blue),
      alpha: Double(resolved.opacity)
    )
    // Calling draw explicitly not needed.
    view.needsDisplay = true
  }
}

class Metal4ViewCoordinator: NSObject, MTKViewDelegate {
  var device: MTLDevice
  var commandQueue: MTL4CommandQueue
  var commandBuffer: MTL4CommandBuffer
  var allocator: MTL4CommandAllocator

  override init() {
    guard let d = MTLCreateSystemDefaultDevice(),
          let queue = d.makeMTL4CommandQueue(),
          let cmdBuffer = d.makeCommandBuffer(),
          let alloc = d.makeCommandAllocator()
    else {
      fatalError("unable to create metal artifacts")
    }
    self.device = d
    self.commandQueue = queue
    self.commandBuffer = cmdBuffer
    self.allocator = alloc
    super.init()
  }

  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

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
    encoder.endEncoding()
    commandBuffer.endCommandBuffer()
    commandQueue.waitForDrawable(drawable)
    commandQueue.commit([commandBuffer])
    commandQueue.signalDrawable(drawable)
    drawable.present()
  }
}
