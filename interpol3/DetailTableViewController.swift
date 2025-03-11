//
//  DetailTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import UIKit

class DetailTableViewController: UITableViewController {
    var countries = Countries()
    var imagesString = [String]()
    var imagesData = [UIImage]()
    var person: PersonNotice?
    var personID: String = ""
    var showData = [[(String?, String?)](),[(String?, String?)](),[(String?, String?)]()]
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createHeaderView()
        getPersonInfo()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 20
        tableView.rowHeight = UITableView.automaticDimension
    
    }
    
    
    func getPersonInfo() {
        Task {
            do {
                let result = try await NetworkManager.shared.getPerson(by: personID)
                person = result
//                print("!!! \(personID)")
                guard let imagesLink = person?.links.images?.href else { return }
                    let resultImages = try await NetworkManager.shared.getPersonImages(by: imagesLink)
                for image in resultImages.embedded.images {
                    imagesString.append(image.links.linksSelf.href)
                }
                for imageString in imagesString {
                    let imageData = try await NetworkManager.shared.getImageNow(by: imageString)
                    imagesData.append(UIImage(data: imageData)!)
                }
                
                showData[0].append(("Family name", person?.name ?? "No name"))
                showData[0].append(("Forename", person?.forename ?? "No forename"))
                showData[0].append(("Gender", person?.sexID ?? "No gender"))
                showData[0].append(("Date of birth", person?.dateOfBirth ?? "No date"))
                if person?.placeOfBirth != nil {
                    showData[0].append(("Place of birth", person?.placeOfBirth))
                }
                if let haveNations = person?.nationalities {
                    var resultString = ""
                    var nationsArray = []
                    for nation in haveNations {
                        nationsArray.append(Locale.current.localizedString(forRegionCode: nation)!)
                    }
                    let separator = ", "
                    for (index, element) in nationsArray.enumerated() {
                        if index > 0 {
                            resultString += separator
                        }
                        resultString += element as! String
                    }
                    showData[0].append(("Nationality", resultString))
                }
                if person?.languagesSpokenIDS != nil {
                    let languagesString = person?.languagesSpokenIDS?.joined(separator: ", ")
                    showData[0].append(("Language(s) spoken", languagesString))
                }
                if person?.height != nil && person?.height != 0 {
                    showData[1].append(("Height", "\(String((person?.height)!)) meters"))
                }
                if person?.weight != nil && person?.weight != 0 {
                    showData[1].append(("Weight", "\(String((person?.weight)!)) kilograms"))
                }
                if person?.hairsID != nil {
                    let hairsString = person?.hairsID?.joined(separator: ",")
                    showData[1].append(("Color of hair", hairsString))
                }
                if let eyesColors = person?.eyesColorsID {
                    let eyesString = eyesColors.joined(separator: ",")
                    showData[1].append(("Color of eyes", eyesString))
                }
                if let warrants = person?.arrestWarrants.first {
                    showData[2].append(("Wanted by", countries.getCountryName(by: warrants.issuingCountryID ?? "UK")))
                    showData[2].append(("Charge", warrants.charge))
                }
                
            } catch NetworkError.invalidUrl {
                print("invalid URL")
            } catch NetworkError.invalidData {
                print("invalid Data")
            } catch NetworkError.invalidResponse {
                print("invalid response")
            }
            tableView.reloadData()
            createHeaderView()
        }
    }
    
    
    func createHeaderView() {
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 160))
        tableView.tableHeaderView?.backgroundColor = .systemBlue
    
        //stackView
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        //add images to stackView
        for image in imagesData {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(imageView)
        }
        
        tableView.tableHeaderView?.addSubview(stackView)
        
        //constraints for stackView
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: tableView.tableHeaderView!.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: tableView.tableHeaderView!.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: tableView.tableHeaderView!.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: tableView.tableHeaderView!.bottomAnchor, constant: -10)
        ])
        
//        tableView.reloadData()
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titleOfSection: String?
    
        switch section {
        case 0: titleOfSection = "Identity particulars"
        case 1: titleOfSection = "Physical description"
        case 2: titleOfSection = "Charges"
        default: break
        }
        return titleOfSection
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        showData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showData[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        
        cell.textLabel!.text = showData[indexPath.section][indexPath.row].0
        cell.detailTextLabel?.text = showData[indexPath.section][indexPath.row].1
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 1 {
            return 100
        } else { return 44 }
    }
    
}

    
    
//  search button
//    search() {
          //hide seearch controller
//        dismiss(animated: true, completion: nil)
//          udate viewController
//    }
