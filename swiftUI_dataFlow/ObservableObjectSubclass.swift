//
//  ObservableObjectSubclass.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 11/1/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI
import Combine

class ObservableObjectSubModel: ObservableObject {
    @Published var two = true // this works
    @Published var one: Bool // this works
    
//    var objectWillChange = PassthroughSubject<Void, Never>()
    
    init(_ outline: Bool) {
        self.one = outline
    }
}


// NOTE: SubClasses of ObservableObject don't seem to use the `@Published` propertyWrapper, meaning their variables are not `ObservableObject`.
class ObservableObjectSubSubModel: ObservableObjectSubModel {
    @Published var four = true // this doesnt work
    @Published var three: Bool // this doesnt work
    
    init(_ hasBackgroundColor: Bool, _ hasOutline: Bool) {
        self.three = hasBackgroundColor
        super.init(hasOutline)
    }
    
}

struct ObservableObjectSub: View {
    @EnvironmentObject var model: ObservableObjectSubSubModel
    
    var body: some View {
        HStack {
            VStack(alignment: .center, spacing: 20) {
                HStack {
                    Text("1")
                    Text(String(describing: model.one))
                }
                HStack {
                    Text("2")
                    Text(String(describing: model.two))
                }
                HStack {
                    Text("3")
                    Text(String(describing: model.three))
                }
                HStack {
                    Text("4")
                    Text(String(describing: model.four))
                }
            }
            Spacer(minLength: 250)
                ObservableObjectSubEditView()
        }
    .padding()
    }
}
struct ObservableObjectSubEditView: View {
    @EnvironmentObject var model: ObservableObjectSubSubModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Toggle(isOn: $model.one) {
                Text("1")
            }
            Toggle(isOn: $model.two) {
                Text("2")
            }
            Toggle(isOn: $model.three) {
                Text("3")
            }
            Toggle(isOn: $model.four) {
                Text("4")
            }
            
        }
    }
}

struct ObservableObjectSubclass_Previews: PreviewProvider {
    static var previews: some View {
        ObservableObjectSub().environmentObject(ObservableObjectSubSubModel(true, true))
    }
}
