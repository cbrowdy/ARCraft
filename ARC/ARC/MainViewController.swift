//
//  MainViewController.swift
//  ARC
//
//  Created by Sproull Student on 2/18/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import RealityKit
import ARKit
import AVKit
import Combine
import Foundation
import SCNRecorder

class MainViewController: UIViewController, ARSessionDelegate, UITabBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var recording: VideoRecording?
   
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var mainArView: ARView!
    @IBOutlet weak var bottomTab: UITabBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        InitNavigationBar()
        bottomTab.bringSubviewToFront(mainArView)
        
        bottomTab.delegate = self
        loadingLabel.isHidden = true
        mainArView.prepareForRecording()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 1:
            // Check if you're signed in
            if Auth.auth().currentUser == nil {
                let alert = UIAlertController(title: "Cannot Access", message: "Must sign in to use this feature.", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                }))
                
                alert.addAction(UIAlertAction(title: "To Signin", style: UIAlertAction.Style.default, handler: { _ in
                    let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "signinVC") as! SigninViewController
                    self.navigationController?.pushViewController(signupVC, animated: true)
                }))
                
                present(alert, animated: true, completion: nil)
                break
            }
            
            // Begin upload process
            seePhotos()
            break
        case 2:
            if item.title == "Record" {
                recordFeature()
                item.title = "Pause"
                item.selectedImage = UIImage(systemName: "pause")
                
            } else {
                finishVideoRecording(handler: {(URL) in self.recording

                })
                item.title = "Record"
                item.selectedImage = UIImage(systemName: "play.circle.fill")
                present(
                    UIActivityViewController(activityItems: [recording!.url], applicationActivities: nil),
                      animated: true,
                      completion: nil
                )
            }
            break
            
        case 3:
            showEffects()
            break
        default:
            break
        }
    }
    
    // Create profile picture button in top right corner
    func InitNavigationBar() {
        let profile = UIImage(named: "Profile")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: profile, style: .plain, target: self, action: #selector(showProfile))
        self.navigationItem.rightBarButtonItem?.customView?.bringSubviewToFront(mainArView)
    }
    
    // Show effects panel
    func showEffects() {
        
        // CITATION: https://sarunw.com/posts/bottom-sheet-in-ios-15-with-uisheetpresentationcontroller/
        let effectsVC = storyboard?.instantiateViewController(withIdentifier: "effectsVC") as! EffectsViewController
        effectsVC.arView = mainArView
        effectsVC.loading = loadingLabel
        let nav = UINavigationController(rootViewController: effectsVC)

        nav.modalPresentationStyle = .pageSheet // Default
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
        }

        self.present(nav, animated: true, completion: nil)
    }
    
    // Show profile page or login / signup page
    @objc func showProfile() {
        let auth = Auth.auth()
        
        if auth.currentUser != nil {
            // Send to profile page
            let profileVC = storyboard?.instantiateViewController(withIdentifier: "profileVC") as! ProfilePageViewController
            navigationController?.pushViewController(profileVC, animated: true)
        }
        else {
            // Send to login and/or signup page
            let signupVC = storyboard?.instantiateViewController(withIdentifier: "signinVC") as! SigninViewController
            navigationController?.pushViewController(signupVC, animated: true)
        }
    }
    
    // See your camera roll or creations you've made?
    func seePhotos() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        // Check if you can upload (cannot upload more than 20 crafts
        let db = Firestore.firestore()
        db.collection(user.uid).document("crafts").collection("urls").getDocuments(completion: {
            snapshot, error in
            
            guard error == nil else {
                return
            }
            
            guard snapshot != nil else {
                return
            }
            
            var paths = [String]()
            for doc in snapshot!.documents {
                paths.append(doc["url"] as! String)
            }
            
            if paths.count > 20 {
                // Cannot upload any more
                let alert = UIAlertController(title: "Failure", message: "You have reached the max capacity for uploading.", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                }))
                
                self.present(alert, animated: true, completion: nil)
                return
            }
        })
        
        // CITATION: https://stackoverflow.com/questions/58104572/cant-upload-video-to-firebase-storage-on-ios-13
        if let videoURL = info[.mediaURL] as? NSURL {
           let urlSlices = videoURL.relativeString.split(separator: ".")
           //Create a temp directory using the file name
           let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
           let targetURL = tempDirectoryURL.appendingPathComponent(String(urlSlices[1])).appendingPathExtension(String(urlSlices[2]))

           //Copy the video over
           do {
               try FileManager.default.copyItem(at: videoURL as URL, to: targetURL)
               let pathRef = "crafts/\(user.uid)/\(UUID().uuidString).mov"
               let storageRef = Storage.storage().reference().child(pathRef)
               storageRef.putFile(from: targetURL as URL, metadata: nil, completion: {
                   (metadata, error) in
                   guard metadata != nil else {
                       // Uh-oh, an error occurred!
                       let alert = UIAlertController(title: "Cannot Access", message: "File is too large", preferredStyle: UIAlertController.Style.alert)

                       alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                       }))
                       
                       self.present(alert, animated: true, completion: nil)
                       return
                   }
                   if error != nil {
                       return
                   }
                   
                   // Save reference to file in Firestore DB
                   let db = Firestore.firestore()
                   db.collection(user.uid).document("crafts").collection("urls").document().setData(["url":pathRef]) {
                       err in
                       if err != nil {
                           print("Error add video")
                       } else {
                           let alert = UIAlertController(title: "Success", message: "Craft successfully added!", preferredStyle: UIAlertController.Style.alert)

                           alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                           }))
                           
                           self.present(alert, animated: true, completion: nil)
                       }
                   }
               })
           } catch {
               print(error)
               return
           }
       }
       
       dismiss(animated: true, completion: nil)
    }
    
    // When you hit the camera / record button
    func recordFeature() {
        let size = mainArView.frame.size
        do{
            recording = try startVideoRecording(size: size)
            print(recording!.$duration.value)
        } catch{
            print(error)
        }
        print("and...... ACTION!")
    }
}

@available(iOS 13.0, *)
extension MainViewController {

  func takePhoto(handler: @escaping (UIImage) -> Void) {
    mainArView.takePhoto(completionHandler: handler)
  }

  func startVideoRecording(size: CGSize) throws -> VideoRecording {
    try mainArView.startVideoRecording(size: size)
  }

  func finishVideoRecording(handler: @escaping (URL) -> Void) {
    mainArView.finishVideoRecording(completionHandler: { handler($0.url) })
  }
}
