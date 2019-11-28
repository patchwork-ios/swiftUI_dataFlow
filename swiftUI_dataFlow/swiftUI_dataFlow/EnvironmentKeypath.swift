//
//  EnvironmentKeypath.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 10/26/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI

class OtherModel: ObservableObject {
    var name: String
    init(name: String) {
        self.name = name
    }
}

class EnvModel: ObservableObject {
    var amount: String
    init(amount: String) {
        self.amount = amount
    }
}

class ViewModel: ObservableObject {
    @ObservedObject var envModel: EnvModel
    @ObservedObject var otherModel: OtherModel
    
    init(model: EnvModel, otherModel: OtherModel) {
        self.envModel = model
        self.otherModel = otherModel
    }
}

struct EnvironmentKeypath: View {
    @EnvironmentObject var model: ViewModel
    var body: some View {
        VStack {
            HStack {
                Text(model.envModel.amount)
                TextField("amount", text: $model.envModel.amount).disabled(true)
            }
            HStack {
                Text(model.otherModel.name)
                TextField("amount", text: $model.otherModel.name)
            }
        }
    }
}

struct EnvironmentKeypath_Previews: PreviewProvider {
    static var previews: some View {
        EnvironmentKeypath().environmentObject(ViewModel(model: EnvModel(amount: "100"), otherModel: OtherModel(name: "Things")))
    }
}
