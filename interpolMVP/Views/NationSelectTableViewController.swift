//
//  NationSelectTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 08/03/2025.
//

import UIKit

protocol NationSelectDelegate: AnyObject {
    func didSelectNation(_ nation: String)
}

class NationSelectTableViewController: UITableViewController, UISearchResultsUpdating {
    
    weak var delegate: NationSelectDelegate?
    var searchPresenter: SearchPresenter!
    private var filteredNations: [String] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if searchPresenter == nil {
            searchPresenter = SearchPresenter()
        }
        filteredNations = searchPresenter.filterCountries(with: "")
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Nation"
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filteredNations = searchPresenter.filterCountries(with: searchText)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source & delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nationCell", for: indexPath)
        cell.textLabel?.text = filteredNations[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedNation = filteredNations[indexPath.row]
        searchPresenter.updateNationality(selectedNation)
        delegate?.didSelectNation(selectedNation)
        navigationController?.popViewController(animated: true)
    }
}
