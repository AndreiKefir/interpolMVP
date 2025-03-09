//
//  CountrySelectTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 11/03/2025.
//

import UIKit

protocol CountrySelectDelegate: AnyObject {
    func didSelectCountry(country: String)
}

class CountrySelectTableViewController: UITableViewController {
    weak var delegate: CountrySelectDelegate?

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
        countryList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        cell.textLabel?.text = countryList[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCountry(country: countryList[indexPath.row])
        navigationController?.popViewController(animated: true)
    }

}
