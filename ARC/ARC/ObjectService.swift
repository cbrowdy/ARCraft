//
//  ObjectService.swift
//  ARC
//
//  Created by Daniel Ryu on 3/25/23.
//

import UIKit
import ARKit

class ObjectService : NSObject {
    static func addChildNode(_ node: SCNNode, toNode: SCNNode, inView: ARSCNView, cameraRelativePosition: SCNVector3){
        guard let currentFrame = inView.session.currentFrame else {return}
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = cameraRelativePosition.x
        translationMatrix.columns.3.y = cameraRelativePosition.y
        translationMatrix.columns.3.z = cameraRelativePosition.z
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        node.simdTransform = modifiedMatrix
        toNode.addChildNode(node)
    }
}
