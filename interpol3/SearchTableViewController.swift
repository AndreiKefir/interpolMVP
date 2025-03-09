//
//  SearchTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 07/03/2025.
//

import UIKit

class SearchTableViewController: UITableViewController, UITextFieldDelegate {
    
    var cells: [(String, String)] = [
        ("forename", ""),
        ("familyName", ""),
        ("Gender", ""),
        ("byCountry", "")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tapGesture)

    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Forename"
        case 1: return "Family name"
        case 2: return "Gender"
        case 3: return "Nationality"
        case 4: return "Wanted by"
        default: return ""
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
    
        switch indexPath.section {
        case 0, 1:
            let textfield = UITextField()
            textfield.borderStyle = .roundedRect
            textfield.returnKeyType = .search
            textfield.delegate = self
            if indexPath.row == 0 {
                textfield.placeholder = "Forename"
            } else {
                textfield.placeholder = "Family name"
            }
            textfield.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(textfield)
            
            NSLayoutConstraint.activate([
                textfield.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                textfield.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                textfield.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 30),
                textfield.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -30)
            ])
            return cell
        case 2:
            let genderSegment = UISegmentedControl()
            genderSegment.insertSegment(withTitle: "All", at: 0, animated: true)
            genderSegment.insertSegment(withTitle: "Male", at: 1, animated: true)
            genderSegment.insertSegment(withTitle: "Female", at: 2, animated: true)
            genderSegment.selectedSegmentIndex = 0
            cell.contentView.addSubview(genderSegment)
            genderSegment.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                genderSegment.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                genderSegment.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                genderSegment.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 30),
                genderSegment.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -30)
            ])
        case 3:
            cell.detailTextLabel?.text = "Some detail"
            cell.textLabel?.text = "Nation"
            cell.textLabel?.textAlignment = .center
            cell.accessoryType = .disclosureIndicator
        case 4:
            cell.textLabel?.text = "Country"
            cell.textLabel?.textAlignment = .center
            cell.accessoryType = .disclosureIndicator
        default:
            break
        }
            
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 || indexPath.section == 4 {
            let listVC = storyboard?.instantiateViewController(withIdentifier: "listVC") as! ListSearchTableViewController
            navigationController?.pushViewController(listVC, animated: true)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
