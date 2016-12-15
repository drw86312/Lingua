//
//  TranslationResponse.swift
//  Lingua
//
//  Created by David Warner on 11/30/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import Foundation
import LanguageTranslatorV2

extension Translation {

    public init() {
        self.translation = ""
    }

    public init(withText: String) {
        self.translation = withText
    }
}

extension TranslateResponse {

    public init() {
        let translation = Translation()
        self.translations = [translation]
        self.characterCount = translation.translation.characters.count
        self.wordCount = 0
    }

    public init(withText: String) {
        let translation = Translation(withText: withText)
        self.translations = [translation]
        self.characterCount = translation.translation.characters.count
        self.wordCount = 0
    }
}
