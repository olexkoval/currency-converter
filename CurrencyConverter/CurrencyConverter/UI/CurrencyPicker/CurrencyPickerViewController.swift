//
//  CurrencyPickerViewController.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import UIKit

protocol CurrencyPickerViewControllerDelegate: AnyObject {
    func currencyPickerViewController(_ picker: CurrencyPickerViewController, didSelect currencyISOCode: String)
    func currencyPickerViewControllerDidCancel(_ picker: CurrencyPickerViewController)
}

final class CurrencyPickerViewController: UIViewController {
    private let viewModel: CurrencyPickerViewModel
    var selectedCurrencyISOCode: String?
    weak var delegate: CurrencyPickerViewControllerDelegate?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        return tableView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        view.addSubview(searchBar)
        
        return searchBar
    }()
    
    init(viewModel: CurrencyPickerViewModel,
         delegate: CurrencyPickerViewControllerDelegate? = nil,
         selectedCurrencyISOCode: String? = nil)
    {
        self.viewModel = viewModel
        self.selectedCurrencyISOCode = selectedCurrencyISOCode
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchBar.resignFirstResponder()
    }
}

extension CurrencyPickerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        tableView.reloadData()
        
        delegate?.currencyPickerViewControllerDidCancel(self)
    }
}

extension CurrencyPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cellTitle = if shouldShowRecents && indexPath.section == 0 {
            viewModel.recents[indexPath.row]
        } else {
            viewModel.all[indexPath.row]
        }
        
        delegate?.currencyPickerViewController(self, didSelect: cellTitle)
    }
}

extension CurrencyPickerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        shouldShowRecents ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 && shouldShowRecents ? viewModel.recents.count : viewModel.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        let cellTitle = if shouldShowRecents && indexPath.section == 0 {
            viewModel.recents[indexPath.row]
        } else {
            viewModel.all[indexPath.row]
        }
        
        cell.textLabel?.text = cellTitle
        
        if let selectedCurrencyISOCode,
           selectedCurrencyISOCode == cellTitle {
            cell.setSelected(true, animated: false)
        } else {
            cell.setSelected(false, animated: false)
        }
        
        return cell
    }
}

private extension CurrencyPickerViewController {
    var shouldShowRecents: Bool {
        !viewModel.isFiltering && !viewModel.recents.isEmpty
    }
    
    func filterContentForSearchText(_ searchText: String) {
        viewModel.filter = searchText
        tableView.reloadData()
    }
    
    func setupConstraints() {
        let salg = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: salg.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: salg.trailingAnchor),
            searchBar.topAnchor.constraint(equalTo: salg.topAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: salg.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: salg.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: salg.bottomAnchor),
        ])
    }
}
