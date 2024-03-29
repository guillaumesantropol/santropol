//
//  ProfileViewController.swift
//  Santrapol_UA
//
//  Created by Anshul Manocha on 2019-03-04.
//  Copyright © 2019 Anshul Manocha. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import PhoneNumberKit
import Foundation
import SVProgressHUD

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileView: UIView!
    
    let screenSize:CGRect = UIScreen.main.bounds

    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        profileView.layer.borderWidth = 1
        profileView.layer.masksToBounds = false
       // profileView.frame.size.height = screenSize.height * 0.2
        profileView.layer.borderColor = UIColor.gray.cgColor
        profileView.layer.cornerRadius = screenSize.height * 0.15
        profileView.clipsToBounds = true
        
        self.navigationItem.title = ""
        
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.isTranslucent = true
        
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "SignOutSegue", sender: nil)
        } catch {
            print(error)
        }
        
    }
    
    
    


}



class ProfileEdit: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var viewScroll: UIView!
    
    //Labels
    @IBOutlet weak var personalLbl: UILabel!
    @IBOutlet weak var birthdayLbl: UILabel!
    @IBOutlet weak var contactLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var roulantUsernameLbl: UILabel!
    
    
    // Fields
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var postalCodeField: UITextField!
    @IBOutlet weak var roulantUserNameField: UITextField!
    
    let userid = Auth.auth().currentUser!.uid
    var old_key: String?
    var registration_date: String?
    var old_no_show: Int?
    var registeredUsersFull = [UserInformation]()
    var origin_phone_number: String?
    var origin_email: String?
    var credential: AuthCredential!
    var EventList = [Model]()
    
    lazy var datePicker: UIDatePicker = {
        
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        
        picker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
        return picker
    } ()
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    } ()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                //Labels
        personalLbl.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        personalLbl.layer.cornerRadius = 5
        personalLbl.clipsToBounds = true
        
        birthdayLbl.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        birthdayLbl.layer.cornerRadius = 5
        birthdayLbl.clipsToBounds = true
        
        contactLbl.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        contactLbl.layer.cornerRadius = 5
        contactLbl.clipsToBounds = true
        
        addressLbl.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        addressLbl.layer.cornerRadius = 5
        addressLbl.clipsToBounds = true
        
        roulantUsernameLbl.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        
        roulantUsernameLbl.layer.cornerRadius = 5
        roulantUsernameLbl.clipsToBounds = true
        
        
        
        
        
        firstNameField.backgroundColor = UIColor(red: 198/255, green: 94/255, blue: 196/255, alpha: 0.5)
        firstNameField.layer.cornerRadius = 5
        firstNameField.clipsToBounds = true
        
        lastNameField.backgroundColor = UIColor(red: 198/255, green: 94/255, blue: 196/255, alpha: 0.5)
        lastNameField.layer.cornerRadius = 5
        lastNameField.clipsToBounds = true
        
        dobField.backgroundColor = UIColor(red: 198/255, green: 94/255, blue: 196/255, alpha: 0.5)
        dobField.layer.cornerRadius = 5
        dobField.clipsToBounds = true
        
        emailField.backgroundColor = UIColor(red: 198/255, green: 94/255, blue: 196/255, alpha: 0.5)
        emailField.layer.cornerRadius = 5
        emailField.clipsToBounds = true
        
        phoneField.backgroundColor = UIColor(red: 198/255, green: 94/255, blue: 196/255, alpha: 0.5)
        phoneField.layer.cornerRadius = 5
        phoneField.clipsToBounds = true
        
        addressField.backgroundColor = UIColor(red: 198/255, green: 94/255, blue: 196/255, alpha: 0.5)
        addressField.layer.cornerRadius = 5
        addressField.clipsToBounds = true
        
        cityField.backgroundColor = UIColor(red: 198/255, green: 94/255, blue: 196/255, alpha: 0.5)
        cityField.layer.cornerRadius = 5
        cityField.clipsToBounds = true
        
        postalCodeField.backgroundColor = UIColor(red: 198/255, green: 94/255, blue: 196/255, alpha: 0.5)
        postalCodeField.layer.cornerRadius = 5
        postalCodeField.clipsToBounds = true
        
        roulantUserNameField.backgroundColor = UIColor(red: 63/255, green: 128/255, blue: 52/255, alpha: 0.5)
        roulantUserNameField.layer.cornerRadius = 5
        roulantUserNameField.clipsToBounds = true
        
        dobField.inputView = datePicker
        
        self.navigationItem.title = "Your Roulant Profile"
    
        
        self.viewScroll.backgroundColor = UIColor.clear
        
        postalCodeField.delegate = self
        lastNameField.delegate = self
        phoneField.delegate = self
        roulantUserNameField.delegate = self
        
        roulantUserNameField.isUserInteractionEnabled = false
        
        
        
        
        // Load the date from Firebase
        var user_uid: String?
        
        Database.database().reference().child("user").queryOrdered(byChild: "key").queryEqual(toValue: userid).observe(.value, with: { (snapshot) in
            
            for child in snapshot.children {
                
                let childSnapshot = child as? DataSnapshot
                let dict = childSnapshot?.value as? [String:Any]
                
                
                // Fetch the user information and communicate to the global variable
                
                self.firstNameField.text = dict?["first_name"] as? String
                
                self.lastNameField.text = dict?["last_name"] as? String
                
                var dob = dict?["dob"] as? String
                
                
                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateFormat = "yyyyMMdd"
                
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "MMMM dd,yyyy"
                
                let date = dateFormatterGet.date(from: dob!)
                
                self.dobField.text = dateFormatterPrint.string(from: date ?? Date())
               
                
                
                
                
                self.emailField.text = dict?["email"] as? String
                
                self.origin_email = dict?["email"] as? String
                
                var phone_number = dict?["phone_number"] as? String ?? ""
                
                self.origin_phone_number = dict?["phone_number"] as? String ?? ""
                
                phone_number = "(\(phone_number.prefix(3))) \(phone_number.prefix(6).suffix(3))-\(phone_number.suffix(4))"
                
                self.phoneField.text = phone_number
                
                
                var addressNumber = dict?["address_number"] as? Int
                var address_street = dict?["address_street"] as? String
                
                self.addressField.text = "\(String(addressNumber ?? 0)), \(address_street ?? "")"
                
                self.cityField.text = dict?["address_city"] as? String
                
                var postal_code = dict?["address_postal_code"] as? String ?? ""
                
                var postal_code2 = String(postal_code.prefix(3) + " " + postal_code.suffix(3))
                
                self.postalCodeField.text = postal_code2
                
                
                let placeholder = childSnapshot?.key
                
                self.roulantUserNameField.attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.5)])

                
                self.old_key = childSnapshot?.key
                
                self.registration_date = dict?["signup_date"] as? String
                
                self.old_no_show = dict?["no_show"] as? Int
                
            }
            
        })
        
        
        Database.database().reference().child("user").observe(.value, with: { (snapshot) in
            
            self.registeredUsersFull.removeAll()
            
            for child in snapshot.children {
                
                let childSnapshot = child as? DataSnapshot
                let dict = childSnapshot?.value as? [String:Any]
                
                let email = dict?["email"] as? String
                let phone_number = dict?["phone_number"] as? String
                
                let registeredUser = UserInformation(email: email, phone_number: phone_number)
                
                self.registeredUsersFull.append(registeredUser)
                
            }
        })
        
        
        // Load information about the events the user is registered in
        
        
        Database.database().reference().child("event").queryOrdered(byChild: "key").queryEqual(toValue: userid).observe(.value, with: { (snapshot) in
            
            self.EventList.removeAll()
            
            for child in snapshot.children {
                
                
                let childSnapshot = child as? DataSnapshot
                let dict = childSnapshot?.value as? [String:Any]
                
                let eventid = childSnapshot?.key
                
                let event = Model(eventid: eventid)
                
                self.EventList.append(event)
                
            }
                
        })
        
        
    }
    
    @objc func datePickerChanged(_ sender: UIDatePicker) {
        
        dobField.text = dateFormatter.string(from: sender.date)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneField {
            
            self.phoneField.text = PartialFormatter().formatPartial(self.phoneField.text!)
            
            let text = NSString(string: String(phoneField.text!)).replacingCharacters(in: range, with: string)
            
            self.roulantUserNameField.attributedPlaceholder = NSAttributedString(string: String(lastNameField.text!.lowercased().prefix(2) + text.digitsOnly().prefix(10)), attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.5)])

           return range.location < 14
            
            
            
        } else if textField == postalCodeField {
            
             return range.location < 7
            
        } else if textField == lastNameField  {
            
            let text = NSString(string:             String(lastNameField.text!)).replacingCharacters(in: range, with: string)
            
            
            self.roulantUserNameField.attributedPlaceholder = NSAttributedString(string: text.lowercased().prefix(2) + (phoneField.text?.digitsOnly())!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.5)])

            return true
            
        } else {
            
            return true
            
        }
        
        
    }
    
    
    @IBAction func saveChangesTapped(_ sender: UIButton) {
        
        SVProgressHUD.setForegroundColor(UIColor(red: 104.0/255.0, green: 23.0/255.0, blue: 104.0/255.0, alpha: 1.0))
        SVProgressHUD.show()
        
        // Test for any error with the entries in the text fields
        var email_array = self.registeredUsersFull.map {$0.email}
        email_array = email_array.filter{$0 != origin_email}
        
        var phone_array = self.registeredUsersFull.map {$0.phone_number}
        phone_array = phone_array.filter{$0 != origin_phone_number}
        
        
        //First Name
        if firstNameField.text! == "" {
            
            showAlert(message: "Please enter a valid first name")
            SVProgressHUD.dismiss()
            return
            
        }
        
        
        //Last Name
        
        else if lastNameField.text! == "" {
            
            showAlert(message: "Please enter a valid last name")
            SVProgressHUD.dismiss()
            return
        }
        
        //Date of Birth
        
        else if dobField.text! == "" {
            
            showAlert(message: "Please enter a valid date of birth")
            SVProgressHUD.dismiss()
            return
        }
        
        //Email Address
            
            
        else if isValidEmail(testStr: emailField.text!) == false {
            
            showAlert(message: "Please enter a valid email address")
            SVProgressHUD.dismiss()
            return
        }
        
        else if email_array.contains(self.emailField.text!) {
            
            showAlert(message: "This email is already in use by another volunteer!")
            SVProgressHUD.dismiss()
            return
        }
        
        
        //Phone Number
            
        else if phoneField.text!.digitsOnly().count != 10 {
            
            showAlert(message: "Please enter a valid phone number")
            SVProgressHUD.dismiss()
            return
        }
        
        else if phone_array.contains(phoneField.text!.digitsOnly()){
            
            showAlert(message: "This phone number is already in use by another volunteer!")
            SVProgressHUD.dismiss()
            return
        }
        
        //Address line
        
        else if addressField.text == "" {
            
            showAlert(message: "Please enter a valid address line")
            SVProgressHUD.dismiss()
            return
        }
        
        
        //City
        
        else if cityField.text == "" {
            
            showAlert(message: "Please enter a valid city")
            SVProgressHUD.dismiss()
            return
        }
        
        //Postal Code
        
        else if String(postalCodeField.text!.filter { !" \n\t\r".contains($0) }).count != 6 {
            
            showAlert(message: "Please enter a postal code")
            SVProgressHUD.dismiss()
            return
            
        }
        
        
        
        // Remove the old entry
        
       if old_key != roulantUserNameField.placeholder {
            
            Database.database().reference().child("user").child(old_key!).removeValue()
            
        }
        
        
       // Add a new entry
        
        let key = Auth.auth().currentUser!.uid
        
        // Collect the date
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMMM d, yyyy"
        
        let date = dateFormatterGet.date(from: dobField.text!)
        
        let year = Calendar.current.component(.year, from: date ?? Date())
        let month = Calendar.current.component(.month, from: date ?? Date())
        let day = Calendar.current.component(.day, from: date ?? Date())
        
        // Prepare the dictionary to update the Firebawse
        let dictionary: NSDictionary = [
            "first_name" : firstNameField.text,
            "last_name" : lastNameField.text,
            "email": emailField.text,
            "dob": "\(year)\(String(format: "%02d", month))\(String(format: "%02d", day))" as String,
            "phone_number": phoneField.text?.digitsOnly(),
            "address_city": cityField.text,
            "address_number": Int(addressField.text!.digitsOnly()) ?? 0,
            "address_postal_code": String(postalCodeField.text!.filter { !" \n\t\r".contains($0) }),
            "address_street": addressField.text!.components(separatedBy: CharacterSet.decimalDigits).joined().trimmingCharacters(in: NSCharacterSet(charactersIn: ",") as CharacterSet).trimmingCharacters(in: .whitespacesAndNewlines),
            "key": key,
            "signup_date": self.registration_date,
            "no_show": self.old_no_show
            
            // Write more information about the user in the future
            
        ]
        
        // Update the email of the user in the Firebase Authentification module
        

        let currentUser = Auth.auth().currentUser
        
        currentUser?.updateEmail(to: emailField.text!) { error in
            if let error = error {
                print(error)
            } else {
                print("CHANGED")
            }
        }
        
        // Insert the information in the database
        
       /* Database.database().reference().child("event").queryOrdered(byChild: "key").queryEqual(toValue: userid).child(userid).setValue("test") */
        Database.database().reference().child("user").child(roulantUserNameField.placeholder!).setValue(dictionary)
        
        // Need to update the new information in all the events a user is registered for:
        
        let eventid_list = self.EventList.map {$0.eventid}
        
        
        print(eventid_list)
        
        var childUpdates = [String:Any]()
        let eventRefUpdate = Database.database().reference().child("event")
        
        for eventid in eventid_list {
            
            childUpdates["/\(eventid ?? "")/first_name/"] = firstNameField.text
            childUpdates["/\(eventid ?? "")/last_name/"] = lastNameField.text
            childUpdates["/\(eventid ?? "")/uid/"] = roulantUserNameField.placeholder
            
        }

       eventRefUpdate.updateChildValues(childUpdates)
        
        
        if old_key != roulantUserNameField.placeholder {
            
            let alert = UIAlertController(title: "Success", message: "Your profile informations have been updated! Note that your username is now \(roulantUserNameField.placeholder ?? "").", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(OKAction)
            
            self.present(alert, animated: true, completion: nil)
            
            
        } else {
            
            let alert = UIAlertController(title: "Success", message: "Your profile informations have been updated!", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(OKAction)
            
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
        SVProgressHUD.dismiss()
        
    } // Ends the save changes function
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
        
        func showAlert(message:String){
            
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(OKAction)
            
            self.present(alert, animated: true, completion: nil)
        
    }
    
    
} // Ends the class



    /*
    @IBOutlet weak var PageHeader: UINavigationItem!
    let userid = Auth.auth().currentUser!.uid
    
    
    @IBOutlet weak var BarCode: UIImageView!
    @IBAction func EditProfileTapped(_ sender: Any) {
    }
    
    @IBAction func AttendanceTapped(_ sender: Any) {
        
        
        self.performSegue(withIdentifier: "goToHomefromPr", sender: self)
    }
    
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Profile"

         BarCode.image = generateBarcode(from: userid)
        // Do any additional setup after loading the view.
        
        // Allows to dismiss keyboard by tapping anywhere on the screen
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
    }
    
    @IBAction func LogoutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "SignOutSegue", sender: nil)
        } catch {
            print(error)
        }
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        
        let HomePage: HomePage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomePage") as! HomePage
        
        present(HomePage, animated:false, completion: nil)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
     */
    func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    
    
    
*/

