//
//  NetworkManager.swift
//  VirtualTourist
//
//  Created by Herbert Dodge on 7/27/20.
//  Copyright © 2020 Herbert Dodge. All rights reserved.
//

import UIKit

struct NetworkManager {
    
    //MARK: - Properties
    
    static let shared = NetworkManager()
    
    static let apiKey = "968a3fd91af6324158510cd873e48284"
    static let baseUrl = "https://api.flickr.com/services/rest"
    static let searchMethod = "flickr.photos.search"
    static let numberOfPhotos = 20
    
    //MARK: - Helpers
    
    func getPhotosAt(latitude: Double, longitude: Double, completion: @escaping (FlickrResponse?, Error?) -> Void) {
        let searchUrl = "\(NetworkManager.baseUrl)?api_key=\(NetworkManager.apiKey)&method=\(NetworkManager.searchMethod)&per_page=\(NetworkManager.numberOfPhotos)&format=json&nojsoncallback=1?&lat=\(latitude)&lon=\(longitude)&page=\((1...10).randomElement() ?? 1)"
        
        let request = URLRequest(url: URL(string: searchUrl)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let flickrResponse = try decoder.decode(FlickrResponse.self, from: data)
                completion(flickrResponse, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func constructPhotoUrl(_ response: FlickrResponse) -> [URL] {
        var Urls: [URL] = []
        
        for url in response.photos.photo {
            let url = "https://farm\(url.farm).staticflickr.com/\(url.server)/\(url.id)_\(url.secret)_m.jpg"
            
            Urls.append(URL(string: url)!)
        }
        return Urls
    }
    
    func downloadImage(imageUrl: URL, completion: @escaping (Data?, Error?) -> Void) {
        let request = URLRequest(url: imageUrl)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (imageData, response, error) in
            if error != nil {
                completion(nil, error)
            }
            guard let imageData = imageData else { return }
            
            completion(imageData, nil)
            
        }
        task.resume()
    }
}
