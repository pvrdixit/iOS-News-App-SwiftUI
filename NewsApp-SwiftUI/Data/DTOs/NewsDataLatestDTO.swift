import Foundation

//
//  NewsDataLatestDTO.swift
//  NewsApp-SwiftUI
//
//  Created by Vijay Raj Dixit on 13/03/26.
//

/// Root DTO returned by NewsData for its latest-headlines endpoint.
struct NewsDataLatestResponseDTO: Decodable {
    let totalResults: Int?
    let results: [NewsDataArticleDTO]
    let nextPage: String?
}

/// NewsData article payload before it is normalized into the domain Article model.
struct NewsDataArticleDTO: Decodable {
    let title: String?
    let link: String?
    let creator: [String]?
    let description: String?
    let content: String?
    let pubDate: String?
    let duplicate: Bool?
    let imageURL: String?
    let sourceID: String?
    let sourceName: String?

    enum CodingKeys: String, CodingKey {
        case title
        case link
        case creator
        case description
        case content
        case pubDate
        case duplicate
        case imageURL = "image_url"
        case sourceID = "source_id"
        case sourceName = "source_name"
    }
}

/// NewsData supported categories in the same display order used by Explore.
enum NewsDataSupportedCategories: String, CaseIterable, Identifiable, Codable {
    case top
    case world
    case business
    case technology
    case sports
    case breaking
    case domestic
    case health
    case science
    case entertainment
    case politics
    case education
    case lifestyle
    case environment
    case crime
    case food
    case tourism
    case other

    static let supportedCategories: [NewsDataSupportedCategories] = [
        .top,
        .world,
        .business,
        .technology,
        .sports,
        .breaking,
        .domestic,
        .health,
        .science,
        .entertainment,
        .politics,
        .education,
        .lifestyle,
        .environment,
        .crime,
        .food,
        .tourism,
        .other
    ]

    var id: String { rawValue }

    var displayName: String {
        rawValue.firstCapitalized
    }
}


