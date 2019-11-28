//
//  NumberTextField.swift
//  swiftUI_dataFlow
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



struct NumberTextField: View {
    @Binding var value: Double
    var textDidChange: ((String?) -> Void)?

    var body: some View {
        Text("te")
//        NumberTextFieldRepresentable(value: $value, textDidChange: textDidChange)
    }
}

struct NumberTextField_Previews: PreviewProvider {
    @State static var num: Double = 100
    static var previews: some View {
        NumberTextField(value: $num)
    }
}







// MARK: - NumberTextField

struct NumberTextFieldRepresentable: UIViewRepresentable {
//    enum NumberType {
//        case int(Binding<Int>)
//        case double(Binding<Double>)
//        case float(Binding<Float>)
//    }
    @Binding var value: Double
    let formatter: NumberFormatter
    var textDidChange: ((String?) -> Void)?
//    var textDidEndEditing: (() -> Void)?
    
    init(value: Binding<Double>, formatter: NumberFormatter, textDidChange: ((String?) -> Void)? = nil) {
        _value = value
        self.formatter = formatter
        self.textDidChange = textDidChange
    }
        
    func makeCoordinator() -> NumberTextFieldRepresentable.Coordinator {
        let coordinator = Coordinator(value: $value, formatter: formatter, textDidChange: textDidChange)
        return coordinator
    }
    
    func makeUIView(context: UIViewRepresentableContext<NumberTextFieldRepresentable>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.text = value.stringValue
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(context.coordinator.textChanged(_:)), for: .editingChanged)
        return textField
    }
    
     func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<NumberTextFieldRepresentable>) {
        // update UIKit based on Bindings from SwiftUI. i.e. _one of your bindings have changed_
        context.coordinator.listenToChanges = false
        uiView.text = value.stringValue
        context.coordinator.listenToChanges = true
    }

    
    class Coordinator: NSObject, UITextFieldDelegate {
    
        @Binding var value: Double
        var textDidChange: ((String?) -> Void)?
        var lastValue: String? = nil
        var formatter: NumberFormatter
        var listenToChanges = false
        
        init(value: Binding<Double>, formatter: NumberFormatter, textDidChange: ((String?) -> Void)?) {
            _value = value
            self.formatter = formatter
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
            if let newValue = formatter.number(from: newText) {
                if listenToChanges {
                    // update our binding if we're not getting updated by a SwiftUI rendering
                    value = newValue.doubleValue
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


