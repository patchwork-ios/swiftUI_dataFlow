//
//  FormattableTextField.swift
//  Money Wise
//
//  Created by Benjamin Patch on 11/27/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI

//class Obj: ObservableObject {
//    var str = "string" {
//        didSet {
//            print("`Obj.str` was set")
//            objectWillChange.send()
//        }
//    }
//    var dbl: Double = 199 {
//        didSet {
//            print("`Obj.dbl` was set")
//            objectWillChange.send()
//        }
//    }
//    var objectWillChange = PassthroughSubject<Void, Never>()
//    // variable that wraps the double and converts it to a string and updates the publisher with the publisher.didChange
//
//}

struct FormatterTextFieldRepresentableView: View {
    @ObservedObject var obj: Obj
    @State var isEditing: Bool = false

    var body: some View {
        VStack {
            FormatterTextFieldRepresentable(placeholder: "", isEditing: $isEditing, number: { () -> NSNumber in
                NSNumber(value: self.obj.dbl)
            }, unformattedStringFormatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.decimal
                formatter.minimumFractionDigits = 2
                return formatter
            }(), formattedTextFormatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                return formatter
            }()) { (number) in
                self.obj.dbl = number.doubleValue
            }.fixedSize(horizontal: false, vertical: true)
            Button(action: {
                self.isEditing.toggle()
            }) { Text(self.isEditing ? "End Editing" : "Begin Editing") }
        }.padding()
    }
}


struct FormatterTextField_Previews: PreviewProvider {
    @State static var obj = Obj()
    static var previews: some View {
        FormatterTextFieldRepresentableView(obj: obj)
    }
}






// MARK: - StringConvertable

/// A protocol that enables conversion to and from a String
public protocol FormattingTextFieldDelegate {
    var placeholder: String { get }
    /// The value you wish the user to interact with when editing the textField.
    /// For instance, you may remove currency formatting on a double and provide "135.50" as the unformattedString,
    /// while the formattedString would be "$135.50".
    func unformattedString() -> String
    /// Return a fancily formatted string to be inserted upon ending first responder.
    /// For instance the user has typed "135.5" and hits return.
    /// You might return a new string with currency formatting like this: "$135.50"
    /// If no unformattesString is provided, then return a formatted version of the  `unformattedString`.
    func formattedString(from unformattedString: String?) -> String
    /// Whether the newly input text sholud be accepted. A direct relationship with `textField(shouldChangeCharacters: inRange:)`
    /// Expected implementation is to make sure the new string can be properly converted to the value type of the binding in mind. Return true if conversion succeeds, else return false.
    func shouldAcceptChange(_ newString: String) -> Bool
    /// Called after each successfull change of the text (after being approved by `shouldAcceptChange`).
    /// Expected implementation is to convert the String to the type of your binding and then assign your binding to that value.
    func updateBinding(from string: String)
}

fileprivate struct FormattingTextFieldDefaultDelegate: FormattingTextFieldDelegate {
    var placeholder: String
    var unformattedStringCompletion: (() -> String)
    var formattedStringCompletion: ((String) -> String)?
    var shouldAcceptChangeCompletion: ((String) -> Bool)
    var updateBindingCompletion: ((String) -> Void)
    
    func unformattedString() -> String {
        return unformattedStringCompletion()
    }
    
    func formattedString(from unformattedString: String?) -> String {
        return formattedStringCompletion?(unformattedString ?? self.unformattedString()) ?? self.unformattedString()
    }
    
    func shouldAcceptChange(_ newString: String) -> Bool {
        return shouldAcceptChangeCompletion(newString)
    }
    
    func updateBinding(from string: String) {
        updateBindingCompletion(string)
    }
    
    
}

// MARK: - FormatterTextField

struct FormatterTextFieldRepresentable: UIViewRepresentable {
    var delegate: FormattingTextFieldDelegate
    var isEditing: Binding<Bool>?
    
    init(delegate: FormattingTextFieldDelegate, isEditing: Binding<Bool>?) {
        self.delegate = delegate
        self.isEditing = isEditing
    }
        
