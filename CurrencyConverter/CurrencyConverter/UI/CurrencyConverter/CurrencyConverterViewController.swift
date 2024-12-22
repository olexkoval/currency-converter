//
//  CurrencyConverterViewController.swift
//  CurrencyConverter
//
//  Created by Oleksandr Koval on 22.12.2024.
//

import UIKit
import Combine

final class CurrencyConverterViewController: UIViewController {
    
    private let viewModel: CurrencyConverterViewModel
    private var bindings = Set<AnyCancellable>()
    private var textFieldText = ""
    weak var navigationCoordinator: NavigationCoordinator?
    
    private lazy var containerView: UIView = {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 10
        view.addSubview(container)
        
        return container
    }()
    
    private lazy var sourceCurrencyButton: UIButton = {
        let button = Self.createCurrencyButton()
        button.addTarget(self, action: #selector(sourceCurrencyButtonTapped), for: .touchUpInside)
        containerView.addSubview(button)
        
        return button
    }()
    
    private lazy var targetCurrencyButton: UIButton = {
        let button = Self.createCurrencyButton()
        button.addTarget(self, action: #selector(targetCurrencyButtonTapped), for: .touchUpInside)
        containerView.addSubview(button)
        
        return button
    }()
    
    private lazy var sourceAmountLabel: UILabel = {
        let label = Self.createAmountLabel()
        label.textColor = .systemBlue
        label.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sourceAmountLabelTapped))
        label.addGestureRecognizer(tapGestureRecognizer)
        
        containerView.addSubview(label)
        
        return label
    }()
    
    private lazy var targetAmountLabel: UILabel = {
        let label = Self.createAmountLabel()
        containerView.addSubview(label)
        
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(activityIndicator)
        
        return activityIndicator
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.keyboardType = .decimalPad
        textField.textColor = .clear
        
        view.addSubview(textField)
        
        return textField
    }()
    
    init(viewModel: CurrencyConverterViewModel,
         navigationCoordinator: NavigationCoordinator? = nil)
    {
        self.viewModel = viewModel
        self.navigationCoordinator = navigationCoordinator
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray
        
        setupBindings()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onAppear()
    }
}

extension CurrencyConverterViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        textFieldText = ""
        return true
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        var tft = textFieldText
        
        if string.isEmpty {
            _ = tft.popLast()
        }
        else if string == "," {
            tft.append(".")
        }
        else {
            tft.append(string)
        }
        
        if viewModel.isValidAmount(tft) {
            textFieldText = tft
            viewModel.amountChanged(textFieldText)
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.text = textFieldText
    }
}

private extension CurrencyConverterViewController {
    
    func setupConstraints() {
        let salg = view.safeAreaLayoutGuide
        
        let containerViewWidth = containerView.widthAnchor.constraint(equalToConstant: 400)
        containerViewWidth.priority = .defaultHigh
        
        let containerViewHeight = containerView.heightAnchor.constraint(equalToConstant: 200)
        containerViewHeight.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: salg.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: salg.trailingAnchor, constant: -8),
            containerView.centerXAnchor.constraint(equalTo: salg.centerXAnchor),
            containerViewWidth,
            containerViewHeight,
            containerView.bottomAnchor.constraint(equalTo: salg.centerYAnchor),
            containerView.topAnchor.constraint(greaterThanOrEqualTo: salg.topAnchor, constant: 8),
            
            sourceCurrencyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            sourceCurrencyButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            sourceCurrencyButton.bottomAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -8),
            
            sourceAmountLabel.leadingAnchor.constraint(equalTo: sourceCurrencyButton.trailingAnchor, constant: 8),
            sourceAmountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            sourceAmountLabel.centerYAnchor.constraint(equalTo: sourceCurrencyButton.centerYAnchor),
            
            textField.leadingAnchor.constraint(equalTo: sourceAmountLabel.trailingAnchor, constant: 0),
            textField.topAnchor.constraint(equalTo: sourceAmountLabel.topAnchor, constant: 0),
            textField.bottomAnchor.constraint(equalTo: sourceAmountLabel.bottomAnchor, constant: 0),
            textField.widthAnchor.constraint(equalToConstant: 2),
            
            targetCurrencyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            targetCurrencyButton.topAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 8),
            targetCurrencyButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            
            targetAmountLabel.leadingAnchor.constraint(equalTo: targetCurrencyButton.trailingAnchor, constant: 8),
            targetAmountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            targetAmountLabel.centerYAnchor.constraint(equalTo: targetCurrencyButton.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])
    }
    
    func setupBindings() {
        viewModel.currencyConverterPublisher
            .sink(receiveValue: { [weak self] in
                self?.updateUI(viewModelData: $0)
            })
            .store(in: &bindings)
        
        let stateValueHandler: (CurrencyConverterLoadingState) -> Void = { [weak self] state in
            switch state {
            case .loading:
                self?.activityIndicator.startAnimating()
            case .finishedLoading:
                self?.activityIndicator.stopAnimating()
            case .error(let error):
                self?.activityIndicator.stopAnimating()
                self?.navigationCoordinator?.showError(error)
            }
        }
        
        viewModel.loadingStatePublisher
            .sink(receiveValue: stateValueHandler)
            .store(in: &bindings)
    }
    
    func updateUI(viewModelData: CurrencyConverterViewModelData) {
        sourceCurrencyButton.setTitle(viewModelData.sourceCurrency, for: .normal)
        targetCurrencyButton.setTitle(viewModelData.targetCurrency, for: .normal)
        sourceAmountLabel.text = viewModelData.sourceAmount
        targetAmountLabel.text = viewModelData.targetAmount
    }
    
    @objc func sourceCurrencyButtonTapped() {
        textField.resignFirstResponder()
        
        self.navigationCoordinator?.presentCurrencyPicker(for: nil) { [weak self] currencyISOCode in
            if let currencyISOCode {
                self?.viewModel.sourceCurrencyChanged(currencyISOCode)
            }
        }
    }
    
    @objc func targetCurrencyButtonTapped() {
        textField.resignFirstResponder()
        
        self.navigationCoordinator?.presentCurrencyPicker(for: nil) { [weak self] currencyISOCode in
            if let currencyISOCode {
                self?.viewModel.targetCurrencyChanged(currencyISOCode)
            }
        }
    }
    
    @objc func sourceAmountLabelTapped() {
        textField.becomeFirstResponder()
    }
    
    static func createCurrencyButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        return button
    }
    
    static func createAmountLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .right
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return label
    }
}

