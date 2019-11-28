//
//  ForceUpdateView.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 11/7/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//



// FAILED...


import SwiftUI

protocol UpdatableView: View {
    /// Toggle this boolean value to update the view.
    var updateView: State<Bool> { get set }
    associatedtype ViewType: View
    var newBody: ViewType { get }
}

extension UpdatableView {
    var body: some View {
        VStack {
            Toggle(isOn: updateView.projectedValue, label: {
                Text("I'm invisible")
                }).frame(maxHeight: 0).clipped()
            newBody
        }
    }
}



struct ForceUpdateView: UpdatableView {
    var updateView: State<Bool> = State<Bool>(initialValue: false)
    
    @State var model = Model()
    @State var isFirstResponder = false
    var newBody: some View {
        VStack {
            Text(model.str)
            AdvancedTextField(isFirstResponder: $isFirstResponder, text: $model.str, textDidChange: { newText in
                self.updateView.wrappedValue.toggle()
            })
            Spacer()
        }
    }
    
    class Model {
        var str: String
        init() {
            str = "hellooo"
        }
    }
}

struct ForceUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        ForceUpdateView()
    }
}
