//
//  TextFieldFormatter.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 10/21/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI
var numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
}()
struct TextFieldFormatter: View {
    @State private var string: String = ""
    var body: some View {
        VStack {
            Text(string)
            TextField("placholder", text: $string)
            TextField("placeholder", value: $string, formatter: numberFormatter)
        }
    }
}

struct TextFieldFormatter_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldFormatter()
    }
}
