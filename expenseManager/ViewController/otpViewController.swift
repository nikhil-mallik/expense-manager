//
//  otpViewController.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 25/05/23.
//

import UIKit

class otpViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var resendOtpOutlet: UIButton!
    @IBOutlet weak var OtpCodeOutlet: UITextField!
    @IBOutlet weak var verifyBtnOutlet: UIButton!
    
    // MARK: Properties
    
    var verificationID: String?
    var phoneNumber: String?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate for the OTP text field
        OtpCodeOutlet.delegate = self
    }
    


     @IBAction func resendOtpAction(_ sender: Any) {
         guard let phoneNumber = phoneNumber else {
             showAlert(message: "No phone number found.")
             return
         }
         
         AuthManager.shared.startAuth(phoneNumber: phoneNumber) { [weak self] success in
             if success {
                 self?.showAlert(message: "OTP has been resent successfully.")
             } else {
                 self?.showAlert(message: "Failed to resend OTP.")
             }
         }
     }
     
    @IBAction func verifyBtnAction(_ sender: Any) {
        if let text = OtpCodeOutlet.text, !text.isEmpty {
            let code = text
            AuthManager.shared.verifyCode(smsCode: code) { [weak self] success in
                guard success else { return }
                DispatchQueue.main.async {
                    let vc = CategoryViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                }
            }
        }
    }
    
    // MARK: Show Alert
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
