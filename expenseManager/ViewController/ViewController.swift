//
//  ViewController.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 25/05/23.
//

import UIKit

class ViewController: UIViewController {

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigate to another page after 1.5 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let phoneVC = storyboard.instantiateViewController(withIdentifier: "phoneViewController")
            let navController = UINavigationController(rootViewController: phoneVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }
    }


}

