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
    var selectedCountry = "not selected"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        detailNationalityLabel.text = selectedNationality
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //        view.addGestureRecognizer(tapGesture)
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detailNationalityLabel.text = selectedNationality
        detailCountryLabel.text = selectedCountry
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            let nationVC = storyboard?.instantiateViewController(withIdentifier: "nationVC") as! NationSelectTableViewController
            nationVC.delegate = self
            navigationController?.pushViewController(nationVC, animated: true)
        }
        if indexPath.section == 4 {
            let countryVC = storyboard?.instantiateViewController(withIdentifier: "countryVC") as! CountrySelectTableViewController
            countryVC.delegate = self
            navigationController?.pushViewController(countryVC, animated: true)
        }
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

//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        5
//    }
//    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0: return "Forename"
//        case 1: return "Family name"
//        case 2: return "Gender"
//        case 3: return "Nationality"
//        case 4: return "Wanted by"
//        default: return ""
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        1
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
//    
//        switch indexPath.section {
//        case 0, 1:
//            let textfield = UITextField()
//            textfield.borderStyle = .roundedRect
//            textfield.returnKeyType = .search
//            textfield.delegate = self
//            if indexPath.row == 0 {
//                textfield.placeholder = "Forename"
//            } else {
//                textfield.placeholder = "Family name"
//            }
//            textfield.translatesAutoresizingMaskIntoConstraints = false
//            cell.contentView.addSubview(textfield)
//            
//            NSLayoutConstraint.activate([
//                textfield.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
//                textfield.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
//                textfield.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 30),
//                textfield.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -30)
//            ])
//            return cell
//        case 2:
//            let genderSegment = UISegmentedControl()
//            genderSegment.insertSegment(withTitle: "All", at: 0, animated: true)
//            genderSegment.insertSegment(withTitle: "Male", at: 1, animated: true)
//            genderSegment.insertSegment(withTitle: "Female", at: 2, animated: true)
//            genderSegment.selectedSegmentIndex = 0
//            cell.contentView.addSubview(genderSegment)
//            genderSegment.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                genderSegment.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
//                genderSegment.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
//                genderSegment.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 30),
//                genderSegment.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -30)
//            ])
//        case 3, 4:
//            cell = UITableViewCell(style: .value1, reuseIdentifier: "searchCell")
//            if indexPath.section == 3 {
//                cell.textLabel?.text = "Nationality"
//            } else if indexPath.section == 4 {
//                cell.textLabel?.text = "Country"
//            }
//            cell.detailTextLabel?.text = selectedNationality
//            cell.accessoryType = .disclosureIndicator
//            cell.textLabel?.textAlignment = .center
//        default:
//            break
//        }
//            
//        return cell
//        
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 3 || indexPath.section == 4 {
//            let listVC = storyboard?.instantiateViewController(withIdentifier: "listVC") as! ListSearchTableViewController
//            navigationController?.pushViewController(listVC, animated: true)
//        }
//    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//    }
