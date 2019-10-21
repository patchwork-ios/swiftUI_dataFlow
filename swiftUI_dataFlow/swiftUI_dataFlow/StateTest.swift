//
//  StateTest.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 10/19/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI

fileprivate var item1 = BudgetItem(name: "Second test State", amount: "50")

// Notice how when you use `@ObservedObject` and edit the text in the TextField, the corresponding Text object will update.
// However, when you use the `@State` variable the corresponding object does not change. With `@State` the only way to get the corresponding object to update is to re-assign the variable.
// NOTE: the button will not work with the `@ObservedObject`, so comment out the button when not useing `@State`
struct StateTest: View {
//    @ObservedObject private var item = item0
    @State private var item = item0
    
    var body: some View {
        VStack {
            HStack {
                TextField("title", text: $item.name)
                Spacer()
                TextField("title", text: $item.amount)
            }
            HStack {
                Text(item.name)
                Spacer()
                Text(item.amount)
            }
            Button(action: {
                if self.item.name == item0.name {
                    self.item = item1
                } else {
                    self.item = item0
                }
            }) {
               Text("Re-assign variable")
            }
//            Button(action: {
//                self.item = self.item == item0 ? item1 : item0
//            }, label: { Text("Reassign item0") })
        }
    }
}



struct StateTest_Previews: PreviewProvider {
    static var previews: some View {
        StateTest()
    }
}