/// NewsData supported countries list
enum NewsDataSupportedCountries: String, CaseIterable, Identifiable, Codable {
    case united_states = "us"
    case united_kingdom = "gb"
    case united_arab_emirates = "ae"
    case afghanistan = "af"
    case albania = "al"
    case algeria = "dz"
    case american_samoa = "as"
    case andorra = "ad"
    case angola = "ao"
    case anguilla = "ai"
    case antarctica = "aq"
    case antigua_and_barbuda = "ag"
    case argentina = "ar"
    case armenia = "am"
    case aruba = "aw"
    case australia = "au"
    case austria = "at"
    case azerbaijan = "az"
    case bahamas = "bs"
    case bahrain = "bh"
    case bangladesh = "bd"
    case barbados = "bb"
    case belarus = "by"
    case belgium = "be"
    case belize = "bz"
    case benin = "bj"
    case bermuda = "bm"
    case bhutan = "bt"
    case bolivia = "bo"
    case bosnia_and_herzegovina = "ba"
    case botswana = "bw"
    case bouvet_island = "bv"
    case brazil = "br"
    case british_indian_ocean_territory = "io"
    case brunei = "bn"
    case bulgaria = "bg"
    case burkina_faso = "bf"
    case burundi = "bi"
    case cambodia = "kh"
    case cameroon = "cm"
    case canada = "ca"
    case cape_verde = "cv"
    case cayman_islands = "ky"
    case central_african_republic = "cf"
    case chad = "td"
    case chile = "cl"
    case china = "cn"
    case christmas_island = "cx"
    case colombia = "co"
    case comoros = "km"
    case congo = "cg"
    case democratic_republic_of_the_congo = "cd"
    case cook_islands = "ck"
    case costa_rica = "cr"
    case cote_divoire = "ci"
    case croatia = "hr"
    case jersey = "je"
    case cuba = "cu"
    case cyprus = "cy"
    case curacao = "cw"
    case czech_republic = "cz"
    case denmark = "dk"
    case djibouti = "dj"
    case dominica = "dm"
    case dominican_republic = "do"
    case east_timor = "tp"
    case ecuador = "ec"
    case egypt = "eg"
    case el_salvador = "sv"
    case equatorial_guinea = "gq"
    case eritrea = "er"
    case estonia = "ee"
    case ethiopia = "et"
    case falkland_islands = "fk"
    case faroe_islands = "fo"
    case fiji = "fj"
    case finland = "fi"
    case france = "fr"
    case french_guiana = "gf"
    case french_polynesia = "pf"
    case french_southern_territories = "tf"
    case gabon = "ga"
    case gambia = "gm"
    case georgia = "ge"
    case germany = "de"
    case ghana = "gh"
    case gibraltar = "gi"
    case greece = "gr"
    case greenland = "gl"
    case grenada = "gd"
    case guadeloupe = "gp"
    case guam = "gu"
    case guatemala = "gt"
    case guinea = "gn"
    case guinea_bissau = "gw"
    case guyana = "gy"
    case haiti = "ht"
    case heard_island_and_mcdonald_islands = "hm"
    case vatican = "va"
    case honduras = "hn"
    case timor_leste = "tl"
    case hong_kong = "hk"
    case hungary = "hu"
    case iceland = "is"
    case india = "in"
    case indonesia = "id"
    case iran = "ir"
    case iraq = "iq"
    case ireland = "ie"
    case israel = "il"
    case italy = "it"
    case jamaica = "jm"
    case japan = "jp"
    case jordan = "jo"
    case kazakhstan = "kz"
    case kenya = "ke"
    case kiribati = "ki"
    case kosovo = "xk"
    case north_korea = "kp"
    case south_korea = "kr"
    case kuwait = "kw"
    case kyrgyzstan = "kg"
    case laos = "la"
    case latvia = "lv"
    case lebanon = "lb"
    case lesotho = "ls"
    case liberia = "lr"
    case libya = "ly"
    case liechtenstein = "li"
    case lithuania = "lt"
    case luxembourg = "lu"
    case macau = "mo"
    case macedonia = "mk"
    case madagascar = "mg"
    case malawi = "mw"
    case malaysia = "my"
    case maldives = "mv"
    case mali = "ml"
    case malta = "mt"
    case marshall_islands = "mh"
    case martinique = "mq"
    case mauritania = "mr"
    case mauritius = "mu"
    case mayotte = "yt"
    case mexico = "mx"
    case micronesia = "fm"
    case moldova = "md"
    case monaco = "mc"
    case mongolia = "mn"
    case montserrat = "ms"
    case morocco = "ma"
    case mozambique = "mz"
    case myanmar = "mm"
    case montenegro = "me"
    case namibia = "na"
    case nauru = "nr"
    case nepal = "np"
    case netherlands = "nl"
    case netherlands_antilles = "an"
    case new_caledonia = "nc"
    case new_zealand = "nz"
    case nicaragua = "ni"
    case niger = "ne"
    case nigeria = "ng"
    case niue = "nu"
    case norfolk_island = "nf"
    case northern_mariana_islands = "mp"
    case norway = "no"
    case oman = "om"
    case pakistan = "pk"
    case palau = "pw"
    case palestine = "ps"
    case panama = "pa"
    case papua_new_guinea = "pg"
    case paraguay = "py"
    case peru = "pe"
    case philippines = "ph"
    case pitcairn = "pn"
    case poland = "pl"
    case portugal = "pt"
    case puerto_rico = "pr"
    case qatar = "qa"
    case reunion = "re"
    case romania = "ro"
    case russia = "ru"
    case rwanda = "rw"
    case saint_helena = "sh"
    case saint_kitts_and_nevis = "kn"
    case saint_lucia = "lc"
    case saint_pierre_and_miquelon = "pm"
    case saint_vincent_and_the_grenadines = "vc"
    case samoa = "ws"
    case san_marino = "sm"
    case sao_tome_and_principe = "st"
    case saudi_arabia = "sa"
    case senegal = "sn"
    case seychelles = "sc"
    case sierra_leone = "sl"
    case singapore = "sg"
    case slovakia = "sk"
    case slovenia = "si"
    case solomon_islands = "sb"
    case somalia = "so"
    case south_africa = "za"
    case south_georgia_and_the_south_sandwich_islands = "gs"
    case spain = "es"
    case sri_lanka = "lk"
    case sudan = "sd"
    case suriname = "sr"
    case svalbard_and_jan_mayen = "sj"
    case eswatini = "sz"
    case sweden = "se"
    case switzerland = "ch"
    case syria = "sy"
    case taiwan = "tw"
    case tajikistan = "tj"
    case tanzania = "tz"
    case thailand = "th"
    case togo = "tg"
    case tokelau = "tk"
    case tonga = "to"
    case trinidad_and_tobago = "tt"
    case tunisia = "tn"
    case turkey = "tr"
    case turkmenistan = "tm"
    case turks_and_caicos_islands = "tc"
    case tuvalu = "tv"
    case uganda = "ug"
    case ukraine = "ua"
    case uruguay = "uy"
    case uzbekistan = "uz"
    case vanuatu = "vu"
    case venezuela = "ve"
    case vietnam = "vi"
    case british_virgin_islands = "vg"
    case wallis_and_futuna = "wf"
    case western_sahara = "eh"
    case yemen = "ye"
    case yugoslavia = "yu"
    case zambia = "zm"
    case zimbabwe = "zw"
    case serbia = "rs"
    case saint_martin_dutch = "sx"
    case world = "wo"

