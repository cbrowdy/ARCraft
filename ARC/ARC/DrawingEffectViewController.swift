//
//  DrawingEffectViewController.swift
//  ARC
//
//  Created by Daniel Ryu on 3/27/23.
//

import Foundation
import UIKit
import ARKit
import SceneKit
import SCNRecorder

class DrawingEffectViewController : UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet weak var mainARSCN: ARSCNView!
    
    let cameraRelativePosition = SCNVector3(0,0,-0.1)
    var drawPressed:Bool = false
    
    @IBOutlet weak var penSwitch: UISwitch!
    @IBOutlet weak var menuBar: UIStackView!
    var usedColor:UIColor = UIColor.red
    
    var isRecording: Bool = false
    var recording: VideoRecording?
    
    @IBOutlet weak var colorMenu: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainARSCN.delegate = self
        mainARSCN.session.delegate = self
        let scene = SCNScene()
        mainARSCN.scene = scene
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        mainARSCN.session.run(configuration)
        mainARSCN.layer.zPosition = 0
        menuBar.layer.zPosition = 1

        mainARSCN.prepareForRecording()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isRecording = false
        finishVideoRecording(handler: {(URL) in self.recording

        })
        mainARSCN.pause((() -> ()).self)
    }
    
    @IBAction func colorChange(_ sender: Any) {
        if colorMenu.state.rawValue == 0 {
            usedColor = UIColor.red
        } else if (colorMenu.state.rawValue == 1) {
            usedColor = UIColor.blue
        } else if (colorMenu.state.rawValue == 2) {
            usedColor = UIColor.yellow
        } else {
            usedColor = UIColor.black
        }
    }
    
    @IBAction func penSwitchPressed(_ sender: Any) {
        if penSwitch.isOn {
            drawPressed = true
        } else {
            drawPressed = false
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if !drawPressed {
            return
        }
        
        let sphere = SCNNode()
        sphere.geometry = SCNSphere(radius: 0.0025)
        print(usedColor)
        sphere.geometry?.firstMaterial?.diffuse.contents = usedColor
        ObjectService.addChildNode(sphere, toNode: mainARSCN.scene.rootNode, inView: mainARSCN, cameraRelativePosition: cameraRelativePosition)
    }
    
    @IBAction func onRecordPress(_ sender: Any) {
        if isRecording {
            // Stop recording
            finishVideoRecording(handler: {(URL) in self.recording

            })
            present(
                UIActivityViewController(activityItems: [recording!.url], applicationActivities: nil),
                  animated: true,
                  completion: nil
            )
        } else {
            // Begin recording
            recordFeature()
        }
        
        isRecording = !isRecording
    }
    
    // When you hit the camera / record button
    func recordFeature() {
        let size = mainARSCN.frame.size
        do {
            recording = try startVideoRecording(size: size)
            print(recording!.$duration.value)
        } catch {
            print(error)
        }
        print("and...... ACTION!")
    }
}

@available(iOS 13.0, *)
extension DrawingEffectViewController {

  func takePhoto(handler: @escaping (UIImage) -> Void) {
    mainARSCN.takePhoto(completionHandler: handler)
  }

  func startVideoRecording(size: CGSize) throws -> VideoRecording {
    try mainARSCN.startVideoRecording(size: size)
  }

  func finishVideoRecording(handler: @escaping (URL) -> Void) {
      mainARSCN.finishVideoRecording(completionHandler: { handler($0.url) })
  }
}
