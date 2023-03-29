//
//  CollectionViewController.swift
//  ARC
//
//  Created by Sproull Student on 3/4/23.
//

import UIKit
import AVKit
import AVFoundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var craftsCollection: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageCache : [UIImage] = []
    var lengthCache : [String] = []
    var urlCache : [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spinner.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        
        spinner.isHidden = false
        spinner.startAnimating()
        craftsCollection.delegate = self
        craftsCollection.dataSource = self
        
        DispatchQueue.global().async {
            self.fetchCrafts()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lengthCache.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cell = craftsCollection.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CollectionViewCell else {
            return craftsCollection.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        }
        
        let width = view.frame.width / 3
        cell.thumbnail.frame.size = CGSize(width: width, height: width)
        
        let index = indexPath.row
        cell.thumbnail.image = imageCache[index]
        cell.duration.text = lengthCache[index]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width / 3
        return CGSize(width: width, height: width)
    }

    internal func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        return configureContextMenu(index: indexPaths[0].row, indexPath: indexPaths)
    }
    
    func configureContextMenu(index: Int, indexPath: [IndexPath]) -> UIContextMenuConfiguration{
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            
            let view = UIAction(title: "View", image: UIImage(named: "See"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                
                let avPlayer = AVPlayer(url: self.urlCache[index])
                let avController = AVPlayerViewController()
                avController.player = avPlayer
                self.present(avController, animated: true, completion: {
                    avPlayer.play()
                })
            }
            
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                
                let url = self.urlCache[index]
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
                // exclude some activity types from the list (optional)
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.postToFacebook ]
        
                // present the view controller
                self.present(activityViewController, animated: true, completion: nil)
            }
            
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), identifier: nil, discoverabilityTitle: nil, state: .off) { [self] (_) in
                
                // Check if signed in
                guard let user = Auth.auth().currentUser else {
                    return
                }
                
                // Delete from cloud firestore
                let targetPath = urlCache[index].relativePath
                let db = Firestore.firestore()
                db.collection(user.uid).document("crafts").collection("urls").getDocuments(completion: {
                    snapshot, error in
                    
                    guard error == nil else {
                        return
                    }
                    
                    guard snapshot != nil else {
                        return
                    }
                    
                    var truePath = ""
                    let pattern = #"(crafts(.*))"#
                    do {
                        let regex = try Regex(pattern)
                        if let result = targetPath.firstMatch(of: regex) {
                            truePath = String(result.0)
                        }
                    } catch {
                        print("couldn't get regex")
                    }
                    
                    for doc in snapshot!.documents {
                        let path = doc["url"] as! String
                        
                        if path == truePath {
                            // Delete from Cloud Firestore
                            doc.reference.delete()
                            
                            // Delete from Firebase Storage
                            let storageRef = Storage.storage().reference()
                            storageRef.child(path).delete(completion: { err in
                                if let err = err {
                                    print("Error removing document: \(err)")
                                } else {
                                    print("Document successfully removed!")
                                }
                            })
                            
                            break
                        }
                    }
                })
                
                // Delete from collectionview
                self.craftsCollection.deleteItems(at: indexPath)
                self.urlCache.remove(at: index)
                self.imageCache.remove(at: index)
                self.lengthCache.remove(at: index)
                self.craftsCollection.reloadData()
            }
            
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [view, share, delete])
            
        }
        return context
    }
    
    func fetchCrafts() {
        // Check if signed in
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        
        // Check cloud firestore
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
            
            if paths.count <= 0 {
                // Nothing found for profile so just stop checking
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                return
            }
            
            var index = 0
            for path in paths {
                // Go through every path available for a craft
                let storageRef = Storage.storage().reference()
                let craftRef = storageRef.child(path)
                
                craftRef.downloadURL(completion: {
                    url, error in
                    
                    guard url != nil else {
                        return
                    }
                    
                    guard error == nil else {
                        return
                    }
                    
                    let asset = AVAsset(url: url!)
                    
                    // Get URL
                    self.urlCache.append(url!)
                    
                    // Get length
                    let duration = asset.duration
                    let durationTime = CMTimeGetSeconds(duration)
                    let minutes = durationTime / 60 < 1 ? 0 : Int(durationTime / 60)
                    let seconds = Int(durationTime.truncatingRemainder(dividingBy: 60))
                    let stringSeconds = seconds < 10 ? "0\(seconds)":"\(seconds)" 
                    let videoDuration = "\(minutes):\(stringSeconds)"
                    self.lengthCache.append(videoDuration)
                    
                    // Get thumbnail
                    let imageGenerator = AVAssetImageGenerator(asset: asset)

                    do {
                        let thumbnail = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                        let uiImage = UIImage(cgImage: thumbnail)
                        self.imageCache.append(uiImage)
                    }
                    catch {
                        print(error)
                    }
                    
                    index += 1
                    if index >= paths.count {
                        self.spinner.stopAnimating()
                        self.spinner.isHidden =  true
                        self.craftsCollection.reloadData()
                    }
                })
            }
        })
    }
}
