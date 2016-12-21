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

struct BondDataSource: DataSourceProtocol {

    let observableArray: MutableObservable2DArray<SectionMetadata, Row>

    var numberOfSections: Int {
        return observableArray.sections.count
    }

    func numberOfItems(inSection section: Int) -> Int {
        return observableArray.sections[section].items.count
    }
}

class TranslationListViewController: SLKTextViewController {

    let viewModel = TranslationViewModel()

    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .plain
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        isInverted = false

        guard let tableView = tableView else { return }

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
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50

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

        viewModel.datasource.bind(to: tableView, animated: false) { datasource, indexpath, tableview -> UITableViewCell in
            let rows = datasource[indexpath.section].items
            var cell = UITableViewCell()

            if let row = rows[indexpath.row] as? LanguageRow,
                let languageCell = tableView.dequeueReusableCell(withIdentifier: InterfaceConstants.Cells.Identifier.languageCell, for: indexpath) as? LanguageCell {
                languageCell.label.text = row.language
                cell = languageCell
            } else if let row = rows[indexpath.row] as? TranslationRow,
                let translationCell = tableView.dequeueReusableCell(withIdentifier: InterfaceConstants.Cells.Identifier.translationCell, for: indexpath) as? TranslationCell {
                translationCell.translatedTextLabel.text = row.translation
                cell = translationCell
            } else if let row = rows[indexpath.row] as? ErrorRow,
                let errorCell = tableView.dequeueReusableCell(withIdentifier: InterfaceConstants.Cells.Identifier.errorCell, for: indexpath) as? ErrorCell {
                errorCell.titleLabel.text = row.error
                cell = errorCell
            }
            return cell
        }

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
            .filter { self.viewModel.datasource.sections[$0.section].metadata == .inputLanguage }
            .map { Language.supportedInputLanguages[$0.row] }
            .doOn(next: { _ in
                self.viewModel.confidence.value = 1
            })

        viewModel
            .inputLanguage
            .bind(signal: selectedInputLanguage)
            .disposeIn(bnd_bag)

        // Bind selected output language to viewmodel
        // Set selected output language to .none if input language changes and current output language not supported
        let selectOutputLanguage = tableView
            .selectedRow
            .filter { self.viewModel.datasource.sections[$0.section].metadata == .outputLanguage }
            .map { self.viewModel.inputLanguage.value.supportedOutputLanguages[$0.row] }

        let selectInputLanguage = viewModel
            .inputLanguage
            .map { $0.supportedOutputLanguages.contains(self.viewModel.outputLanguage.value) ? self.viewModel.outputLanguage.value : .none }

        let mergedOutputLanguage = selectOutputLanguage.merge(with: selectInputLanguage)

        viewModel
            .outputLanguage
            .bind(signal: mergedOutputLanguage)
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

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = viewModel.datasource.sections[section]
        if section.metadata == .translation || section.metadata == .error { return 0 }
        return 50
    }

    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        let section = viewModel.datasource.sections[section]
        if section.metadata == .translation || section.metadata == .error { return UIView() }

        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: InterfaceConstants.Headers.languageSectionHeader) as? LanguageSectionHeader else { return nil }

        let tapGesture = ReactiveTapGesture()
        header.backingView.addGestureRecognizer(tapGesture)

        // Add side-effect that dismisses keyboard
        let tapSignal = tapGesture.bnd_tap.doOn(next: { _ in self.view.endEditing(true) })

        if section.metadata == .inputLanguage {
            header.leftLabel.text = viewModel.inputLanguage.value.displayValue
            header.rightLabel.text = viewModel.confidence.value.percentageString
            tapSignal
                .observeNext { gesture in
                    self.viewModel.shouldDisplayOutputLanguage.value = false
                    self.viewModel.shouldDisplayInputLanguage.value = !self.viewModel.shouldDisplayInputLanguage.value
                }
                .disposeIn(bnd_bag)
        } else if section.metadata == .outputLanguage {
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

