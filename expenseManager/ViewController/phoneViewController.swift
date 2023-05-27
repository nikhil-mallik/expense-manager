//
//  phoneViewController.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 25/05/23.
//

import UIKit

class phoneViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var phoneTextOutlet: UITextField!
    
    
    @IBOutlet weak var sendOTPOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        phoneTextOutlet.delegate = self
    }
    

    @IBAction func sendOTPAction(_ sender: Any) {
        guard let phoneNumber = phoneTextOutlet.text, !phoneNumber.isEmpty else {
                   showAlert(message: "Please enter a phone number.")
                   return
               }
               
               // Validate phone number format
               let phoneNumberRegex = "^\\d{10}$"
               let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
               let isValidPhoneNumber = phoneNumberPredicate.evaluate(with: phoneNumber)
               
               if !isValidPhoneNumber {
                   showAlert(message: "Please enter a valid 10-digit phone number.")
                   return
               }
               
               let number = "+91\(phoneNumber)"
               AuthManager.shared.startAuth(phoneNumber: number) { [weak self] success in
                   guard success else { return }
                   DispatchQueue.main.async {
                       guard let otpViewController = self?.storyboard?.instantiateViewController(withIdentifier: "otpViewController") as? otpViewController else {
                           return
                       }
                       otpViewController.title = "Enter Code"
                       otpViewController.phoneNumber = phoneNumber // Pass the phoneNumber to otpViewController
                       self?.navigationController?.pushViewController(otpViewController, animated: true)
                   }
               }
           }
    
    // MARK: Show alert

        func showAlert(message: String) {
            // Display an alert with the given message
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
            func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
            }
    

}
