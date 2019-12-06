//
//  BindingWrapperConversion.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 11/30/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI
import Combine

struct BindingWrapperConversion: View {
    @ObservedObject var my: Obj
    var body: some View {
        let binding = Binding<String>(get: { "\(self.my.dbl)" }, set: { self.my.dbl = Double($0)! })
        return VStack {
            Text("\(my.dbl)")
            Text(my.str)
            TextField("", text: $my.str)
            TextField("", text: binding)
        }
    }
}

class Obj: ObservableObject {
    @Published var str = "string"
    @Published var dbl: Double = 199
//    var objectWillChange = PassthroughSubject<Void, Never>()
    // variable that wraps the double and converts it to a string and updates the publisher with the publisher.didChange
    
}

struct BindingWrapperConversion_Previews: PreviewProvider {
    @ObservedObject static var my = Obj()
    static var previews: some View {
        BindingWrapperConversion(my: my)
    }
}
