//
//  UIViewRepresentable.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 11/4/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI

struct CustomTextFieldView: View {
    @State var str = "text"
    @State var isFirstResponder = false
    var body: some View {
        VStack {
            AdvancedTextField(isFirstResponder: $isFirstResponder, text: $str)
            TextField("placeholder2", text: $str)
            Toggle(isOn: $isFirstResponder) {
                Text("First Responder")
            }
            Spacer(minLength: 500)
        }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextFieldView()
    }
}




struct AdvancedTextField: UIViewRepresentable {
    @Binding var isFirstResponder: Bool
    @Binding var text: String
    var textDidChange: ((String?) -> Void)?
    

    init(isFirstResponder: Binding<Bool>, text: Binding<String>, textDidChange: ((String?) -> Void)? = nil) {
        _isFirstResponder = isFirstResponder
        _text = text
        self.textDidChange = textDidChange
    }
    
    func makeCoordinator() -> AdvancedTextField.Coordinator {
        let coordinator = Coordinator(isFirstResponder: $isFirstResponder, text: $text, textDidChange: textDidChange)
        return coordinator
    }
    
    func makeUIView(context: UIViewRepresentableContext<AdvancedTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.text = text
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(context.coordinator.textChanged(_:)), for: .editingChanged)
        return textField
    }
    
    
    // MARK: - SwiftUI -> UIKit
    
    /// This method is called whenever a the SwiftUI view is re-rendered and/or the bindings on this View are updated.
    /// The intention is to update your UIKit object based on SwiftUI changes. i.e. `SwiftUI -> UIKit`.
    /// - WARNING: Be sure to not update any `Binding` during the execution of this method (whether directly or indirectly,
    /// like via a delegate method being executed in the `Coordinator`). If you do this, you will get the warning:
    /// `Modifying state during view update, this will cause undefined behavior.` and you may can an infinite loop.
    /// See `Coordinator.listenToChanges` flag for my approach to avoid this problem.
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<AdvancedTextField>) {
        // update UIKit based on Bindings from SwiftUI. i.e. _one of your bindings have changed_
        context.coordinator.listenToChanges = false
        if isFirstResponder != uiView.isFirstResponder {
            if isFirstResponder {
                uiView.becomeFirstResponder() // this calls the delegate methods, which update the binding, which calls this method... infinitum. Hence the `listenToChanges` variable.
            } else {
                uiView.resignFirstResponder() // this calls the delegate methods, which update the binding, which calls this method... infinitum. Hence the `listenToChanges` variable.
            }
        }
        uiView.text = text
        context.coordinator.listenToChanges = true
    }

    
    // MARK: - UIKit -> SwiftUI
    
    /// The `Coordinator` class is meant to be the delegate and action handler of the UIKit objects.
    /// Your `UIViewRepresentable` object will not handle delegate methods and actions of UIKit objects (they just won't get called).
    /// The `Coordinator` is meant to update SwiftUI (via updating `Binding`s) based on UIKit changes. i.e. `UIKit -> SwiftUI`
    /// - WARNING: When updating a SwiftUI's `Binding`s, make sure you are not updating it from changes made in the `updateUIView` method
    /// or else you will get a warning and can get into an infinite loop.
    /// i.e. Binding updated -> updateUIView -> delegate method on `Coordinator` updates Binding -> updateUIView -> delegate method... etc
    class Coordinator: NSObject, UITextFieldDelegate {
    
        @Binding var isFirstResponder: Bool
        @Binding var text: String
        var textDidChange: ((String?) -> Void)?
        fileprivate var listenToChanges: Bool = false // A Boolean to make sure we don't update Bindings when SwiftUI is updating UIKit (i.e. during the `updateUIView` execution)

        init(isFirstResponder: Binding<Bool>, text: Binding<String>, textDidChange: ((String?) -> Void)?) {
            _isFirstResponder = isFirstResponder
            _text = text
            self.textDidChange = textDidChange
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            // UIKit Changed. Update SwiftUI bindings only if this method was called because of a UIKit change
            // and *not* a SwiftUI change (i.e. `updateUIView`).
            guard listenToChanges else { return }
            isFirstResponder = textField.isFirstResponder
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            // UIKit Changed. Update SwiftUI bindings only if this method was called because of a UIKit change
            // and *not* a SwiftUI change (i.e. `updateUIView`).
            guard listenToChanges else { return }
            isFirstResponder = textField.isFirstResponder
        }
        
        @objc func textChanged(_ textField: UITextField) {
            // UIKit Changed. Update SwiftUI bindings only if this method was called because of a UIKit change
            // and *not* a SwiftUI change (i.e. `updateUIView`).
            guard listenToChanges else { return }
            text = textField.text ?? ""
            textDidChange?(textField.text)
        }
    }
}

