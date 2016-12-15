//
//  IdentifiedLanguage.swift
//  Lingua
//
//  Created by David Warner on 11/30/16.
//  Copyright © 2016 davewarner. All rights reserved.
//

import Foundation
import LanguageTranslatorV2

extension IdentifiedLanguage {

    public init(_ language: Language) {
        self.language = language.rawValue
        self.confidence = 0.0
    }

    var enumValue: Language {
        return Language(rawValue: language) ?? .unknown
    }

    var confidenceStringPercentage: String {
        return "\(confidence.truncate(places: 2) * 100)%"
    }

    var certaintyLevel: String {
        switch confidence {
        case 0..<(0.2):
            return "Low"
        case (0.2)..<(0.4):
            return "Medium-Low"
        case (0.4)..<(0.6):
            return "Medium"
        case (0.6)..<(0.8):
            return "Medium-High"
        case (0.8)..<(0.9):
            return "High"
        case (0.9)..<(0.95):
            return "Very High"
        case (0.95)..<(0.975):
            return "Extremely High"
        case (0.975)...(1.0):
            return "Near Certain"
        default:
            return ""
        }
    }
}

public func ==(lhs: Language, rhs: Language) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none): return true
    case (.unknown, .unknown): return true
    case (.afrikaans, .afrikaans): return true
    case (.arabic, .arabic): return true
    case (.azerbaijani, .azerbaijani): return true
    case (.bashkir, .bashkir): return true
    case (.belarusian, .belarusian): return true
    case (.bulgarian, .bulgarian): return true
    case (.bengali, .bengali): return true
    case (.bosnian, .bosnian): return true
    case (.czech, .czech): return true
    case (.chuvash, .chuvash): return true
    case (.danish, .danish): return true
    case (.german, .german): return true
    case (.greek, .greek): return true
    case (.english, .english): return true
    case (.esperanto, .esperanto): return true
    case (.spanish, .spanish): return true
    case (.estonian, .estonian): return true
    case (.basque, .basque): return true
    case (.persian, .persian): return true
    case (.finnish, .finnish): return true
    case (.french, .french): return true
    case (.gujarati, .gujarati): return true
    case (.hebrew, .hebrew): return true
    case (.hindi, .hindi): return true
    case (.haitian, .haitian): return true
    case (.hungarian, .hungarian): return true
    case (.armenian, .armenian): return true
    case (.indonesian, .indonesian): return true
    case (.icelandic, .icelandic): return true
    case (.italian, .italian): return true
    case (.japanese, .japanese): return true
    case (.georgian, .georgian): return true
    case (.kazakh, .kazakh): return true
    case (.centralKhmer, .centralKhmer): return true
    case (.korean, .korean): return true
    case (.kurdish, .kurdish): return true
    case (.kirghiz, .kirghiz): return true
    case (.lithuanian, .lithuanian): return true
    case (.latvian, .latvian): return true
    case (.malayalam, .malayalam): return true
    case (.mongolian, .mongolian): return true
    case (.norwegianBokmal, .norwegianBokmal): return true
    case (.dutch, .dutch): return true
    case (.norwegianNynorsk, .norwegianNynorsk): return true
    case (.panjabi, .panjabi): return true
    case (.polish, .polish): return true
    case (.pushto, .pushto): return true
    case (.portuguese, .portuguese): return true
    case (.romanian, .romanian): return true
    case (.russian, .russian): return true
    case (.slovakian, .slovakian): return true
    case (.somali, .somali): return true
    case (.albanian, .albanian): return true
    case (.swedish, .swedish): return true
    case (.tamil, .tamil): return true
    case (.telugu, .telugu): return true
    case (.turkish, .turkish): return true
    case (.ukrainian, .ukrainian): return true
    case (.urdu, .urdu): return true
    case (.vietnamese, .vietnamese): return true
    case (.chinese, .chinese): return true
    case (.traditionalChinese, .traditionalChinese): return true
    default: return false
    }
}

public enum Language: String, Equatable {

    case none = ""
    case unknown = "xx"

