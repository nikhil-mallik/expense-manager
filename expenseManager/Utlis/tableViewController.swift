//
//  tableViewController.swift
//  expenseManager
//
//  Created by Nikhil Mallik on 26/05/23.
//

import UIKit

class tableViewController: UIViewController {
    
    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        table.delegate = self
//        table.dataSource = self
        view.backgroundColor = .systemBlue
//        tableView.backgroundColor = .systemRed
        tblView.backgroundColor = .systemRed
    }
}

extension tableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped me")
    }
}

extension tableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Attempt"
        return cell
    }
    
}
