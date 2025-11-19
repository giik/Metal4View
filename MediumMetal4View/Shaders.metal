//
// Shaders.swift
//
// Created for MediumMetal4View
//     on 11/16/25
//     by GIIK Web Development

#include <metal_stdlib>
using namespace metal;

struct Vertex {
  float4 position [[position]];
  float pointSize [[point_size]];
  float4 color;
};

vertex Vertex vertex_f(uint id [[vertex_id]]) {
  return {
    .position = float4(0, 0, 0, 1),
    .pointSize = 200,
    .color = float4(1, 0, 0, 1),
  };
}

fragment float4 fragment_f(Vertex in [[stage_in]],
                           float2 pointPos [[point_coord]]) {
  if (distance(0.5, pointPos) > 0.5) { discard_fragment(); }
  return in.color;
}
