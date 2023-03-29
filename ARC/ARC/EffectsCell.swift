//
//  EffectsCell.swift
//  ARC
//
//  Created by Sproull Student on 2/18/23.
//

import UIKit

class EffectsCell: UICollectionViewCell {
    // Every effect has an image and text identifier
    @IBOutlet weak var effectsImage: UIImageView!
    @IBOutlet weak var effectsLabel: UILabel!
    
    // Will change from gray to yellow-ish when selected
    @IBOutlet weak var selectedView: UIView!
    
    func select() {
        selectedView.backgroundColor = UIColor.systemYellow
    }
    
    func deselect()
    {
        selectedView.backgroundColor = UIColor.lightGray
    }
}
