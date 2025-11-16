//
// ContentView.swift
//
// Created for MediumMetal4View
//     on 11/14/25
//     by GIIK Web Development

import MetalKit
import SwiftUI

struct Metal4View: NSViewRepresentable {
  // Needed to resolve the color.
  @Environment(\.self) var environment
  var color: Color

  func makeCoordinator() -> Metal4ViewCoordinator {
    Metal4ViewCoordinator()
  }

  // Creating the wrapped MTKView
  func makeNSView(context: Context) -> MTKView {
    let view = MTKView()
    view.delegate = context.coordinator
    view.device = context.coordinator.device
    return view
  }

  // Called when the view needs to be updated, incl. because the value of the Binding changed. It
  // gives us a chance to signal that drawing is needed which will happen when the delegate's draw()
  // method is called.
  func updateNSView(_ view: MTKView, context: Context) {
    let resolved = self.color.resolve(in: self.environment)
    view.clearColor = MTLClearColor(
      red: Double(resolved.red),
      green: Double(resolved.green),
      blue: Double(resolved.blue),
      alpha: Double(resolved.opacity)
    )
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
