//
//  DetailTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import UIKit

class DetailTableViewController: UITableViewController {
    let myBlueColor = #colorLiteral(red: 0, green: 0.1617512107, blue: 0.4071177244, alpha: 1)
    var countries = Countries()
    var imagesString = [String]()
    var images = [UIImage]()
    var person: PersonNotice?
    var personID: String = ""
    var showData = [[(String?, String?)](),[(String?, String?)](),[(String?, String?)]()]
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createHeaderView()
        getPersonInfo()
    
    }
    
    func getPersonInfo() {
        Task {
            do {
                let personData = try await Network.shared.fetchPersonData(from: personID)
                person = personData
                guard let imagesLink = person?.links.images?.href else { return }
                    let resultImages = try await Network.shared.fetchPersonImages(from: imagesLink)
                for image in resultImages.embedded.images {
                    imagesString.append(image.links.linksSelf.href)
                }
                for imageString in imagesString {
                    if let imageData = try await Network.shared.fetchImageData(from: imageString) {
                        images.append(UIImage(data: imageData)!)
                    }
                }
                
                showData[0].append(("Family name", person?.name ?? "No name"))
                showData[0].append(("Forename", person?.forename ?? "No forename"))
                if let gender = person?.sexID {
                    if gender == "M" {
                        showData[0].append(("Gender", "Male"))
                    } else {
                        showData[0].append(("Gender", "Female"))
                    }
                }
                showData[0].append(("Date of birth", person?.dateOfBirth ?? "No date"))
                if person?.placeOfBirth != nil {
                    showData[0].append(("Place of birth", person?.placeOfBirth))
                }
                if let haveNations = person?.nationalities {
                    let nationsArray = haveNations.map { countries.getCountryName(by: $0) }
                    showData[0].append(("Nationality", nationsArray.joined(separator: ", ")))
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
                    let hairsString = person?.hairsID?.joined(separator: ", ")
                    showData[1].append(("Color of hair", hairsString))
                }
                if let eyesColors = person?.eyesColorsID {
                    let eyesString = eyesColors.joined(separator: ", ")
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
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        let imageVC = ImageViewController()
        imageVC.image = tappedImageView.image
        
        if let popoverController = imageVC.popoverPresentationController {
            popoverController.sourceView = self.tableView.tableHeaderView
        }
        
        self.present(imageVC, animated: true)
    }
    
    func createHeaderView() {
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 160))
        tableView.tableHeaderView?.backgroundColor = myBlueColor
    
        //stackView
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        //add images to stackView
        for image in images {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            stackView.addArrangedSubview(imageView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            imageView.addGestureRecognizer(tapGesture)
        }
        
        tableView.tableHeaderView?.addSubview(stackView)
        
        //constraints for stackView
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: tableView.tableHeaderView!.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: tableView.tableHeaderView!.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: tableView.tableHeaderView!.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: tableView.tableHeaderView!.bottomAnchor, constant: -10)
        ])
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titleOfSection: String?
    
        switch section {
        case 0: titleOfSection = "Identity particulars"
        case 1: if !showData[1].isEmpty { titleOfSection = "Physical description" }
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
            return 120
        } else { return 44 }
    }
    
}