    init(placeholder: String, isEditing: Binding<Bool>? = nil,  unformattedString: @escaping (() -> String), formattedString: ((String) -> String)? = nil, shouldAcceptChange: @escaping ((String) -> Bool), updateBinding: @escaping ((String) -> Void)) {
        delegate = FormattingTextFieldDefaultDelegate(placeholder: placeholder, unformattedStringCompletion: unformattedString, formattedStringCompletion: formattedString, shouldAcceptChangeCompletion: shouldAcceptChange, updateBindingCompletion: updateBinding)
        self.isEditing = isEditing
    }
    
    init(placeholder: String, isEditing: Binding<Bool>? = nil, number: @escaping (() -> NSNumber), unformattedStringFormatter: NumberFormatter, formattedTextFormatter: NumberFormatter, updateBinding: @escaping ((NSNumber) -> Void)) {
        delegate = FormattingTextFieldDefaultDelegate(placeholder: placeholder, unformattedStringCompletion: { () -> String in
            return  unformattedStringFormatter.string(from: number()) ?? "error"
        }, formattedStringCompletion: { (unformattedString) -> String in
            return formattedTextFormatter.string(from: number()) ?? "error"
        }, shouldAcceptChangeCompletion: { (newText) -> Bool in
            return unformattedStringFormatter.number(from: newText) != nil
        }, updateBindingCompletion: { (newText) in
            guard let number = unformattedStringFormatter.number(from: newText) else { return }
            updateBinding(number)
        })
        self.isEditing = isEditing
    }
    
    func makeCoordinator() -> FormatterTextFieldRepresentable.Coordinator {
        let coordinator = Coordinator.init(delegate: delegate, isEditing: isEditing)
        return coordinator
    }
    
    func makeUIView(context: UIViewRepresentableContext<FormatterTextFieldRepresentable>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.text = delegate.formattedString(from: nil)
        textField.placeholder = delegate.placeholder
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(context.coordinator.textChanged(_:)), for: .editingChanged)
        if isEditing?.wrappedValue ?? false {
            textField.becomeFirstResponder()
        }
        return textField
    }
    
    
    // MARK: - SwiftUI -> UIKit
    
     func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<FormatterTextFieldRepresentable>) {
        // update UIKit based on Bindings from SwiftUI. i.e. _one of your bindings have changed_
        context.coordinator.listenToChanges = false
        let delegate = context.coordinator.delegate
        if let isEditing = isEditing?.wrappedValue
        {
            if isEditing && !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
                uiView.text = delegate.unformattedString()
            } else if !isEditing && uiView.isFirstResponder {
                uiView.resignFirstResponder()
                uiView.text = delegate.formattedString(from: nil)
            }
        }
        if let text = uiView.text, delegate.formattedString(from: text) != delegate.formattedString(from: nil) {
            // text binding was changed, update the textField's text.
            uiView.text = uiView.isFirstResponder ? delegate.unformattedString() : delegate.formattedString(from: nil)
        }
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
    
        var delegate: FormattingTextFieldDelegate
        var isEditing: Binding<Bool>?
        var listenToChanges = false
        
        init(delegate: FormattingTextFieldDelegate, isEditing: Binding<Bool>?) {
            self.delegate = delegate
            self.isEditing = isEditing
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            guard listenToChanges else { return }
            textField.text = delegate.unformattedString()
            isEditing?.wrappedValue = true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let text = textField.text ?? ""
            let newText: String
            if text.isEmpty {
                newText = string
            } else if let textRange = Range(range, in: text) {
                newText = text.replacingCharacters(in: textRange, with: string)
            } else {
                return false // unable to resolve Range, so fail
            }
            if delegate.shouldAcceptChange(newText) && listenToChanges {
                return true
            } else {
                // if unable to convert to T type, don't allow the textChange
                return false
            }
        }
        
        @objc func textChanged(_ textField: UITextField) {
            guard let text = textField.text, listenToChanges else { return }
//            delegate.updateBinding(from: text)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            guard let text = textField.text, listenToChanges else { return }
            textField.text = delegate.formattedString(from: text)
            delegate.updateBinding(from: text)
            isEditing?.wrappedValue = false
        }
    }
}


