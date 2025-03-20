//
//  SearchTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 07/03/2025.
//

import UIKit

class SearchTableViewController: UITableViewController, UITextFieldDelegate, SearchViewProtocol {
    
    @IBOutlet weak var forenameTextField: UITextField!
    @IBOutlet weak var familyNameTextField: UITextField!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var detailNationalityLabel: UILabel!
    @IBOutlet weak var detailCountryLabel: UILabel!
    
    var searchPresenter: SearchPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If presenter not injected from outside, create a new instance.
        if searchPresenter == nil {
            searchPresenter = SearchPresenter()
        }
        searchPresenter.attachView(self)
        
        forenameTextField.delegate = self
        familyNameTextField.delegate = self
        
        genderSegment.addTarget(self, action: #selector(genderChanged(_:)), for: .valueChanged)
        
        detailNationalityLabel.text = searchPresenter.nationality
        detailCountryLabel.text = searchPresenter.country
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == forenameTextField {
            searchPresenter.updateForename(textField.text)
        } else if textField == familyNameTextField {
            searchPresenter.updateFamilyName(textField.text)
        }
        textField.resignFirstResponder()
        return true
    }
    
    @objc func genderChanged(_ sender: UISegmentedControl) {
        searchPresenter.updateGender(sender.selectedSegmentIndex)
    }
    
    // MARK: - SearchViewProtocol Methods
    func updateSearchQuery(_ queryItems: [URLQueryItem]) {
        Network.shared.searchQuery = queryItems
        print("Updated search query: \(queryItems)")
    }
    
    func updateNationality(_ nationality: String) {
        detailNationalityLabel.text = nationality
    }
    
    func updateCountry(_ country: String) {
        detailCountryLabel.text = country
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            guard let nationVC = storyboard?.instantiateViewController(withIdentifier: "nationVC") as? NationSelectTableViewController else {
                return
            }
            nationVC.searchPresenter = searchPresenter  // Передаем единый презентер
            nationVC.delegate = self
            navigationController?.pushViewController(nationVC, animated: true)
        }
        if indexPath.section == 4 {
            guard let countryVC = storyboard?.instantiateViewController(withIdentifier: "countryVC") as? CountrySelectTableViewController else {
                return
            }
            countryVC.searchPresenter = searchPresenter  // Передаем единый презентер
            countryVC.delegate = self
            navigationController?.pushViewController(countryVC, animated: true)
        }
    }
}

    
extension SearchTableViewController: NationSelectDelegate, CountrySelectDelegate {
    func didSelectNation(_ nation: String) {
        searchPresenter.updateNationality(nation)
    }
    
    func didSelectCountry(_ country: String) {
        searchPresenter.updateCountry(country)
    }
}
