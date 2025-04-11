//
//  CountrySelectTableViewController.swift
//  Interpol MVP
//
//  Created by Andy Kefir on 11/04/2025.
//

import UIKit

protocol CountrySelectDelegate: AnyObject {
    func didSelectCountry(_ country: String)
}

class CountrySelectTableViewController: UITableViewController, UISearchResultsUpdating {
    
    weak var delegate: CountrySelectDelegate?
    var searchPresenter: SearchPresenter!
    private var filteredCountries: [String] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        if searchPresenter == nil {
            searchPresenter = SearchPresenter()
        }
        filteredCountries = searchPresenter.filterCountries(with: "")
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Country"
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filteredCountries = searchPresenter.filterCountries(with: searchText)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath)
        cell.textLabel?.text = filteredCountries[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCountry = filteredCountries[indexPath.row]
        searchPresenter.updateCountry(selectedCountry)
        delegate?.didSelectCountry(selectedCountry)
        navigationController?.popViewController(animated: true)
    }
}
