//
//  SigninViewController.swift
//  ARC
//
//  Created by Sproull Student on 2/18/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class SigninViewController: UIViewController {

    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailAddress.text = ""
        password.text = ""
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            navigationController?.popViewController(animated: false)
        }
        
        emailAddress.text = ""
        password.text = ""
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func login(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailAddress.text ?? "", password: password.text ?? "", completion: { [weak self] result, error in
                    
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                var errorMessage = ""
                
                let specificError = error as? NSError
                switch AuthErrorCode.Code(rawValue: specificError!.code) {
                case .invalidEmail:
                    errorMessage = "Invalid email address."
                    break
                case .wrongPassword:
                    errorMessage = "Invalid password entry."
                    break
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
                
                // Incorrect email or password message
                let alert = UIAlertController(title: "Login Failed!", message: errorMessage, preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                            //Cancel Action
                        }))
                
                strongSelf.present(alert, animated: true, completion: nil)
                return
            }
            
            // Successful signin
            let alert = UIAlertController(title: "Login Successful!", message: "You are now logged in.", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                strongSelf.navigationController?.popViewController(animated: true)
                    }))
            strongSelf.present(alert, animated: true, completion: nil)
        })
    }
    
    
    @IBAction func loginGoogle(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                return
            }

            guard let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                return
            }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                // At this point, our user is signed in
                strongSelf.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    // Push sign up page
    @IBAction func toSignup(_ sender: Any) {
        guard let strongStoryboard = storyboard else {
            return
        }
        
        guard let strongNav = navigationController else {
            return
        }
        
        guard let signupVC = strongStoryboard.instantiateViewController(withIdentifier: "signupVC") as? SignupViewController  else {
            return
        }
        
        strongNav.pushViewController(signupVC, animated: true)
    }
    
}
