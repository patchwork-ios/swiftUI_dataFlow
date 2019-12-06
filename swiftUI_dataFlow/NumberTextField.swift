//
//  NumberTextField.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 11/27/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI


// Issues with this approach:
// 1. It only supports Doubles...
// 2. The Binding doesn't appear to be updating properly...
// 3. You can't delete syntactical symbols like the $ or %
// 3.1 I could make it so I remove the syntactical stuff from the string before adjusting the new value... That may or may not work though cause that adjusting would happen in the "should change characters" method, which I would return true from and it would change things the old way, not the way I wanted.


struct NumberTextField: View {
    @State var value: Double = 100
    var stringBinding: Binding<String> {
        return Binding<String>.init(get: { "\(self.value)" }, set: { self.value = Double($0)! })
    }
    var textDidChange: ((String?) -> Void)?

    var body: some View {
        VStack {
            Spacer()
            TextField("", text: stringBinding)
            NumberTextFieldRepresentable(value: $value, formatter: {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                return formatter
            }())
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}

struct NumberTextField_Previews: PreviewProvider {
    @State static var num: Double = 100
    static var previews: some View {
        VStack {
            NumberTextField()
            TextField("", text: $num.stringBinding)
            Text("\(num)")
        }
        
    }
}


extension Binding where Value == Double {
    var stringBinding: Binding<String> {
        return Binding<String>.init(get: { "\(self.wrappedValue)" }, set: { self.wrappedValue = Double($0)! })
    }
}






// MARK: - NumberTextField

struct NumberTextFieldRepresentable: UIViewRepresentable {
//    enum NumberType {
//        case int(Binding<Int>)
//        case double(Binding<Double>)
//        case float(Binding<Float>)
//    }
    var value: Binding<Double>
    let formatter: NumberFormatter
    var textDidChange: ((String?) -> Void)?
//    var textDidEndEditing: (() -> Void)?

    init(value: Binding<Double>, formatter: NumberFormatter, textDidChange: ((String?) -> Void)? = nil) {
        self.value = value
        self.formatter = formatter
        self.textDidChange = textDidChange
    }

    func makeCoordinator() -> NumberTextFieldRepresentable.Coordinator {
        let coordinator = Coordinator(value: value, formatter: formatter, textDidChange: textDidChange)
        return coordinator
    }

    func makeUIView(context: UIViewRepresentableContext<NumberTextFieldRepresentable>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.text = value.wrappedValue.stringValue
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(context.coordinator.textChanged(_:)), for: .editingChanged)
        return textField
    }

     func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<NumberTextFieldRepresentable>) {
        // update UIKit based on Bindings from SwiftUI. i.e. _one of your bindings have changed_
        context.coordinator.listenToChanges = false
        uiView.text = formatter.string(from: NSNumber(value: context.coordinator.value))
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


