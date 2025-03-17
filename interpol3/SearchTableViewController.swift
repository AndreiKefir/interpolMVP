//
//  SearchTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 07/03/2025.
//

import UIKit

class SearchTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var forenameTextField: UITextField!
    @IBOutlet weak var familyNameTextField: UITextField!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var detailNationalityLabel: UILabel!
    @IBOutlet weak var detailCountryLabel: UILabel!
    
    var selectedNationality = "All"
    var selectedCountry = "All"
    var searchQuery = [URLQueryItem]()
    var countries = Countries()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forenameTextField.delegate = self
        familyNameTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detailNationalityLabel.text = selectedNationality
        detailCountryLabel.text = selectedCountry
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Network.shared.searchQuery = createQuery()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        20
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            let nationVC = storyboard?.instantiateViewController(withIdentifier: "nationVC") as! NationSelectTableViewController
            nationVC.delegate = self
            nationVC.selectedCountry = detailNationalityLabel.text
            navigationController?.pushViewController(nationVC, animated: true)
        }
        if indexPath.section == 4 {
            let countryVC = storyboard?.instantiateViewController(withIdentifier: "countryVC") as! CountrySelectTableViewController
            countryVC.delegate = self
            navigationController?.pushViewController(countryVC, animated: true)
        }
    }
    
    func createQuery() -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        if !forenameTextField.text!.isEmpty {
            let forenameQuery = URLQueryItem(name: "forename", value: forenameTextField.text)
            queryItems.append(forenameQuery)
        }
        if !familyNameTextField.text!.isEmpty {
            let familyNameQuery = URLQueryItem(name: "name", value: familyNameTextField.text)
            queryItems.append(familyNameQuery)
        }
        if genderSegment.selectedSegmentIndex == 1 {
            let genderQuery = URLQueryItem(name: "sexId", value: "M")
            queryItems.append(genderQuery)
        }
        if genderSegment.selectedSegmentIndex == 2 {
            let genderQuery = URLQueryItem(name: "sexId", value: "F")
            queryItems.append(genderQuery)
        }
        if countries.countriesList.contains(where: { $0.name == detailNationalityLabel.text }) {
            let nationalityQuery = URLQueryItem(name: "nationality", value: countries.getCountryCode(by: detailNationalityLabel.text!))
            queryItems.append(nationalityQuery)
        }
        if countries.countriesList.contains(where: { $0.name == detailCountryLabel.text }) {
            let countryQuery = URLQueryItem(name: "arrestWarrantCountryId", value: countries.getCountryCode(by: detailCountryLabel.text!))
            queryItems.append(countryQuery)
        }
        searchQuery = queryItems
        print("query = \(queryItems)")
        return queryItems
    }
    
}


extension SearchTableViewController: CountrySelectDelegate, NationSelectDelegate {
    func didSelectNation(country: String) {
        selectedNationality = country
    }
    
    func didSelectCountry(country: String) {
        selectedCountry = country
    }
}
