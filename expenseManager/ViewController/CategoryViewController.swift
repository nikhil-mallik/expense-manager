//
//  CategoryViewController.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 27/05/23.
//

import UIKit
import FirebaseFirestore

class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - IBOutlets

    @IBOutlet weak var tableShowOutlet: UITableView! // Outlet for the table view
    @IBOutlet weak var nextButton: UIButton! // Outlet for the "Next" button
    @IBOutlet weak var logoutOutlet: UIButton! // Outlet for the "Logout" button
    
    // MARK: - Card Model
    
    struct CardModel {
        let titleOutlet: String
        let iconImageView: UIImage?
        let expAmtOutlet: Double
        let leftAmtOutlet: Double
    }
    
    var cardData: [CardModel] = [] // Array to store card data
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the data source and delegate for the table view
        tableShowOutlet.dataSource = self
        tableShowOutlet.delegate = self
        
        // Fetch data from Firestore
        fetchDataFromFirestore()
        
        // Add pull-down refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableShowOutlet.refreshControl = refreshControl
    }
    
    // MARK: - Actions
    
    @IBAction func nextButtonAction(_ sender: Any) {
        // Navigate to AddCategoryViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addCategoryViewController = storyboard.instantiateViewController(withIdentifier: "AddCategoryViewController") as? AddCategoryViewController else {
            return
        }
        navigationController?.pushViewController(addCategoryViewController, animated: true)
    }
    
    // MARK: - Firestore Data Fetch
    
    func fetchDataFromFirestore() {
        let db = Firestore.firestore()
        
        db.collection("Category").getDocuments { [weak self] snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "")")
                return
            }
            
            var cards: [CardModel] = []
            
            for document in snapshot.documents {
                let data = document.data()

                if let title = data["title"] as? String,
                   let imageURL = data["img"] as? String,
                   let expenseAmount = data["expAmt"] as? Double,
                   let budgetAmount = data["budget"] as? Double,
                   let image = UIImage(named: imageURL) {
                    let card = CardModel(titleOutlet: title,
                                         iconImageView: image,
                                         expAmtOutlet: expenseAmount,
                                         leftAmtOutlet: budgetAmount)
                    cards.append(card)
                } else {
                    // Use the first letter of the title as a placeholder image
                    if let title = data["title"] as? String,
                       let firstLetter = title.first?.uppercased() { // Convert the first letter to uppercase
                        let placeholderImage = self?.generatePlaceholderImage(text: firstLetter)
                        
                        let card = CardModel(titleOutlet: title,
                                             iconImageView: placeholderImage,
                                             expAmtOutlet: data["expAmt"] as? Double ?? 0.0, // Fetch expense amount from Firestore
                                             leftAmtOutlet: data["budget"] as? Double ?? 0.0) // Fetch budget amount from Firestore
                        cards.append(card)
                    }
                }
            }
            
            self?.cardData = cards
            self?.tableShowOutlet.reloadData()
        }
    }
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let card = cardData[indexPath.row]
        
        cell.titleOutlet.text = card.titleOutlet
        
        if let iconImage = card.iconImageView {
            cell.iconImageView.image = iconImage
        } else {
            let placeholderImage = self.generatePlaceholderImage(text: String(card.titleOutlet.prefix(1)))
            cell.iconImageView.image = placeholderImage
        }
        
        cell.expAmtOutlet.text = "\(card.expAmtOutlet)"
        cell.leftAmtOutlet.text = "\(card.leftAmtOutlet)"
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // Set the desired constant height for the table view cells
    }
    
    // MARK: - Helper Methods
    
    func generatePlaceholderImage(text: String) -> UIImage? {
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.lightGray.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        let textRect = CGRect(x: 0, y: (size.height - 30) / 2, width: size.width, height: 30)
        attributedText.draw(in: textRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - Pull-down Refresh
    
    @objc func refreshData(_ sender: Any) {
        // Fetch data from Firestore
        fetchDataFromFirestore()
        
        // End the refreshing
        tableShowOutlet.refreshControl?.endRefreshing()
    }
}



