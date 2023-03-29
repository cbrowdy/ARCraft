//
//  Bones.swift
//  ARC
//
//  Created by Daniel Ryu on 2/11/23.
//

import Foundation

enum Bones: CaseIterable {
    case leftShoulderToLeftArm
    case leftArmToLeftForearm
    case leftForearmToLeftHand
    
    var name:String{
        return "\(self.jointFromName)-\(self.jointToName)"
    }
    
    var jointFromName: String{
        switch self {
        case .leftShoulderToLeftArm:
            return "left_shoulder_1_joint"
        case .leftArmToLeftForearm:
            return "left_arm_joint"
        case .leftForearmToLeftHand:
            return "left_forearm_joint"
        }
    }
    
    var jointToName: String {
        switch self{
        case .leftShoulderToLeftArm:
            return "left_arm_joint"
        case .leftArmToLeftForearm:
            return "left_forearm_joint"
        case .leftForearmToLeftHand:
            return "left_hand_joint"
        }
    }
}
