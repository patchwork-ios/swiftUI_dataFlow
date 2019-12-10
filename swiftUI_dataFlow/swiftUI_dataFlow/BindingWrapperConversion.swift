//
//  BindingWrapperConversion.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 11/30/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI
import Combine

class Obj: ObservableObject {
    var dbl: Double = 199 {
        didSet {
            print("`Obj.dbl` was set")
            objectWillChange.send()
        }
    }
    var objectWillChange = PassthroughSubject<Void, Never>()
}

struct AnyTextField: View {
    var placeholder: String
    var get: () -> String
    /// Return whether the set was successful or not.
    var set: (String) -> Bool
    
    /// The string that the user edits while text field is first responder.
    /// We don't update the string based on the `convertFromString` completion
    /// because we if we constantly reformat the string while the user is editing the string
    /// it ends up not allowing the user to delete certain parts of the string.
    /// i.e. If the string "2.4" formats to "2.4%". If the user deletes the "%" and we reformat immediately afterward
    /// then the string goes to "2.4%" instead of "2.4"
    @State private var lastValidString: String = ""
    @State private var failureToggle: Bool = false
    var objectWillChange = PassthroughSubject<Void, Never>()

    init(_ placeholder: String, get: @escaping () -> String, setSuccessfull set: @escaping (String) -> Bool) {
        self.placeholder = placeholder
        self.get = get
        self.set = set
        _lastValidString = State(initialValue: get())
    }
    
    // A binding to abstract changes to the string value so we can ignore invalid changes.
    var stringBinding:  Binding<String> {
        return Binding<String>(get: {
            print("`AnyTextField.stringBinding` get called.")
            // By adding a reference to the @State variable `textFieldWasEditing` in here it forces a re-get when the guard on line 52 fails (i.e. the user typed in an invalid character, so we want to ignore that change).
            let _ = self.failureToggle
            return self.lastValidString
        }) { (newValue) in
            guard self.set(newValue) else {
                // Change a state variable that this binding's get is using so the textField will re-get the binding's getter value and return the `lastValidString`, thus ignoring any invalid changes.
                self.failureToggle.toggle()
                return
            } // ignore invalid changes
            self.lastValidString = newValue
        }
    }

    var body: some View {
        TextField(placeholder, text: stringBinding) {
            // format the string once the user is done editing it.
            self.lastValidString = self.get()
        }
    }
    
}

struct AnyTextField_Previews: PreviewProvider {
    @ObservedObject static var my = Obj()
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    static var previews: some View {
        VStack {
            AnyTextField("placeholder", get: {
                return formatter.string(from: NSNumber(value: self.my.dbl)) ?? ""
            }) { (newString) -> Bool in
                formatter.numberStyle = .percent
                guard let newDbl = formatter.number(from: newString)?.doubleValue else { return false }
                self.my.dbl = newDbl
                return true
            }.background(Color.gray)
        }
    }
}















struct TF<T: Any>: View {
    var convertToString: (T) -> String?
    var convertFromString: (String) -> T?
    var value: Binding<T>
    var placeholder: String
    
    /// The string that the user edits while text field is first responder.
    /// We don't update the string based on the `convertFromString` completion
    /// because we if we constantly reformat the string while the user is editing the string
    /// it ends up not allowing the user to delete certain parts of the string.
    /// i.e. If the string "2.4" formats to "2.4%". If the user deletes the "%" and we reformat immediately afterward
    /// then the string goes to "2.4%" instead of "2.4"
    @State var lastValidString: String = ""
    @State var isEditingTextField: Bool
    
    // A binding to abstract changes to the string value so we can ignore invalid changes.
    var stringBinding:  Binding<String> {
        return Binding<String>(get: {
            return self.lastValidString
        }) { (newValue) in
            guard let newT = self.convertFromString(newValue) else { return } // ignore invalid changes
            self.lastValidString = newValue
            self.value.wrappedValue = newT
        }
    }
//    var fancyString: Binding<String> {
//        Binding<String>(get: {
//            "\(self.my.dbl)"
//        }, set: {
//            guard let value = convertFromString($0) else { return }
//            self.value.wrappedValue =
//        })
//    }

    var body: some View {
        TextField(placeholder, text: stringBinding, onEditingChanged: { self.isEditingTextField = $0 }) {
            guard let formattedString = self.convertToString(self.value.wrappedValue) else { return } // assuming the value is up to date at this point...
            // set the lastValidString to be the formatted string
            self.lastValidString = formattedString
            
        }
    }
    
}

struct BindingWrapperConversion: View {
    init(my: Obj) {
        self.my = my
        self.string = "\(my.dbl)"
    }

    @ObservedObject var my: Obj
    @State var isEditingTextField: Bool = false
    @State var string: String = ""
    var stringBinding:  Binding<String> {
        return Binding<String>(get: {
            return self.string
        }) { (newValue) in
            guard let _ = Double(newValue) else { return } // ignore invalid changes
            self.string = newValue
        }
    }


    var body: some View {
        let binding = Binding<String>(get: { "\(self.my.dbl)" }, set: { self.my.dbl = Double($0)! })
        return VStack {
            Text("\(my.dbl)")
            TextField("", text: isEditingTextField ? stringBinding : binding, onEditingChanged: {
                self.isEditingTextField = $0
            }) {
                binding.wrappedValue = self.stringBinding.wrappedValue
                self.string = binding.wrappedValue
            }
        }
    }
}



//struct BindingWrapperConversion_Previews: PreviewProvider {
//    @ObservedObject static var my = Obj()
//    static var previews: some View {
//        BindingWrapperConversion(my: my)
//    }
//}


//struct TextFieldBindingConversion<T: Any> {
//    var lastValidValue: String
//    var editableText: Binding<String>
//
//
//    init(_ binding: Binding<T>) {
//
//    }
//}
