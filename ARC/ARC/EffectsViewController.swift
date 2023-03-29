//
//  EffectsViewController.swift
//  ARC
//
//  Created by Sproull Student on 2/18/23.
//

import UIKit
import RealityKit
import ARKit
import Combine
import Foundation

class EffectsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ARSessionDelegate, ARSCNViewDelegate {
    @IBOutlet weak var effectsCollection: UICollectionView!
    var arView : ARView!
    var loading : UILabel!
    var currSelectedIndex = 0
    
    //Variables for robot effect
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [-1.0, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        effectsCollection.dataSource = self
        effectsCollection.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        effectsList.count
    }
    
    // Create effects list
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = effectsCollection.dequeueReusableCell(withReuseIdentifier: "effectsCell", for: indexPath) as? EffectsCell else {
            return effectsCollection.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        }
        
        let effect = effectsList[indexPath.row]
        cell.effectsImage.image = UIImage(systemName: effectIcons[indexPath.row])
        cell.effectsLabel.text = effect
        
        if currSelectedIndex != indexPath.row {
            cell.deselect()
            return cell
        }
        
        cell.select()
        
        // Reset effects before loading new one
        arView.scene.anchors.removeAll()
        loading.text = "Loading..."
        loading.isHidden = true
        
        switch currSelectedIndex {
        case 0:
            break
        case 1:
            boxEffect()
            break
        case 2:
            musicEffect()
            break
        case 3:
            robotEffect()
            break
        case 4:
            soccerEffect()
            break
        case 5:
            ericEffect()
            break
        case 6:
            let drawingVC = storyboard?.instantiateViewController(withIdentifier: "drawingVC") as! DrawingEffectViewController
            let nav = UINavigationController(rootViewController: drawingVC)
            
//            nav.modalPresentationStyle = .fullScreen // Default
//            if let sheet = nav.sheetPresentationController {
//                sheet.detents = [.large()]
//            }

            self.present(nav, animated: true)
            
//            var stack = self.navigationController?.viewControllers
//            stack?.popLast()
//            stack?.popLast()
//            stack?.append(drawingVC)
//            self.navigationController?.setViewControllers(stack!, animated: true)
            break
        
        case 7:
            ericDanielEffect()
            break
            
        default:
            // Should reset back to a valid index
            currSelectedIndex = 0
            arView.scene.anchors.removeAll()
            break
        }
        
        return cell
    }
    
    // Update the currently selected row
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currSelectedIndex = indexPath.row
        effectsCollection.reloadData()
    }
    
    func effectHelper(anchor: HasAnchoring, completion: () -> ()) {
        arView?.scene.addAnchor(anchor)
        completion()
    }
    
    func soccerEffect() {
        print("score start")
        arView?.session.delegate = self
        loading.isHidden = false
        DispatchQueue.main.async {
            let sphereAnchor = try! Experience.loadSoccer()
            self.loading.text = "Point your camera at a flat surface!"
            self.effectHelper(anchor: sphereAnchor, completion: {
                self.loading.isHidden = true
                self.loading.text = "Loading..."
            })
        }
    }
    func ericEffect() {
        print("eric start")
        arView?.session.delegate = self
        loading.isHidden = false
        DispatchQueue.main.async {
            let sphereAnchor = try! Experience.loadEric()
            self.loading.text = "Point your camera at a flat surface!"
            self.effectHelper(anchor: sphereAnchor, completion: {
                self.loading.isHidden = true
                self.loading.text = "Loading..."
            })
        }
    }
    func musicEffect() {
        print("music2 start")
        arView?.session.delegate = self
        loading.isHidden = false
        DispatchQueue.main.async {
            let sphereAnchor = try! Experience.loadMusic()
            self.loading.text = "Point your camera at a flat surface!"
            self.effectHelper(anchor: sphereAnchor, completion: {
                self.loading.isHidden = true
                self.loading.text = "Loading..."
            })
        }
    }
    func boxEffect() {
        print("box start")
        arView?.session.delegate = self
        loading.isHidden = false
        DispatchQueue.main.async {
            let sphereAnchor = try! Experience.loadBox()
            self.loading.text = "Point your camera at a flat surface!"
            self.effectHelper(anchor: sphereAnchor, completion: {
                self.loading.isHidden = true
                self.loading.text = "Loading..."
            })
        }
    }
    
    func ericDanielEffect() {
        print("ericdaniel start")
        arView?.session.delegate = self
        loading.isHidden = false
        DispatchQueue.main.async {
            let sphereAnchor = try! Experience.loadEricDaniel()
            self.loading.text = "Point your camera at a flat surface!"
            self.effectHelper(anchor: sphereAnchor, completion: {
                self.loading.isHidden = true
                self.loading.text = "Loading..."
            })
        }
    }
    
    //robot effect
    func robotEffect(){
        print("robot start")
        arView?.session.delegate = self

        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            let alert = UIAlertController(title: "Cannot Access", message: "This feature is only supported on devices with an A12 chip.", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                        //Cancel Action
                    }))
            
            present(alert, animated: true, completion: nil)
            currSelectedIndex = 0
            effectsCollection.reloadData()
            return
        }

        loading.isHidden = false
        
        
        
        // Run a body tracking configration.
        let configuration = ARBodyTrackingConfiguration()
        arView?.session.run(configuration)
        
        arView?.scene.addAnchor(characterAnchor)
        
        // Asynchronously load the 3D character.
        var cancellable: AnyCancellable? = nil
        cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellable?.cancel()
            }, receiveValue: { [self] (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                // Scale the character to human size
                character.scale = [1.0, 1.0, 1.0]
                self.character = character
                cancellable?.cancel()
                loading.text = "Point your camera at somebody!"
            } else {
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
    }
    
    //robot effect
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue
            }
            
            // Update the position of the character anchor's position.
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            characterAnchor.position = bodyPosition + characterOffset
            // Also copy over the rotation of the body anchor, because the skeleton's pose
            // in the world is relative to the body anchor's rotation.
            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
   
            if let character = character, character.parent == nil {
                // Attach the character to its anchor as soon as
                // 1. the body anchor was detected and
                // 2. the character was loaded.
                characterAnchor.addChild(character)
            }
        }
    }
}
