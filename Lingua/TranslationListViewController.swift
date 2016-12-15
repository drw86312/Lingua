//
//  TranslationListViewController.swift
//  Lingua
//
//  Created by David Warner on 11/22/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit
import SlackTextViewController

struct TranslationTableViewBond: TableViewBond {

    let animated: Bool = false

    func cellForRow(at indexPath: IndexPath,
                    tableView: UITableView,
                    dataSource: Observable2DArray<SectionMetadata, Row>) -> UITableViewCell {

        let rows = dataSource[indexPath.section].items
        var cell = UITableViewCell()

        if let row = rows[indexPath.row] as? LanguageRow,
            let languageCell = tableView.dequeueReusableCell(withIdentifier: InterfaceConstants.Cells.Identifier.languageCell, for: indexPath) as? LanguageCell {
            languageCell.label.text = row.language
            cell = languageCell
        } else if let row = rows[indexPath.row] as? TranslationRow,
            let translationCell = tableView.dequeueReusableCell(withIdentifier: InterfaceConstants.Cells.Identifier.translationCell, for: indexPath) as? TranslationCell {
            translationCell.translatedTextLabel.text = row.translation
            cell = translationCell
        } else if let row = rows[indexPath.row] as? ErrorRow,
            let errorCell = tableView.dequeueReusableCell(withIdentifier: InterfaceConstants.Cells.Identifier.errorCell, for: indexPath) as? ErrorCell {
            errorCell.titleLabel.text = row.error
            cell = errorCell
        }

        return cell
    }

    func titleForHeader(in section: Int, dataSource: Observable2DArray<SectionMetadata, Row>) -> String? {
        return nil
    }

    func titleForFooter(in section: Int, dataSource: Observable2DArray<SectionMetadata, Row>) -> String? {
        return nil
    }
}

class TranslationListViewController: SLKTextViewController {

    var viewModel: TranslationViewModel!
    let tableViewBond = TranslationTableViewBond()

    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .plain
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let tableView = tableView else { return }

        isInverted = false

        // Register Cells
        tableView.register(UINib(nibName: InterfaceConstants.Nibs.translationCell, bundle: nil),
                           forCellReuseIdentifier: InterfaceConstants.Cells.Identifier.translationCell)
        tableView.register(UINib(nibName: InterfaceConstants.Nibs.languageCell, bundle: nil),
                           forCellReuseIdentifier: InterfaceConstants.Cells.Identifier.languageCell)
        tableView.register(UINib(nibName: InterfaceConstants.Nibs.errorCell, bundle: nil),
                           forCellReuseIdentifier: InterfaceConstants.Cells.Identifier.errorCell)

        // Register Headers
        tableView.register(UINib(nibName: InterfaceConstants.Nibs.languageSectionHeader, bundle: nil), forHeaderFooterViewReuseIdentifier: InterfaceConstants.Headers.languageSectionHeader)

        // Configure tableview
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.estimatedSectionHeaderHeight = 30

        // Configure text input view
        textView.placeholder = "Type text to be translated here"
        textInputbar.rightButton.setTitle("Retry", for: .normal)

        // Setup viewModel bindings
        setupViewModelBindings(tableView)
    }

    override func didPressRightButton(_ sender: Any?) {
        // Override implementation to prevent pressing right bar button deleting textview text
    }

    private func setupViewModelBindings(_ tableView: UITableView) {

        // Bind view model data source to tableview
        viewModel.dataSource.bind(to: tableView, using: tableViewBond)

        // Bind input text view to viewModel
        viewModel
            .inputText
            .bind(signal: textView
                .bnd_text
                .toSignal()
                .distinct())
            .disposeIn(bnd_bag)

        // Force-set input text on inputBar button tap -> will force a new translation request
        textInputbar.rightButton
            .bnd_tap
            .observeNext { _ in
                self.viewModel.inputText.value = self.textView.text
            }
            .disposeIn(bnd_bag)

        // Bind selected input language to viewmodel
        let selectedInputLanguage = tableView
            .selectedRow
            .filter { self.viewModel.dataSource.sections[$0.section].metadata.type == .inputLanguage }
            .map { Language.supportedInputLanguages[$0.row] }

        viewModel
            .inputLanguage
            .bind(signal: selectedInputLanguage)
            .disposeIn(bnd_bag)

        // Bind selected output language to viewmodel
        let selectedOutputLanguage = tableView
            .selectedRow
            .filter { self.viewModel.dataSource.sections[$0.section].metadata.type == .outputLanguage }
            .map { Language.supportedOutputLanguages[$0.row] }

        viewModel
            .outputLanguage
            .bind(signal: selectedOutputLanguage)
            .disposeIn(bnd_bag)

        // Hide language selection on cell selection or tableview scroll
        let hideLanguages = tableView.selectedRow.map { _ in false }

        viewModel.shouldDisplayInputLanguage
            .bind(signal: hideLanguages)
            .disposeIn(bnd_bag)

        viewModel.shouldDisplayOutputLanguage
            .bind(signal: hideLanguages)
            .disposeIn(bnd_bag)

        // Forward to -self for implementation of non-reactive delegate functions
        tableView.bnd_delegate.forwardTo = self
    }

//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }

    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        let section = viewModel.dataSource.sections[section]
        if section.metadata.type == .translation || section.metadata.type == .error { return nil }

        print(section.metadata.type)

        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: InterfaceConstants.Headers.languageSectionHeader) as? LanguageSectionHeader else { return nil }

        let tapGesture = ReactiveTapGesture()
        header.backingView.addGestureRecognizer(tapGesture)

        // Add side-effect that dismisses keyboard
        let tapSignal = tapGesture.bnd_tap.doOn(next: { _ in self.view.endEditing(true) })

        if section.metadata.type == .inputLanguage {
            header.leftLabel.text = viewModel.inputLanguage.value.displayValue
            tapSignal
                .observeNext { gesture in
                    self.viewModel.shouldDisplayOutputLanguage.value = false
                    self.viewModel.shouldDisplayInputLanguage.value = !self.viewModel.shouldDisplayInputLanguage.value
                }
                .disposeIn(bnd_bag)
        } else if section.metadata.type == .outputLanguage {
            header.leftLabel.text = viewModel.outputLanguage.value.displayValue
            tapSignal
                .observeNext { gesture in
                    self.viewModel.shouldDisplayInputLanguage.value = false
                    self.viewModel.shouldDisplayOutputLanguage.value = !self.viewModel.shouldDisplayOutputLanguage.value
                }
                .disposeIn(bnd_bag)
        }
        return header
    }
}

