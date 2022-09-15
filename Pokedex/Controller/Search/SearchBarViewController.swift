//
//  SearchBarViewController.swift
//  Pokedex
//
//  Created by Tamás Csukás 2022
//

import UIKit

protocol SearchBarViewControllerDelegate {
  func clearFilter()
  func search(for: String?)
  func beginEditing()
  func endEditing()
}

extension SearchBarViewController {
  enum Status {
    case active, inactive
  }
}

class SearchBarViewController: UIViewController, UITextFieldDelegate {
  
  // IBOutlets
  @IBOutlet private weak var searchBarView: UIView!
  @IBOutlet private weak var searchBarTrailingConstraint: NSLayoutConstraint!
  private var searchBarTrailingConstraintConstant: CGFloat = CGFloat(0)
  
  @IBOutlet private weak var searchTextField: UITextField!
  @IBOutlet private weak var searchTextFieldLeadingConstraint: NSLayoutConstraint!
  private var searchTextFieldLeadingConstraintConstant: CGFloat = CGFloat(0)
  
  @IBOutlet private weak var filterLabelView: UIView!
  @IBOutlet private weak var filterLabel: UILabel!
  @IBOutlet private weak var filterLabelViewLeadingConstraint: NSLayoutConstraint!
  
  @IBOutlet private weak var profileImageViewWidth: NSLayoutConstraint!
  private var profileImageViewWidthConstant: CGFloat = CGFloat(0)
  
  // Handle UI actions
  @IBAction private func touchOnFilterLabel(_ sender: Any) {
    setFilter(text: "")
    delegate?.clearFilter()
  }
  
  @IBAction private func searchTextFieldDidChange(_ sender: Any) {
    // Delay search
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.delayedSearch), object: nil)
    self.perform(#selector(self.delayedSearch), with: nil, afterDelay: 0.75)
  }
  
  // Perform the previously delayed search
  @objc private func delayedSearch() {
    delegate?.search(for: searchKeyword)
  }
  
  // MARK: - Properties
  
  var delegate: SearchBarViewControllerDelegate?
  
  // view status (active when the user uses the search bar)
  var status = Status.inactive {
    didSet {
      guard oldValue != status else { return }
      
      switch status {
      case .active:
        delegate?.beginEditing()
        searchBarOnFocusAnimation()
        
      case .inactive:
        delegate?.endEditing()
        searchBarLostFocusAnimation()
      }
    }
  }
  
  // Current search's keyword
  var searchKeyword: String? {
    get {
      if searchTextField.text != nil, !searchTextField.text!.isEmpty {
        return searchTextField.text
      } else {
        return nil
      }
    }
    set { searchTextField.text = newValue }
  }
  
  // MARK: - Funcitons
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    searchTextField.delegate = self
    
    // UI modifications
    searchBarView.layer.borderColor = UIColor.label.cgColor
    searchBarView.layer.borderWidth = 1
    searchBarView.layer.cornerRadius = 18.0
    searchBarView.clipsToBounds = true
    
    searchTextField.borderStyle = .none
    
    filterLabelView.layer.cornerRadius = 3
    filterLabelView.clipsToBounds = true
    
    // UI properties
    searchTextFieldLeadingConstraintConstant = searchTextFieldLeadingConstraint.constant
  }
  
  func setFilter(text: String?, color: UIColor? = nil) {
    if let text = text {
      if text.isEmpty {
        filterLabel.text = ""
        self.view.layoutIfNeeded()
        hideFilterLabelView()
      } else {
        filterLabel.text = text
        self.view.layoutIfNeeded()
        showFilterLabelView()
      }
    }
    
    if let color = color {
      filterLabelView.backgroundColor = color
      self.view.layoutIfNeeded()
    }
  }
  
  // MARK: - Animations
  
  private func searchBarOnFocusAnimation() {
    UIView.animate(withDuration: 0.1) {
      // widen search bar on its right
      self.searchBarTrailingConstraintConstant = self.searchBarTrailingConstraint.constant
      self.profileImageViewWidthConstant = self.profileImageViewWidth.constant
      self.searchBarTrailingConstraint.constant = 0
      self.profileImageViewWidth.constant = 0
      self.view.layoutIfNeeded()
    }
  }
  
  private func searchBarLostFocusAnimation() {
    UIView.animate(withDuration: 0.1) {
      // narros search bar on its right
      self.searchBarTrailingConstraint.constant = self.searchBarTrailingConstraintConstant
      self.profileImageViewWidth.constant = self.profileImageViewWidthConstant
      self.view.layoutIfNeeded()
    }
  }
  
  private func hideFilterLabelView() {
    // widen search bar on its left
    UIView.animate(withDuration: 0.1) {
      self.searchTextFieldLeadingConstraint.constant = self.searchTextFieldLeadingConstraintConstant
      self.view.layoutIfNeeded()
    }
  }
  
  private func showFilterLabelView() {
    // nerrows searh bar on its left
    UIView.animate(withDuration: 0.1) {
      self.searchTextFieldLeadingConstraint.constant = self.filterLabelViewLeadingConstraint.constant + self.filterLabelView.frame.size.width + 6
      self.view.layoutIfNeeded()
    }
  }
  
  // MARK: - UITextFieldDelegate
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    status = .active
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    // cancel ongoing delayed search
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.delayedSearch), object: nil)
    // perform search
    delegate?.search(for: searchKeyword)
    // deactivate the search bar
    status = .inactive
    return true
  }
  
  // MARK: - Nib
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  static func nib() -> UINib {
    return UINib(nibName: "SearchBarViewController", bundle: nil)
  }
  
}

