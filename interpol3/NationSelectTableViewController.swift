//
//  ListSearchTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 08/03/2025.
//

import UIKit

protocol NationSelectDelegate: AnyObject {
    func didSelectNation(country: String)
}

class NationSelectTableViewController: UITableViewController {
    weak var delegate: NationSelectDelegate?
    
    var countryList = [String]()
    let countries = Countries()
    var numberOfSelectedCell = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryList = countries.countriesList.map { $0.0 }
        //    countriesList.map { $0.0 }
        
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        cell.textLabel?.text = countryList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        if numberOfSelectedCell == indexPath.row {
            selectedCell?.accessoryType = .none
        } else {
            numberOfSelectedCell = indexPath.row
            selectedCell?.accessoryType = .checkmark
        }
        
        delegate?.didSelectNation(country: countryList[indexPath.row])
        navigationController?.popViewController(animated: true)
        
        //        let searchVC = storyboard?.instantiateViewController(withIdentifier: "searchVC") as! SearchTableViewController
        //        searchVC.selectedNationality = countryList[indexPath.row]
        //        print("selected \(searchVC.selectedNationality)")
        //        navigationController?.popViewController(animated: true)
        //    }
        


        //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        <#code#>
        //    }
    }
    
}
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let searchVC = segue.destination as! SearchTableViewController
//        let searchVC = storyboard?.instantiateViewController(withIdentifier: "searchVC") as! SearchTableViewController
//        searchVC.selectedNationality = countryList[numberOfSelectedCell]
//    }



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

