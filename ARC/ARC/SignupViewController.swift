//
//  SignupViewController.swift
//  ARC
//
//  Created by Sproull Student on 2/18/23.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {

    @IBOutlet weak var emailID: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailID.text = ""
        password.text = ""
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailID.text = ""
        password.text = ""
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func signup(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailID.text ?? "", password: password.text ?? "") { [weak self] result, error in

            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                var errorMessage = ""

                let specificError = error as? NSError
                switch AuthErrorCode.Code(rawValue: specificError!.code)
                {
                case .emailAlreadyInUse:
                    errorMessage = "Email already in use"
                    break
                case .weakPassword:
                    errorMessage = "Password too short."
                    break
                default:
                    errorMessage = specificError!.localizedDescription
                    break
                }


                // Signup Failure Message
                let alert = UIAlertController(title: "Signup Failed!", message: errorMessage, preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                            //Cancel Action
                        }))
                
                strongSelf.present(alert, animated: true, completion: nil)
                return
            }

            // Successful signup
            let alert = UIAlertController(title: "Account Created", message: "Welcome to ARC", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                
                guard let viewControllers = strongSelf.navigationController?.viewControllers as? [UIViewController] else {
                    return
                }
                
                var vcCount = viewControllers.count
                if vcCount < 3 {
                    vcCount = 3
                }
                
                strongSelf.navigationController?.popToViewController(viewControllers[vcCount - 3], animated: true)
                }))
            strongSelf.present(alert, animated: true, completion: nil)
        }
    }
}
