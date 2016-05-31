//
//  MOJO-E
//
//  Created by Tam Tran on 5/11/16.
//  Copyright © 2016 MOJO. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    //MARK: UI element
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialize()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UI ACtion
    @IBAction func finishAction(sender: AnyObject) {
        if validateSignUp() {
            if let name = usernameTextField.text {
                if let email = emailTextField.text, let password = passwordTextField.text {
                    FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
                        if let error = error {
                            if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
                                switch (errorCode) {
                                case .ErrorCodeNetworkError:
                                    Utility.showToastWithMessage(kErrorNetwork)
                                default:
                                    Utility.showToastWithMessage(error.description)
                                }
                            }
                        } else {
                            let profile = Profile()
                            profile.authenID = user!.uid
                            profile.isRemember = true
                            profile.isLogged = true
                            profile.email = email
                            profile.userName = name
                            profile.password = password
                            profile.syncToFirebase()
                            Utility.openAuthenticatedFlow()
                        }
                    })
                }
                else {
                    Utility.showToastWithMessage(kErrorEmailIsEmpty)
                }
            } else {
                Utility.showToastWithMessage(kErrorNameIsEmpty)
            }
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func initialize() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.endEditing))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        usernameTextField.becomeFirstResponder()
    }
    
    func endEditing() {
        self.view.endEditing(true)
    }
    
    private func validateSignUp() -> Bool {
        if let name = usernameTextField.text where name.count() < 4 {
            Utility.showToastWithMessage("Username should be at least 4 characters")
            return false
        }
        if let email = emailTextField.text where email.count() < 4 {
            Utility.showToastWithMessage("Email is not valid")
            return false
        }
        else {
            let email = emailTextField.text
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            if !emailTest.evaluateWithObject(email) {
                Utility.showToastWithMessage("Email is not valid")
                return false
            }
        }
        if let password = passwordTextField.text where password.count() < 6 {
            Utility.showToastWithMessage("Password should be at least 6 characters")
            return false
        }
        else {
            let password = passwordTextField.text
            let numberRegEx  = ".*[0-9]+.*"
            let passwordTest = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
            if !passwordTest.evaluateWithObject(password) {
                Utility.showToastWithMessage("Password should include at least 1 number")
                return false
            }
        }
        if let password = passwordTextField.text, let confirm = confirmPasswordTextField.text where password != confirm {
            Utility.showToastWithMessage("Confirm password doesn't match")
            return false
        }
        return true
        
    }
    
}
