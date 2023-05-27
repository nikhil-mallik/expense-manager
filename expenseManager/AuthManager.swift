//
//  AuthManager.swift
//  expense_manager
//
//  Created by Nikhil Mallik on 24/05/23.
//

import FirebaseAuth
import Foundation

class AuthManager {
    static let shared = AuthManager()
    private let auth = Auth.auth()
    
    private var verificationId: String?
    private var phoneNumber: String?
    
    // MARK: - Phone Authentication
    
    // Initiates phone number authentication by sending an OTP
    public func startAuth(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationId, error in
            guard let verificationId = verificationId, error == nil else {
                completion(false)
                return
            }
            
            self?.verificationId = verificationId
            
            completion(true)
        }
    }
    
    // Verifies the entered SMS code with the verification ID
    public func verifyCode(smsCode: String, completion: @escaping (Bool) -> Void) {
        guard let verificationId = verificationId else {
            completion(false)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: smsCode)
        
        auth.signIn(with: credential) { result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    // Resends the OTP to the stored phone number
        public func resendOTP(completion: @escaping (Bool) -> Void) {
            guard let phoneNumber = phoneNumber else {
                completion(false)
                return
            }
            
            startAuth(phoneNumber: phoneNumber) { success in
                completion(success)
            }
        }
}






