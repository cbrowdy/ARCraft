//
//  LoginViewController.swift
//  ARC
//
//  Created by Daniel Ryu on 2/2/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //When user presses the login button on login screen
    @IBAction func loginSubmit(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailAddress.text!, password: password.text!) { [weak self] authResult, error in
          guard let strongSelf = self else {
              print("error")
              return
          }
        }
//        do{
//            try Auth.auth().signOut()
//        } catch let signOutError as NSError {
//            print("Error signing out: %@", signOutError)
//        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
