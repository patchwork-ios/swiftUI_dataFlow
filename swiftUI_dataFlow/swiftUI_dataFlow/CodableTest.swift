//
//  CodableTest.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 10/28/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI
import Combine

fileprivate class CodableModel: ObservableObject, Codable {
    var objectWillChange = PassthroughSubject<Void, Never>()
    var str: String = "testing" { didSet { objectWillChange.send() } }
    private enum CodingKeys: String, CodingKey { case str }
}
// Subclassing and Codable don't work unless you implement the codable methods manually.
//fileprivate class CodableModelSubclass: CodableModel {
//    var i: Int = 1 { didSet { didChange.send() } }
//    var j: String = "" { didSet { didChange.send() } }
//    var x: Double = 0 { didSet { didChange.send() } }
//    private enum CodingKeys: String, CodingKey {
//        case i, j, x
//    }
//    override init() {
//        i = 1
//        j = "j"
//        x = 2.0
//        super.init()
//    }
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        i = try values.decode(Int.self, forKey: .i)
//        j = try values.decode(String.self, forKey: .j)
//        x = try values.decode(Double.self, forKey: .x)
//        try super.init(from: decoder)
//    }
//    override func encode(to encoder: Encoder) throws {
//        <#code#>
//    }
//}

struct CodableTest: View {
    @ObservedObject fileprivate var model = CodableModel()
    var body: some View {
        VStack {
            Text(model.str)
            TextField("ts", text: $model.str)
        }
    }
}

struct CodableTest_Previews: PreviewProvider {
    static var previews: some View {
        CodableTest()
    }
}
