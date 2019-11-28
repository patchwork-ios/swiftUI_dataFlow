//
//  ProtocolObservableObject.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 10/26/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI


protocol Observable: ObservableObject, Identifiable {
    var id: UUID { get }
    var name: String { get }
    var value: Double { get set }
}

class MyObservable: Observable {
    let id = UUID()
    
    @Published var name: String
    @Published var value: Double
    
    init(name: String, value: Double) {
        self.name = name
        self.value = value
    }
}

struct ProtocolObservableObject: View {
    @ObservedObject var model: Model
    
    var body: some View {
        HStack {
            Text(model.item.name)
            TextField("title", text: $model.item.name)
        }
    }
}
extension ProtocolObservableObject {
    class Model: ObservableObject {
        @Published var item: MyObservable
        init(item: MyObservable) {
            self.item = item
        }
    }
}


struct ProtocolObservableObject_Previews: PreviewProvider {
    static var previews: some View {
        ProtocolObservableObject(model: ProtocolObservableObject.Model(item: MyObservable(name: "Vespucci", value: 109)))
    }
}
