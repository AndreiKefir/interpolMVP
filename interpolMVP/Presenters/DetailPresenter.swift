//
//  DetailPresenter.swift
//  interpolMVP
//
//  Created by Andy Kefir on 23/03/2025.
//

import Foundation

protocol DetailViewProtocol: AnyObject {
    func updateView()
    func showError(_ error: Error)
}

class DetailPresenter {
    
    weak var view: DetailViewProtocol?
    
    private(set) var person: PersonNotice?
    private(set) var imagesData: [Data] = []
    private(set) var showData: [[(String?, String?)]] = [[], [], []]
    
    private let network: Network
    private let countries: Countries
    var personID: String = ""
    
    init(view: DetailViewProtocol,
         network: Network = Network.shared,
         countries: Countries = Countries()) {
        self.view = view
        self.network = network
        self.countries = countries
    }
    
    func loadDetail() {
        Task {
            do {
                let personData = try await network.fetchPersonData(from: personID)
                self.person = personData
                
                var imageStrings: [String] = []
                if let imagesLink = personData.links.images?.href {
                    let resultImages = try await network.fetchPersonImages(from: imagesLink)
                    imageStrings = resultImages.embedded.images.map { $0.links.linksSelf.href }
                    for imageString in imageStrings {
                        if let imageData = try await network.fetchImageData(from: imageString) {
                            self.imagesData.append(imageData)
                        }
                    }
                }

                self.prepareShowData()
                await updateViewOnMainThread()
            } catch {
                await showErrorOnMainThread(error)
            }
        }
    }
    
    private func prepareShowData() {
        showData = [[], [], []]
        
        guard let person = self.person else { return }
        
        // Section 0: Identity particulars
        showData[0].append(("Family name", person.name ?? "No name"))
        showData[0].append(("Forename", person.forename ?? "No forename"))
        if let gender = person.sexID {
            let genderString = (gender == "M") ? "Male" : "Female"
            showData[0].append(("Gender", genderString))
        }
        showData[0].append(("Date of birth", person.dateOfBirth ?? "No date"))
        if let place = person.placeOfBirth {
            showData[0].append(("Place of birth", place))
        }
        if let nations = person.nationalities {
            let nationsArray = nations.map { countries.getCountryName(by: $0) }
            showData[0].append(("Nationality", nationsArray.joined(separator: ", ")))
        }
        if let languages = person.languagesSpokenIDS {
            let languagesString = languages.joined(separator: ", ")
            showData[0].append(("Language(s) spoken", languagesString))
        }
        
        // Section 1: Physical description
        if let height = person.height, height != 0 {
            showData[1].append(("Height", "\(height) meters"))
        }
        if let weight = person.weight, weight != 0 {
            showData[1].append(("Weight", "\(weight) kilograms"))
        }
        if let hairs = person.hairsID {
            let hairsString = hairs.joined(separator: ", ")
            showData[1].append(("Color of hair", hairsString))
        }
        if let eyes = person.eyesColorsID {
            let eyesString = eyes.joined(separator: ", ")
            showData[1].append(("Color of eyes", eyesString))
        }
        
        // Section 2: Charges
        if let warrant = person.arrestWarrants.first {
            let countryName = countries.getCountryName(by: warrant.issuingCountryID ?? "UK")
            showData[2].append(("Wanted by", countryName))
            showData[2].append(("Charge", warrant.charge))
        }
    }
    
    // MARK: - UI Updates on Main Thread using @MainActor
    @MainActor private func updateViewOnMainThread() {
        view?.updateView()
    }
    
    @MainActor private func showErrorOnMainThread(_ error: Error) {
        view?.showError(error)
    }
    
    // Accessor methods for the view (table view data source)
    func numberOfSections() -> Int {
        return showData.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        guard section < showData.count else { return 0 }
        return showData[section].count
    }
    
    func dataPair(for indexPath: IndexPath) -> (String?, String?) {
        return showData[indexPath.section][indexPath.row]
    }
}
