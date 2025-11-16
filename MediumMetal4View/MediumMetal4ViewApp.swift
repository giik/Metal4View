//
// MediumMetal4ViewApp.swift
//
// Created for MediumMetal4View
//     on 11/14/25
//     by GIIK Web Development

import SwiftUI

@main
struct MediumMetal4ViewApp: App {
  var body: some Scene {
    WindowGroup { ContentView() }
  }
}

struct ContentView: View {
  @State private var startDate = Date.now

  var body: some View {
    TimelineView(.periodic(from: self.startDate, by: 1/10)) { ctx in
      let elapsed = ctx.date.timeIntervalSince(self.startDate)
      let rads = Angle(degrees: elapsed * 20).radians
      let tanRads = Angle(radians: rads.truncatingRemainder(dividingBy: .pi)).radians
      return Metal4View(color: Color(red: tan(tanRads), green: sin(rads), blue: cos(rads)))
    }
  }
}
