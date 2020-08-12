//
//  FlickrResponse.swift
//  VirtualTourist
//
//  Created by Herbert Dodge on 7/27/20.
//  Copyright © 2020 Herbert Dodge. All rights reserved.
//

import Foundation


struct FlickrResponse: Codable {
    let photos: FlickrJSONResponse
}

struct FlickrJSONResponse: Codable {
    let photo: [FlickerUrlResponse]
}


struct FlickerUrlResponse: Codable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
}
