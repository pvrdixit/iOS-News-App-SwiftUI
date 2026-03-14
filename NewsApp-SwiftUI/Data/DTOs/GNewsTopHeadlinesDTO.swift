//
//  GNewsTopHeadlinesDTO.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 14/03/26.
//

import Foundation

/// Root DTO returned by GNews for its top-headlines endpoint.
struct GNewsTopHeadlinesResponseDTO: Decodable {
    let totalArticles: Int?
    let articles: [GNewsArticleDTO]
}

/// GNews article payload before it is normalized into the domain Article model.
struct GNewsArticleDTO: Decodable {
    let id: String?
    let title: String?
    let description: String?
    let content: String?
    let url: String?
    let image: String?
    let publishedAt: String?
    let lang: String?
    let source: GNewsSourceDTO?
}

/// Nested source object returned by GNews.
struct GNewsSourceDTO: Decodable {
    let id: String?
    let name: String?
    let url: String?
    let country: String?
}

/// GNews supported categories in the same display order used by Explore.
enum GNewsSupportedCategories: String, CaseIterable, Identifiable, Codable {
    case general
    case world
    case business
    case technology
    case sports
    case nation
    case health
    case science
    case entertainment

    static let supportedCategories: [GNewsSupportedCategories] = [
        .general,
        .world,
        .business,
        .technology,
        .sports,
        .nation,
        .health,
        .science,
        .entertainment
    ]

    var id: String { rawValue }

    var displayName: String {
        rawValue.firstCapitalized
    }
}

/// GNews supported countries list.
enum GNewsSupportedCountries: String, CaseIterable, Identifiable, Codable {
    case argentina = "ar"
    case australia = "au"
    case austria = "at"
    case bangladesh = "bd"
    case belgium = "be"
    case botswana = "bw"
    case brazil = "br"
    case bulgaria = "bg"
    case canada = "ca"
    case chile = "cl"
    case china = "cn"
    case colombia = "co"
    case cuba = "cu"
    case czechia = "cz"
    case egypt = "eg"
    case estonia = "ee"
    case ethiopia = "et"
    case finland = "fi"
    case france = "fr"
    case germany = "de"
    case ghana = "gh"
    case greece = "gr"
    case hong_kong = "hk"
    case hungary = "hu"
    case india = "in"
    case indonesia = "id"
    case ireland = "ie"
    case israel = "il"
    case italy = "it"
    case japan = "jp"
    case kenya = "ke"
    case latvia = "lv"
    case lebanon = "lb"
    case lithuania = "lt"
    case malaysia = "my"
    case mexico = "mx"
    case morocco = "ma"
    case namibia = "na"
    case netherlands = "nl"
    case new_zealand = "nz"
    case nigeria = "ng"
    case norway = "no"
    case pakistan = "pk"
    case peru = "pe"
    case philippines = "ph"
    case poland = "pl"
    case portugal = "pt"
    case romania = "ro"
    case russia = "ru"
    case saudi_arabia = "sa"
    case senegal = "sn"
    case singapore = "sg"
    case slovakia = "sk"
    case slovenia = "si"
    case south_africa = "za"
    case south_korea = "kr"
    case spain = "es"
    case sweden = "se"
    case switzerland = "ch"
    case taiwan = "tw"
    case tanzania = "tz"
    case thailand = "th"
    case turkey = "tr"
    case uganda = "ug"
    case ukraine = "ua"
    case united_arab_emirates = "ae"
    case united_kingdom = "gb"
    case united_states = "us"
    case venezuela = "ve"
    case vietnam = "vn"
    case zimbabwe = "zw"

    var id: String { rawValue }

    var displayName: String {
        String(describing: self)
            .replacingOccurrences(of: "_", with: " ")
            .firstCapitalized
    }
}

/// GNews supported languages list.
enum GNewsSupportedLanguages: String, CaseIterable, Identifiable, Codable {
    case arabic = "ar"
    case bengali = "bn"
    case bulgarian = "bg"
    case catalan = "ca"
    case chinese = "zh"
    case czech = "cs"
    case dutch = "nl"
    case english = "en"
    case estonian = "et"
    case finnish = "fi"
    case french = "fr"
    case german = "de"
    case greek = "el"
    case gujarati = "gu"
    case hebrew = "he"
    case hindi = "hi"
    case hungarian = "hu"
    case indonesian = "id"
    case italian = "it"
    case japanese = "ja"
    case korean = "ko"
    case latvian = "lv"
    case lithuanian = "lt"
    case malayalam = "ml"
    case marathi = "mr"
    case norwegian = "no"
    case polish = "pl"
    case portuguese = "pt"
    case punjabi = "pa"
    case romanian = "ro"
    case russian = "ru"
    case slovak = "sk"
    case slovenian = "sl"
    case spanish = "es"
    case swedish = "sv"
    case tamil = "ta"
    case telugu = "te"
    case thai = "th"
    case turkish = "tr"
    case ukrainian = "uk"
    case vietnamese = "vi"

    var id: String { rawValue }

    var displayName: String {
        String(describing: self)
            .replacingOccurrences(of: "_", with: " ")
            .firstCapitalized
    }
}
