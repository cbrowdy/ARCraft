//
//  ARViewContainer.swift
//  ARC
//
//  Created by Daniel Ryu on 2/11/23.
//

import SwiftUI
import ARKit
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        return arView
    }
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
}
