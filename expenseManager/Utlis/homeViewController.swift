//
//  homeViewController.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 25/05/23.
//

import UIKit
import FirebaseFirestore

class homeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    // Outlet connections
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var cornerBtnOutlet: UIButton!
    
    // Define the CardModel structure
    struct CardModel {
        let titleOutlet: String
        let iconImageView: UIImage?
        let expAmtOutlet: Double
        let leftAmtOutlet: Double
    }
    
    var cardData: [CardModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the data source and delegate for the table view
        tableViewOutlet.dataSource = self
        tableViewOutlet.delegate = self
        
        view.backgroundColor = .systemOrange
        
        // Register the custom table view cell
        tableViewOutlet.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        // Fetch data from Firestore
        fetchDataFromFirestore()
    }
    
    // Action triggered by the corner button
    @IBAction func cornerBtnAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instantiate and push AddCategoryViewController
        guard let addCategoryViewController = storyboard.instantiateViewController(withIdentifier: "AddCategoryViewController") as? AddCategoryViewController else {
            return
        }
        navigationController?.pushViewController(addCategoryViewController, animated: true)
    }
    
    // Fetch data from Firestore
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
                       let firstLetter = title.first {
                        let placeholderImage = self?.generatePlaceholderImage(text: String(firstLetter))
                        
                        let card = CardModel(titleOutlet: title,
                                             iconImageView: placeholderImage,
                                             expAmtOutlet: 0.0, // Default expense amount
                                             leftAmtOutlet: 0.0) // Default budget amount
                        cards.append(card)
                    }
                }
            }
            
            self?.cardData = cards
            self?.tableViewOutlet.reloadData()
        }
    }
    
    // Table view data source method - number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardData.count
    }
    
    // Table view data source method - cell for row at index path
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
    
    // Helper method to generate a placeholder image
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
}
