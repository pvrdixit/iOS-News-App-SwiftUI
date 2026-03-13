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
