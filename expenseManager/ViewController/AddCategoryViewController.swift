//
//  AddCategoryViewController.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 26/05/23.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UniformTypeIdentifiers

class AddCategoryViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    // MARK: - Outlets
    
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var uploadImageOutlet: UITextField!
    @IBOutlet weak var titleOutlet: UITextField!
    @IBOutlet weak var amountOutlet: UITextField!
    @IBOutlet weak var addDataOutlet: UIButton!
    @IBOutlet weak var backBtnOutlet: UIButton!
    
    // MARK: - Properties
    
    var documentID: String?
    private var isUploadingData = false // Flag to track if data is currently being uploaded
    private var loaderView: UIActivityIndicatorView! // Loader view
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the loader view
        loaderView = UIActivityIndicatorView(style: .gray)
        loaderView.center = view.center
        view.addSubview(loaderView)
        // Set the title of the navigation item
                navigationItem.title = "Add Category"
        // Set the background color of the navigation bar
                navigationController?.navigationBar.barTintColor = UIColor.red
       
        navigationController?.navigationBar.tintColor = UIColor.black
    }
    
    // MARK: - Image Selection
    
    @IBAction func imageAction(_ sender: Any) {
        // Show image source selection alert
        let imageSourceSelectionAlert = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        
        // Camera option
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.showImagePicker(sourceType: .camera)
        }
        
        // Photo Library option
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.showImagePicker(sourceType: .photoLibrary)
        }
        
        // Cancel option
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add actions to the alert
        imageSourceSelectionAlert.addAction(cameraAction)
        imageSourceSelectionAlert.addAction(photoLibraryAction)
        imageSourceSelectionAlert.addAction(cancelAction)
        
        // Present the alert
        present(imageSourceSelectionAlert, animated: true, completion: nil)
    }
    
    // Show the image picker with the specified source type
    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        imagePickerController.mediaTypes = [UTType.image.identifier]
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func backBtnAction(_ sender: Any) {
        // Handle back button action
    }
    
    // MARK: - Add Button Action
    
    @IBAction func addDataAction(_ sender: Any) {
        guard !isUploadingData else {
            // If data is already being uploaded, ignore button tap
            return
        }
        
        // Set the flag to indicate data upload in progress
        isUploadingData = true
        
        // Disable the "Add" button
        addDataOutlet.isEnabled = false
        
        // Show loader
        showLoader()
        
        // Retrieve current user
        guard let currentUser = Auth.auth().currentUser else {
            // User is not logged in
            return
        }
        
        // Validate title field
        guard let title = titleOutlet.text, !title.isEmpty, let _ = title.rangeOfCharacter(from: CharacterSet.letters) else {
            hideLoader()
            displayAlert(message: "Please enter a valid title.")
            return
        }
        
        // Validate amount field
        guard let amountString = amountOutlet.text, let amount = Int(amountString) else {
            hideLoader()
            displayAlert(message: "Please enter a valid amount.")
            return
        }
        
        // Check if an image is selected
        guard let selectedImage = imageOutlet.image, let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
            hideLoader()
            displayAlert(message: "Please select an image.")
            return
        }
        
        // Create a unique ID for the image
        let imageID = UUID().uuidString
        
        // Create a storage reference with the image ID as the path
        let storageRef = Storage.storage().reference().child("images/\(imageID).jpg")
        
        // Upload the image to Firebase Storage
        let uploadTask = storageRef.putData(imageData, metadata: nil) { [weak self] (metadata, error) in
            if let error = error {
                // Handle the image upload error
                print("Image upload error: \(error.localizedDescription)")
                self?.hideLoader()
                self?.displayAlert(message: "Failed to upload image.")
            } else {
                // Image uploaded successfully, retrieve the image URL
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        // Handle the image URL retrieval error
                        print("Image URL retrieval error: \(error.localizedDescription)")
                        self?.hideLoader()
                        self?.displayAlert(message: "Failed to retrieve image URL.")
                    } else if let imageURL = url?.absoluteString {
                        // Image URL retrieved successfully, proceed to save data in Firestore
                        
                        // Prepare category data
                        let categoryData: [String: Any] = [
                            "uId": currentUser.uid,
                            "title": title,
                            "budget": amount,
                            "img": imageURL,
                            "expAmt": ""
                            // Add other fields as needed
                        ]
                        
                        // Save category data in Firestore
                        self?.saveCategoryData(categoryData)
                    }
                }
            }
        }
        
        // Observe the upload progress
        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let progress = snapshot.progress else {
                return
            }
            
            // Calculate the upload progress percentage
            let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            print("Upload progress: \(percentComplete)%")
            
            // Update loader progress, if applicable
            // updateLoaderProgress(percentComplete) // Replace this with your loader update code
        }
    }
    
    // Helper method to save category data in Firestore
    private func saveCategoryData(_ categoryData: [String: Any]) {
        let db = Firestore.firestore()
        
        // Add the category data to Firestore
        db.collection("Category").addDocument(data: categoryData) { [weak self] error in
            if let error = error {
                // Handle Firestore error
                print("Firestore error: \(error.localizedDescription)")
                self?.hideLoader()
                self?.displayAlert(message: "Failed to add category.")
            } else {
                // Category added successfully
                print("Category added to Firestore")
                self?.hideLoader()
                self?.displayAlert(message: "Category added successfully.")
                self?.clearFields()
                
                // Perform push navigation to the destination view controller
                if let categoryListViewController = self?.storyboard?.instantiateViewController(withIdentifier: "CategoryViewController") as? CategoryViewController {
                    self?.navigationController?.pushViewController(categoryListViewController, animated: true)
                }
            }
            
            // Reset the flag and enable the "Add" button
            self?.isUploadingData = false
            self?.addDataOutlet.isEnabled = true
        }
    }
    
    // Helper method to display an alert with the given message
    private func displayAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // Helper method to show the loader view
    private func showLoader() {
        loaderView.startAnimating()
    }
    
    // Helper method to hide the loader view
    private func hideLoader() {
        loaderView.stopAnimating()
    }
    
    // Helper method to clear the input fields
    private func clearFields() {
        titleOutlet.text = ""
        amountOutlet.text = ""
        imageOutlet.image = nil
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageOutlet.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}