    case afrikaans = "af"
    case arabic = "ar"
    case azerbaijani = "az"
    case bashkir = "ba"
    case belarusian = "be"
    case bulgarian = "bg"
    case bengali = "bn"
    case bosnian = "bs"
    case czech = "cs"
    case chuvash = "cv"
    case danish = "da"
    case german = "de"
    case greek = "el"
    case english = "en"
    case esperanto = "eo"
    case spanish = "es"
    case estonian = "et"
    case basque = "eu"
    case persian = "fa"
    case finnish = "fi"
    case french = "fr"
    case gujarati = "gu"
    case hebrew = "he"
    case hindi = "hi"
    case haitian = "ht"
    case hungarian = "hu"
    case armenian = "hy"
    case indonesian = "id"
    case icelandic = "is"
    case italian = "it"
    case japanese = "ja"
    case georgian = "ka"
    case kazakh = "kk"
    case centralKhmer = "km"
    case korean = "ko"
    case kurdish = "ku"
    case kirghiz = "ky"
    case lithuanian = "lt"
    case latvian = "lv"
    case malayalam = "ml"
    case mongolian = "mn"
    case norwegianBokmal = "nb"
    case dutch = "nl"
    case norwegianNynorsk = "nn"
    case panjabi = "pa"
    case polish = "pl"
    case pushto = "ps"
    case portuguese = "pt"
    case romanian = "ro"
    case russian = "ru"
    case slovakian = "sk"
    case somali = "so"
    case albanian = "sq"
    case swedish = "sv"
    case tamil = "ta"
    case telugu = "te"
    case turkish = "tr"
    case ukrainian = "uk"
    case urdu = "ur"
    case vietnamese = "vi"
    case chinese = "zh"
    case traditionalChinese = "zh-TW"

    static let supportedInputLanguages: [Language] = [.english]

    static let supportedOutputLanguages: [Language] = [.english,
                                                       .french,
                                                       .spanish,
                                                       .portuguese,
                                                       .bosnian]
    
    var displayValue: String {
        switch self {

        case .none: return "None"
        case .unknown: return "Unknown"

        case .afrikaans: return "Afrikaans"
        case .arabic: return "Arabic"
        case .azerbaijani: return "Azerbaijani"
        case .bashkir: return "Bashkir"
        case .belarusian: return "Belarusian"
        case .bulgarian: return "Bulgarian"
        case .bengali: return "Bengali"
        case .bosnian: return "Bosnian"
        case .czech: return "Czech"
        case .chuvash: return "Chuvash"
        case .danish: return "Danish"
        case .german: return "German"
        case .greek: return "Greek"
        case .english: return "English"
        case .esperanto: return "Esperanto"
        case .spanish: return "Spanish"
        case .estonian: return "Estonian"
        case .basque: return "Basque"
        case .persian: return "Persian"
        case .finnish: return "Finnish"
        case .french: return "French"
        case .gujarati: return "Gujarati"
        case .hebrew: return "Hebrew"
        case .hindi: return "Hindi"
        case .haitian: return "Haitian"
        case .hungarian: return "Hungarian"
        case .armenian: return "Armenian"
        case .indonesian: return "Indonesian"
        case .icelandic: return "Icelandic"
        case .italian: return "Italian"
        case .japanese: return "Japanese"
        case .georgian: return "Georgian"
        case .kazakh: return "Kazakh"
        case .centralKhmer: return "Central Khmer"
        case .korean: return "Korean"
        case .kurdish: return "Kurdish"
        case .kirghiz: return "Kirghiz"
        case .lithuanian: return "Lithuanian"
        case .latvian: return "Latvian"
        case .malayalam: return "Malayalam"
        case .mongolian: return "Mongolian"
        case .norwegianBokmal: return "Norwegian Bokmal"
        case .dutch: return "Dutch"
        case .norwegianNynorsk: return "Norwegian Nynorsk"
        case .panjabi: return "Panjabi"
        case .polish: return "Polish"
        case .pushto: return "Pushto"
        case .portuguese: return "Portuguese"
        case .romanian: return "Romanian"
        case .russian: return "Russian"
        case .slovakian: return "Slovakian"
        case .somali: return "Somali"
        case .albanian: return "Albanian"
        case .swedish: return "Swedish"
        case .tamil: return "Tamil"
        case .telugu: return "Telugu"
        case .turkish: return "Turkish"
        case .ukrainian: return "Ukrainian"
        case .urdu: return "Urdu"
        case .vietnamese: return "Vietnamese"
        case .chinese: return "Chinese"
        case .traditionalChinese: return "Traditional Chinese"
        }
    }
}
