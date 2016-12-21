//
//  Router.swift
//  Lingua
//
//  Created by David Warner on 11/24/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import Alamofire
import LanguageTranslatorV2
import ReactiveKit

enum LinguaError: Error, Equatable {
    case network(String)
    case none

    static func ==(lhs: LinguaError, rhs: LinguaError) -> Bool {
        switch (lhs, rhs) {
        case (.network, .network): return true
        case (.none, .none): return true
        default: return false
        }
    }
}

struct API {

    static let username = "a8ef87d9-4749-485c-a8b4-931a5f6c8dc1"
    static let password = "uTNtwN0gnGvm"
    static let translator = LanguageTranslator(username: username, password: password)

    static func fetchIdentifiableLanguages() -> Signal<[IdentifiableLanguage], LinguaError> {
        return Signal<[IdentifiableLanguage], LinguaError> { observer in
            translator.getIdentifiableLanguages(failure: { error in
                observer.failed(.network(error.localizedDescription))
            }, success: { identifiableLanguages in
                observer.completed(with: identifiableLanguages)
            })
            return DisposeBag()
        }
    }

    static func identifyLanguageFrom(text: String?) -> Signal<[IdentifiedLanguage], LinguaError> {
        return Signal<[IdentifiedLanguage], LinguaError> { observer in
            if let text = text, text.characters.count > 0 {
                translator.identify(languageOf: text,
                                    failure: { error in
                                        observer.failed(.network(error.localizedDescription))
                }) { identifiedLanguages in
                    observer.completed(with: identifiedLanguages)
                }
            } else {
                observer.completed(with: [IdentifiedLanguage(.none)])
            }
            return DisposeBag()
        }
    }

    static func translate(text: String?,
                          from fromLanguage: Language,
                          to toLanguage: Language) -> Signal<TranslateResponse, LinguaError> {

        return Signal<TranslateResponse, LinguaError> { observer in

            func send(_ translateResponse: TranslateResponse) -> Disposable {
                observer.completed(with: translateResponse)
                return DisposeBag()
            }

            // Send empty responses for any invalid states
            guard let text = text, text.characters.count > 0 else {
                    return send(TranslateResponse())
            }

            // Perform translation
            translator.translate(text, from: fromLanguage.rawValue,
                                 to: toLanguage.rawValue,
                                 failure: { error in
                                    observer.failed(.network(error.localizedDescription))
            }) { translateResponse in
                observer.completed(with: translateResponse)
            }
            return DisposeBag()
        }
    }
}

