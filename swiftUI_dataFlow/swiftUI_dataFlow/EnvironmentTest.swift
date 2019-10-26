//
//  EnvironmentTest.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 10/22/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI

class SubSubViewModel: ObservableObject {
    @Published var cost: Int
    init(cost: Int) {
        self.cost = cost
    }
}

class SubViewModel: SubSubViewModel {
    @Published var amount: Double
    init(amount: Double, cost: Int) {
        self.amount = amount
        super.init(cost: cost)
    }
}

class MainModel: SubViewModel {
    @Published var date: Date
    @Published var name: String
    
    
    init(name: String, amount: Double, date: Date, cost: Int) {
        self.name = name
        self.date = date
        super.init(amount: amount, cost: cost)
    }
}

struct EnvironmentTest: View {
    
    var body: some View {
        List {
            ButtonThing()
        }
    }
}

struct ButtonThing: View {
    @EnvironmentObject var model: MainModel
    @State var isActive = true
    
    var body: some View {
        NavigationLink(destination: SubView(), isActive: $isActive) {
            VStack {
                Text(model.date.description)
                Text(model.name)
                Text(model.amount.description)
                Text(model.cost.description)
            }
        }
    }
}

struct SubView: View {
    @EnvironmentObject var model: SubViewModel
    
    var body: some View {
        Text(model.amount.description)
    }
}

struct SubSubView: View {
    var body: some View {
        Text("")
    }
}

struct EnvironmentTest_Previews: PreviewProvider {
    static var previews: some View {
        EnvironmentTest().environmentObject(MainModel(name: "name", amount: 100, date: Date(), cost: 300))
    }
}
