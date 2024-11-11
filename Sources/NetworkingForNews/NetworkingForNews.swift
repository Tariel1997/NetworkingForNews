// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct Source: Codable {
    public let id: String?
    public let name: String
}

public struct NewsResponseData: Codable {
    public let status: String
    public let totalResults: Int
    public let articles: [NewsArticle]?
    
}

public struct NewsArticle: Codable {
    public let source: Source
    public let author: String?
    public let title: String
    public let description: String?
    public let url: String
    public let urlToImage: String?
    public let publishedAt: String
    public let content: String?
}

public protocol NetworkingProtocol {
    func fetchNewsArticles(completion: @escaping @Sendable (Result<[NewsArticle], Error>) -> Void)
}


public class NetworkingForNews: NetworkingProtocol {
    
    private let apiKey = "9090160e5ec147ca97b94502994ebc28"
    
    public init() {}
    
    public func fetchNewsArticles(completion: @escaping @Sendable (Result<[NewsArticle], Error>) -> Void) {
        let urlString = "https://newsapi.org/v2/everything?q=bitcoin&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No Data", code: 404, userInfo: nil)))
                }
                return
            }
            
            do {
                let newsResponse = try JSONDecoder().decode(NewsResponseData.self, from: data)
                if let articles = newsResponse.articles {
                    DispatchQueue.main.async {
                        completion(.success(articles))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "No Articles", code: 404, userInfo: nil)))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
}
