//
//  ProfilePageViewController.swift
//  ARC
//
//  Created by Sproull Student on 2/18/23.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class ProfilePageViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var emailAddress: UILabel!
    @IBOutlet weak var profileSpinner: UIActivityIndicatorView!
    
   
    @IBOutlet weak var credits: UILabel!
    
    
    @IBAction func showCredit(_ sender: Any) {
        credits.numberOfLines = 3
        print("working")
        credits.text = "Train Model is accredited to Polycam user Toslolini. It was saved on Mar 27 at 2:05PM."
    }
    @IBAction func hideCredit(_ sender: Any) {
//        credits.text = ""
    }
    
    
    var cachedProfile: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        profilePicture.layer.cornerRadius = profilePicture.frame.size.height / 2
        
        if Auth.auth().currentUser != nil {
            emailAddress.text = Auth.auth().currentUser?.email
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        profileSpinner.startAnimating()
        profileSpinner.isHidden = false
        
        if cachedProfile == nil {
            DispatchQueue.main.async {
                self.getProfilePicture()
            }
        } else {
            profileSpinner.stopAnimating()
            profileSpinner.isHidden = true
        }
    }
    
    func getProfilePicture() {
        // Get current user
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        // CITATION: https://www.youtube.com/watch?v=YgjYVbg1oiA
        // Get firestore ref
        let db = Firestore.firestore()
        db.collection(user.uid).getDocuments { snapshot, error in
            
            guard error == nil else {
                return
            }
            
            guard snapshot != nil else {
                return
            }
            
            // In case there are multiple results
            var paths = [String]()
            for doc in snapshot!.documents {
                paths.append(doc["url"] as! String)
            }
            
            if paths.count <= 0 {
                // Nothing found for profile so just stop checking
                self.profileSpinner.stopAnimating()
                self.profileSpinner.isHidden = true
                return
            }
            
            for path in paths {
                let storageRef = Storage.storage().reference()
                let profileRef = storageRef.child(path)
                profileRef.getData(maxSize: 5 * 1024 * 1024, completion: { [weak self] data, error in
                    
                    guard let strongSelf = self else {
                        return
                    }

                    guard data != nil else {
                        return
                    }
                    
                    guard error == nil else {
                        return
                    }

                    if let image = UIImage(data: data!) {
                        DispatchQueue.main.async {
                            strongSelf.cachedProfile = image
                            strongSelf.profilePicture.image = image
                            strongSelf.profileSpinner.stopAnimating()
                            strongSelf.profileSpinner.isHidden = true
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func changeProfilePicture(_ sender: Any) {
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            self.present(picker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        guard let profile = profilePicture else {
            return
        }
        
        // Set profile picture with Firebase
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        // Check if we can convert image to data
        let imageData = image.jpegData(compressionQuality: 0.7)
        guard imageData != nil else {
            return
        }
        
        // Specify file path and name
        let storageRef = Storage.storage().reference()
        let profilePath = "profile/\(user.uid).jpg"
        let profileRef = storageRef.child(profilePath)
        
        // Upload data
        profileRef.putData(imageData!, metadata: nil) {
            metadata, error in
            
            if error != nil || metadata == nil {
                return
            }
            
            // Save reference to file in Firestore DB
            let db = Firestore.firestore()
            db.collection(user.uid).document("profile").setData(["url" : profilePath]) {
                err in
                if err != nil {
                    print("Error changing profile picture")
                } else {
                    print("Worked")
                }
            }
        }
        
        // Set profile picture on app
        cachedProfile = image
        profile.image = image
        dismiss(animated: true)
    }
    
    func setDefault() {
        let defaultImage = UIImage(named: "ARC_Small")
        profilePicture.image = defaultImage
    }
    
    @IBAction func showCameraFeed(_ sender: Any) {
        guard let strongStoryboard = storyboard else {
           return
       }

       guard let collectionVC = strongStoryboard.instantiateViewController(withIdentifier: "collectionVC") as? CollectionViewController  else {
           return
       }
        
        navigationController?.pushViewController(collectionVC, animated: true)
    }
    
    @IBAction func signoutAttempt(_ sender: Any) {
        if IsLoggedIn() {
            do {
                try Auth.auth().signOut()
                cachedProfile = nil
                profilePicture.image = nil
                //delegate?.resetPicture()
                navigationController?.popViewController(animated: true)
            }
            catch {
                print("An error occurred")
            }
        }
        else {
            print("Already not logged in.")
        }
    }
    
    // Check if logged in
    func IsLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}
