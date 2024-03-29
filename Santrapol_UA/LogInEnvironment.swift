//
//  LogInEnvironment.swift
//  Santrapol_UA
//
//  Created by G Lapierre on 2019-07-31.
//  Copyright © 2019 Anshul Manocha. All rights reserved.
//

import UIKit
import FirebaseAuth  //for User Authentication
import FirebaseDatabase
import SVProgressHUD

class LogInEnvironment: UIViewController {

    
    
    @IBOutlet weak var userNameField: UITextField!
    //   @IBOutlet weak var userNameField: UITextField!
    
    
    @IBOutlet weak var PasswordField: UITextField!
    
   // @IBOutlet weak var PasswordField: UITextField!
    
    @IBOutlet weak var showToggle: UIButton!
    
  //  @IBOutlet weak var showToggle: UIButton!
    
    override func viewDidAppear(_ animated: Bool){
        
      userNameField.becomeFirstResponder()
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameField.frame.size.width = UIScreen.main.bounds.width - 58
        
        PasswordField.frame.size.width = UIScreen.main.bounds.width - 58
        
        
        self.navigationItem.rightBarButtonItem!.tintColor = UIColor.white
        
        navigationItem.rightBarButtonItem!.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 14)!], for: .normal)
        
        navigationItem.rightBarButtonItem!.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "AvenirNext-DemiBold", size: 14)!], for: .highlighted)

        
        userNameField.setBottomBorder(withColor: UIColor.white)
        PasswordField.setBottomBorder(withColor: UIColor.white)

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func showToggleTapped(_ sender: UIButton) {
        
        if PasswordField.isSecureTextEntry == false {
            
            // The button is showing text and now we want to hide it
            PasswordField.isSecureTextEntry = true
            UIView.performWithoutAnimation {
                showToggle.setTitle("Show", for: .normal)
                showToggle.layoutIfNeeded()
            }
            
        } else {
            
            // The password is hidden and now we want to display it
            PasswordField.isSecureTextEntry = false
            UIView.performWithoutAnimation {
                showToggle.setTitle("Hide", for: .normal)
                showToggle.layoutIfNeeded()
            }
            
            
        }
        
        
    }

    
    @IBAction func logInTapped(_ sender: Any) {
        
        SVProgressHUD.setForegroundColor(UIColor(red: 104.0/255.0, green: 23.0/255.0, blue: 104.0/255.0, alpha: 1.0))
        SVProgressHUD.show()
        
        var username: String
        
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        
        
        
        
        if userNameField.text == "" {
            SVProgressHUD.dismiss()
            showAlert(message: "User doesn't exist")

            return
            
            // Check if username input contains special characters (not supported by Firebase)
        } else if userNameField.text!.rangeOfCharacter(from: characterset.inverted) != nil {
            
            SVProgressHUD.dismiss()
            showAlert(message: "User doesn't exist")

            return
            
        }
        
        
        
        
        Database.database().reference().child("user").child(userNameField.text!).child("email").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let email1 = snapshot.value
            
            
            if let email = email1, let pass = self.PasswordField.text {
                Auth.auth().signIn(withEmail: email as? String ?? "invalidemail@hotmail.com", password: pass) { (user, error) in
                    // ...
                    if error != nil
                    {
                        if let errCode = AuthErrorCode(rawValue: error!._code) {
                            
                            switch errCode {
                            case .invalidEmail:
                                print("Invalid email")
                                self.showAlert(message: "Please enter valid email")
         
                                
                            case .userDisabled:
                                self.showAlert(message: "User is disabled")

                            case .wrongPassword:
                                
                                self.showAlert(message: "Incorrect Password")
     
                            default:
                                
                                self.showAlert(message: "User doesn't exist")
                            }
                            
                            SVProgressHUD.dismiss()
                            
                        }
                        
                        
                    }
                    else {
                        
                        
                        
                        let userid = Auth.auth().currentUser!.uid
                        //else {return}
                        print(userid)
                        self.performSegue(withIdentifier: "goToMainPage", sender: self)
                        
                        SVProgressHUD.dismiss()
                    }
                    
                } // Ends the second if statement
                
                
                
            } // Ends first if statement
            
            
            
        })
        
        
    } // Ends tap function
    

   
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToRecoverPass", sender: self)
    }
    
    func showAlert(message:String){
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(OKAction)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    

}



class RecoverPass: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidAppear(_ animated: Bool){
        
         emailField.becomeFirstResponder()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    emailField.frame.size.width = UIScreen.main.bounds.width - 58
        
        emailField.setBottomBorder(withColor: UIColor.white)
    }
    
    
    @IBAction func resetPassTapped(_ sender: Any) {
        
        if emailField.text?.isEmpty == false
        {
            let email = emailField.text
            
            Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
                
                if error != nil {
                    
                let userMsg:String = error!.localizedDescription
                    
                self.showAlert(message: userMsg)

                }
                else {
                    
                    let alert = UIAlertController(title: "Success", message: "An email has been sent to \(email ?? "test")", preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    alert.addAction(OKAction)
                    
                    self.present(alert, animated: true, completion: nil)

                }
                return
            }
        }
        else {
            
            self.showAlert(message: "Please enter valid email address")

        }
        
        
    }
    
    func showAlert(message:String){
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(OKAction)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
}
