//
//  DetailTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import UIKit

class DetailTableViewController: UITableViewController, DetailViewProtocol {
    
    let myBlueColor = #colorLiteral(red: 0, green: 0.1617512107, blue: 0.4071177244, alpha: 1)
    var presenter: DetailPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        presenter.view = self
        presenter.loadDetail()
    }
    
    func configureView() {
        title = "Detail"
        tableView.rowHeight = 44
        tableView.backgroundColor = .white
    }
    
    // MARK: - DetailViewProtocol Methods
    func updateView() {
        tableView.reloadData()
        createHeaderView()
    }
    
    func showError(_ error: Error) {
        print("Error: \(error)")
    }
    
    func createHeaderView() {
        let headerHeight: CGFloat = 160
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerHeight))
        headerView.backgroundColor = myBlueColor
        
        // Create a horizontal stack view.
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // For each image data from the presenter, convert it to UIImage.
        for imageData in presenter.imagesData {
            if let image = UIImage(data: imageData) {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageView.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                imageView.addGestureRecognizer(tapGesture)
                stackView.addArrangedSubview(imageView)
            }
        }
        
        headerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        let imageVC = ImageViewController()
        imageVC.image = tappedImageView.image
        
        if let popoverController = imageVC.popoverPresentationController {
            popoverController.sourceView = tableView.tableHeaderView
        }
        present(imageVC, animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Identity particulars"
        case 1:
            return presenter.numberOfRows(in: 1) > 0 ? "Physical description" : nil
        case 2:
            return "Charges"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell") ??
                   UITableViewCell(style: .subtitle, reuseIdentifier: "detailCell")
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        
        let dataPair = presenter.dataPair(for: indexPath)
        cell.textLabel?.text = dataPair.0
        cell.detailTextLabel?.text = dataPair.1
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 1 {
            return 160
        }
        return 44
    }
}
