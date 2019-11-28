//
//  CodableHelper.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 11/19/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import UIKit

struct Top: Codable {
    var data: MidTop
}

struct MidTop: Codable {
    var wrapper: Mid
}

struct Mid:  Codable {
    var objects: [MyObject]
}

struct MyObject: Codable {
    var name: String
    var age: Int
    
//    func encode(to encoder: Encoder) throws {
//
//    }
//
//    init(from decoder: Decoder) throws {
//        let values = decoder.container(keyedBy: <#T##CodingKey.Protocol#>)
//    }
}


