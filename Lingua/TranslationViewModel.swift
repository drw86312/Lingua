//
//  TranslationViewModel.swift
//  Lingua
//
//  Created by David Warner on 11/25/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import LanguageTranslatorV2


typealias SectionMetadata = (Section)

protocol Row { }

struct LanguageRow: Row {
    let language: String
    let isSelected: Bool
}

struct TranslationRow: Row {
    let translation: String
    let wordCount: String
}

struct ErrorRow: Row {
    let error: String
}

func ==(lhs: Section, rhs: Section) -> Bool {
    switch (lhs, rhs) {
    case (.inputLanguage, .inputLanguage): return true
    case (.outputLanguage, .outputLanguage): return true
    case (.translation, .translation): return true
    case (.error, .error): return true
    default: return false
    }
}

enum Section: Equatable {

    case error
    case inputLanguage
    case outputLanguage
    case translation

    var headerTitle: String? {
        switch self {
        case .error:
            return nil
        case .inputLanguage:
            return nil
        case .outputLanguage:
            return nil
        case .translation:
            return nil
        }
    }

    var footerTitle: String? {
        switch self {
        case .error:
            return nil
        case .inputLanguage:
            return nil
        case .outputLanguage:
            return nil
        case .translation:
            return nil
        }
    }

    var metaData: SectionMetadata {
        return (type: self)
    }
}

class TranslationViewModel {

    typealias viewModel = TranslationViewModel

    // Input
    let inputText = Observable<String?>("")
    let inputLanguage = Observable<Language>(.none)
    let confidence = Observable<Double>(0.0)

    // Output
    let translationResult = Observable<TranslateResponse>(TranslateResponse())
    let outputLanguage = Observable<Language>(.spanish)

    // Actions
    let shouldDisplayInputLanguage = Observable<Bool>(false)
    let shouldDisplayOutputLanguage = Observable<Bool>(false)

    // Errors
    let translationError = PublishSubject<LinguaError, NoError>()

    // Disposable
    let disposeBag = DisposeBag()

    // Data source
    let datasource: MutableObservable2DArray<SectionMetadata, Row>

    // Constants
    let throttleDuration = 0.5

    init() {

        datasource = MutableObservable2DArray(
            [viewModel.errorSection(.none),
             viewModel.inputLanguageSection(.none),
             viewModel.outputLanguageSection(.none, inputLanguage: inputLanguage.value),
             viewModel.translationSection(TranslateResponse())])

        // Derive input language from user input text
        let fetchLanguage = inputText
            .throttle(seconds: throttleDuration)
            .flatMapLatest { text -> Signal<[IdentifiedLanguage], LinguaError> in
                return API.identifyLanguageFrom(text: text)
            }
            .suppressError(logging: true)

        confidence
            .bind(signal: fetchLanguage.map { $0.first?.confidence ?? 0.0 })
            .disposeIn(disposeBag)

        let toLanguageEnum = fetchLanguage
            .map { languages -> Language in
                guard let language = languages.first else {
                    return .none
                }
                return language.enumValue
            }
            .distinct()

        // Bind signal value to inputLanguage property
        inputLanguage
            .bind(signal: toLanguageEnum)
            .disposeIn(disposeBag)

        // Translate input text
        let translationSignal =
            combineLatest(inputText,
                          inputLanguage,
                          outputLanguage)
                .throttle(seconds: throttleDuration)
                .flatMapLatest { tuple -> Signal<TranslateResponse, NoError> in
                    let inputText = tuple.0
                    let inputLanguage = tuple.1
                    let outputLanguage = tuple.2
                    return API.translate(text: inputText,
                                         from: inputLanguage,
                                         to: outputLanguage)
                        .suppressAndFeedError(into: self.translationError, logging: true)
        }

        translationSignal.observeNext { _ in
            self.translationError.next(.none)
        }

        translationError
            .distinct()
            .observeNext { error in
               self.replaceSectionOf(type: .error, withSection: viewModel.errorSection(error))
        }
            .disposeIn(disposeBag)

        // Bind signal value to translationResult property
        translationResult
            .bind(signal: translationSignal)
            .disposeIn(disposeBag)

        translationResult
            .observeNext { response in
                self.replaceSectionOf(type: .translation, withSection: viewModel.translationSection(response))
        }
            .disposeIn(disposeBag)

        shouldDisplayInputLanguage
            .distinct()
            .observeNext { showRows in
                self.replaceSectionOf(type: .inputLanguage,
                                      withSection: viewModel.inputLanguageSection(self.inputLanguage.value,
                                                                                  rowsVisible: showRows))
            }
            .disposeIn(disposeBag)

        shouldDisplayOutputLanguage
            .distinct()
            .observeNext { showRows in
                self.replaceSectionOf(type: .outputLanguage,
                                      withSection: viewModel.outputLanguageSection(self.outputLanguage.value,
                                                                                   inputLanguage: self.inputLanguage.value,
                                                                                   rowsVisible: showRows))
            }
            .disposeIn(disposeBag)
    }

    func replaceSectionOf(type: Section, withSection: Observable2DArraySection<SectionMetadata, Row>) {
        guard let index = indexOfSection(type: type) else { return }
        datasource.batchUpdate { datasource in
            datasource.removeSection(at: index)
            datasource.insert(section: withSection, at: index)
        }
    }

    func indexOfSection(type: Section) -> Int? {
        guard let index = self.datasource.sections.index(where: { $0.metadata == type }) else { return nil }
        return index
    }

    static func errorSection(_ error: LinguaError) -> Observable2DArraySection<SectionMetadata, Row> {
        var rows: [ErrorRow] {
            switch error {
            case .network:
                return [ErrorRow(error: "Error: could not translate input")]
            case .none:
                return []
            }
        }
        return Observable2DArraySection<SectionMetadata, Row>(
            metadata: Section.error.metaData,
            items: rows)
    }

    static func translationSection(_ response: TranslateResponse) -> Observable2DArraySection<SectionMetadata, Row> {
        let row = TranslationRow(translation: response.translations.first?.translation ?? "",
                                 wordCount: "\(response.wordCount)")
        return Observable2DArraySection<SectionMetadata, Row>(
            metadata: Section.translation.metaData,
            items: [row])
    }

    static func inputLanguageSection(_ selectedLanguage: Language,
                                     rowsVisible: Bool = false) -> Observable2DArraySection<SectionMetadata, Row> {
        let rows = rowsVisible ? Language.supportedInputLanguages
            .map { LanguageRow(language: $0.displayValue, isSelected: $0 == selectedLanguage) } : []
        return Observable2DArraySection<SectionMetadata, Row>(
            metadata: Section.inputLanguage.metaData,
            items: rows)
    }

    static func outputLanguageSection(_ selectedLanguage: Language,
                                      inputLanguage: Language,
                                      rowsVisible: Bool = false) -> Observable2DArraySection<SectionMetadata, Row> {
        let rows = rowsVisible ? inputLanguage.supportedOutputLanguages
            .map { LanguageRow(language: $0.displayValue, isSelected: $0 == selectedLanguage) } : []
        return Observable2DArraySection<SectionMetadata, Row>(
            metadata: Section.outputLanguage.metaData,
            items: rows)
    }
}
