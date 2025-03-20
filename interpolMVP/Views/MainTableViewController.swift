//
//  MainTableViewController.swift
//  interpol3
//
//  Created by Andy Kefir on 06/03/2025.
//

import UIKit

class MainTableViewController: UITableViewController, MainViewProtocol {
    private let myBlueColor = #colorLiteral(red: 0, green: 0.1617512107, blue: 0.4071177244, alpha: 1)
    
    var presenter: MainPresenter!
    let countries = Countries()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MainPresenter(view: self)
        configureView()
        setHeader(totalNotices: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadNotices()
    }
    
    // MARK: - UI Configuration
    func configureView() {
        title = "INTERPOL"
        navigationController?.navigationBar.barTintColor = myBlueColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                            target: self,
                                                            action: #selector(openSearchVC))
        
        let redNoticeView = UIImageView(image: UIImage(named: "redNotice"))
        redNoticeView.contentMode = .scaleAspectFit
        redNoticeView.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: redNoticeView)
        NSLayoutConstraint.activate([
            redNoticeView.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        let backgroundImage = UIImageView(frame: self.tableView.bounds)
        backgroundImage.image = UIImage(named: "fon2")
        backgroundImage.contentMode = .scaleAspectFill
        self.tableView.backgroundView = backgroundImage
        tableView.rowHeight = 160
    }
    
    // MARK: - MainViewProtocol Methods
    func setHeader(totalNotices: Int?) {
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30)
        headerLabel.backgroundColor = .clear
        if let total = totalNotices {
            headerLabel.text = "\(total) persons found"
        } else {
            headerLabel.text = "searching..."
        }
        headerLabel.textAlignment = .center
        tableView.tableHeaderView = headerLabel
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
    
    func showError(_ error: Error) {
        print("Error: \(error)")
    }
    
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfNotices()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath)
        
        if let notice = presenter.notice(at: indexPath.row) {
            cell.textLabel?.text = "\(notice.name ?? "")\n\(notice.forename ?? "")"
            let ageString = presenter.calculateAge(from: notice.dateOfBirth)
            cell.detailTextLabel?.text = "\(ageString)\n\(countries.getCountryName(by: notice.nationalities?.first ?? ""))"
        }
        
        if let data = presenter.imageData(at: indexPath.row), let image = UIImage(data: data) {
            cell.imageView?.image = image
        } else {
            cell.imageView?.image = UIImage(named: "noPhoto")
        }
        
        cell.imageView?.layer.cornerRadius = 10
        cell.imageView?.layer.borderColor = myBlueColor.cgColor
        cell.imageView?.layer.borderWidth = 1
        cell.imageView?.contentMode = .scaleAspectFill
        
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = myBlueColor
        cell.detailTextLabel?.textColor = .black
        
        cell.imageView?.translatesAutoresizingMaskIntoConstraints = false
        cell.textLabel?.translatesAutoresizingMaskIntoConstraints = false
        cell.detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cell.imageView!.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            cell.imageView!.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20),
            cell.imageView!.widthAnchor.constraint(equalToConstant: 100),
            cell.imageView!.heightAnchor.constraint(equalToConstant: 120),
            cell.textLabel!.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 150),
            cell.textLabel!.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -30),
            cell.textLabel!.topAnchor.constraint(equalTo: cell.topAnchor, constant: 30),
            cell.detailTextLabel!.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 150),
            cell.detailTextLabel!.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -30),
            cell.detailTextLabel!.topAnchor.constraint(lessThanOrEqualTo: cell.textLabel!.bottomAnchor, constant: 20),
            cell.detailTextLabel!.bottomAnchor.constraint(greaterThanOrEqualTo: cell.bottomAnchor, constant: -30)
        ])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetailVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC",
           let detailVC = segue.destination as? DetailTableViewController,
           let indexPath = tableView.indexPathForSelectedRow,
           let selectedNotice = presenter.notice(at: indexPath.row) {
            let personIDString = selectedNotice.entityID.replacingOccurrences(of: "/", with: "-")
            let detailPresenter = DetailPresenter(view: detailVC)
            detailPresenter.personID = personIDString
            detailVC.presenter = detailPresenter
        }
    }
    
    
    // MARK: - User Actions
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            presenter.loadNotices()
        }
    }
    
    @objc func openSearchVC() {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: "searchVC") as! SearchTableViewController
        navigationController?.pushViewController(searchVC, animated: true)
        presenter.resetData()
    }
}
