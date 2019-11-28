//
//  FormattableTextField.swift
//  Money Wise
//
//  Created by Benjamin Patch on 11/27/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI

// Two issues:
// 1. this doesn't allow for pretty formatting whilst the person is editing
// 2. the StringConvertible isn't working. Should change to some sort of formatter class I guess...
// Too bad we can't use Formatter and cast it as one of the "supported" formatters in order to change the value.
// Maybe I just make a NumberTextField and then a separate DateTextField and don't make it as generic...



//struct FormatterTextField<T: StringConvertible>: View {
//    @Binding var value: T
//    var textDidChange: ((String?) -> Void)?
//
//    var body: some View {
//        Text("te")
////        FormatterTextFieldRepresentable(value: $value, textDidChange: textDidChange)
//    }
//}

struct FormatterTextField_Previews: PreviewProvider {
    @State static var num: Double = 100
    static var previews: some View {
        FormatterTextFieldRepresentable(value: $num)
    }
}

extension Double: StringConvertible {
    public var stringValue: String {
        return "\(self)"
    }
    public init?(stringValue value: String) {
        if let double = Double(value) {
            self = double
        }
        return nil
    }
}








// MARK: - StringConvertable

/// A protocol that enables conversion to and from a String
public protocol StringConvertible {
    var stringValue: String { get }
    init?(stringValue value: String)
}


// MARK: - FormatterTextField

struct FormatterTextFieldRepresentable<T: StringConvertible>: UIViewRepresentable {
    @Binding var value: T
    var textDidChange: ((String?) -> Void)?
    
    init(value: Binding<T>, textDidChange: ((String?) -> Void)? = nil) {
        _value = value
        self.textDidChange = textDidChange
    }
        
    func makeCoordinator() -> FormatterTextFieldRepresentable.Coordinator {
        let coordinator = Coordinator.init(value: $value, textDidChange: textDidChange)
        return coordinator
    }
    
    func makeUIView(context: UIViewRepresentableContext<FormatterTextFieldRepresentable>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.text = value.stringValue
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(context.coordinator.textChanged(_:)), for: .editingChanged)
        return textField
    }
    
    
    // MARK: - SwiftUI -> UIKit
    
     func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<FormatterTextFieldRepresentable>) {
        // update UIKit based on Bindings from SwiftUI. i.e. _one of your bindings have changed_
        context.coordinator.listenToChanges = false
        uiView.text = value.stringValue
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
    
        @Binding var value: T
        var textDidChange: ((String?) -> Void)?
        var lastValue: String? = nil
        var listenToChanges = false
        
        init(value: Binding<T>, textDidChange: ((String?) -> Void)?) {
            _value = value
            self.textDidChange = textDidChange
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
            if let newValue = T(stringValue: newText) {
                if listenToChanges {
                    // update our binding if we're not getting updated by a SwiftUI rendering
                    value = newValue
                }
                return true
            } else {
                // if unable to convert to T type, don't allow the textChange
                return false
            }
        }
        
        @objc func textChanged(_ textField: UITextField) {
            guard listenToChanges else { return }
            textDidChange?(textField.text)
        }
    }
}