    var id: String { rawValue }

    var displayName: String {
        String(describing: self)
            .replacingOccurrences(of: "_", with: " ")
            .firstCapitalized
    }
}


/// NewsData supported languages list
enum NewsDataSupportedLanguages: String, CaseIterable, Identifiable, Codable {
    case afrikaans = "af"
    case albanian = "sq"
    case amharic = "am"
    case arabic = "ar"
    case armenian = "hy"
    case assamese = "as"
    case azerbaijani = "az"
    case bambara = "bm"
    case basque = "eu"
    case belarusian = "be"
    case bengali = "bn"
    case bosnian = "bs"
    case bulgarian = "bg"
    case burmese = "my"
    case catalan = "ca"
    case central_kurdish = "ckb"
    case chinese = "zh"
    case croatian = "hr"
    case czech = "cs"
    case danish = "da"
    case dutch = "nl"
    case english = "en"
    case estonian = "et"
    case filipino = "pi"
    case finnish = "fi"
    case french = "fr"
    case galician = "gl"
    case georgian = "ka"
    case german = "de"
    case greek = "el"
    case gujarati = "gu"
    case hausa = "ha"
    case hebrew = "he"
    case hindi = "hi"
    case hungarian = "hu"
    case icelandic = "is"
    case indonesian = "id"
    case italian = "it"
    case japanese = "jp"
    case kannada = "kn"
    case kazakh = "kz"
    case khmer = "kh"
    case kinyarwanda = "rw"
    case korean = "ko"
    case kurdish = "ku"
    case latvian = "lv"
    case lithuanian = "lt"
    case luxembourgish = "lb"
    case macedonian = "mk"
    case malay = "ms"
    case malayalam = "ml"
    case maltese = "mt"
    case maori = "mi"
    case marathi = "mr"
    case mongolian = "mn"
    case nepali = "ne"
    case norwegian = "no"
    case oriya = "or"
    case pashto = "ps"
    case persian = "fa"
    case polish = "pl"
    case portuguese = "pt"
    case punjabi = "pa"
    case romanian = "ro"
    case russian = "ru"
    case samoan = "sm"
    case serbian = "sr"
    case shona = "sn"
    case sindhi = "sd"
    case sinhala = "si"
    case slovak = "sk"
    case slovenian = "sl"
    case somali = "so"
    case spanish = "es"
    case swahili = "sw"
    case swedish = "sv"
    case tajik = "tg"
    case tamil = "ta"
    case telugu = "te"
    case thai = "th"
    case traditional_chinese = "zht"
    case turkish = "tr"
    case turkmen = "tk"
    case ukrainian = "uk"
    case urdu = "ur"
    case uzbek = "uz"
    case vietnamese = "vi"
    case welsh = "cy"
    case zulu = "zu"

    var id: String { rawValue }

    var displayName: String {
        String(describing: self)
            .replacingOccurrences(of: "_", with: " ")
            .firstCapitalized
    }
}
