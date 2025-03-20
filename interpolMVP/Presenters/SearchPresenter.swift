//
//  SearchPresenter.swift
//  interpolMVP
//
//  Created by Andy Kefir on 24/03/2025.
//

import Foundation

protocol SearchViewProtocol: AnyObject {
    func updateSearchQuery(_ queryItems: [URLQueryItem])
    func updateNationality(_ nationality: String)
    func updateCountry(_ country: String)
}

class SearchPresenter {
    weak var view: SearchViewProtocol?
    
    private(set) var forename: String?
    private(set) var familyName: String?
    private(set) var genderIndex: Int = 0 // 0: All, 1: Male, 2: Female
    private(set) var nationality: String = "All"
    private(set) var country: String = "All"
    
    private let countries: Countries
    
    init(countries: Countries = Countries()) {
        self.countries = countries
    }
    
    func attachView(_ view: SearchViewProtocol) {
        self.view = view
        // Отправляем начальное состояние фильтров
        updateSearchQuery()
    }
    
    // MARK: - Update filter parameters
    func updateForename(_ text: String?) {
        self.forename = text
        updateSearchQuery()
    }
    
    func updateFamilyName(_ text: String?) {
        self.familyName = text
        updateSearchQuery()
    }
    
    func updateGender(_ index: Int) {
        self.genderIndex = index
        updateSearchQuery()
    }
    
    func updateNationality(_ nationality: String) {
        self.nationality = nationality
        view?.updateNationality(nationality)
        updateSearchQuery()
    }
    
    func updateCountry(_ country: String) {
        self.country = country
        view?.updateCountry(country)
        updateSearchQuery()
    }
    
    // MARK: - Generate search query
    private func updateSearchQuery() {
        var queryItems = [URLQueryItem]()
        
        if let forename = forename, !forename.isEmpty {
            queryItems.append(URLQueryItem(name: "forename", value: forename))
        }
        if let familyName = familyName, !familyName.isEmpty {
            queryItems.append(URLQueryItem(name: "name", value: familyName))
        }
        if genderIndex == 1 {
            queryItems.append(URLQueryItem(name: "sexId", value: "M"))
        } else if genderIndex == 2 {
            queryItems.append(URLQueryItem(name: "sexId", value: "F"))
        }
        if nationality != "All" {
            let code = countries.getCountryCode(by: nationality)
            queryItems.append(URLQueryItem(name: "nationality", value: code))
        }
        if country != "All" {
            let code = countries.getCountryCode(by: country)
            queryItems.append(URLQueryItem(name: "arrestWarrantCountryId", value: code))
        }
        
        view?.updateSearchQuery(queryItems)
    }
    
    // Фильтрация списка стран для экранов выбора
    func filterCountries(with searchText: String) -> [String] {
        let allCountries = countries.countriesList.map { $0.0 }
        if searchText.isEmpty {
            return allCountries
        }
        return allCountries.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
}
