//
//  BindingAssignment.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 11/1/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI

//struct BindingAssignment: View {
//    @Binding var isFirstResponder: Bool
//    
//    var body: some View {
//        HStack {
//            Text(String(describing: isFirstResponder))
//            BindingAssignmentSubView(binding: &isFirstResponder)
//        }
//    }
//}
//
//struct BindingAssignmentSubView: View {
//    @Binding var outsideIsFirstResponder: Bool
//    var isFirstResponder: Binding<Bool> {
//        Binding<Bool>(get: { () -> Bool in
//                   print("SubView get")
//            return self.outsideIsFirstResponder
//               }, set: { (newValue) in
//                   print("SubView set")
//                self.outsideIsFirstResponder = newValue
//               })
//    }
//    
//    init(binding: inout Binding<Bool>) {
//        _outsideIsFirstResponder = binding
//        binding = _outsideIsFirstResponder
//    }
//    
//    var body: some View {
//        Toggle(isOn: isFirstResponder) {
//            Text("binding")
//        }
//    }
//}
//
//
//struct BindingAssignment_Previews: PreviewProvider {
//    static var bool: Bool = true
//    static var previews: some View {
//        BindingAssignment(isFirstResponder: Binding<Bool>(get: { () -> Bool in
//            print("superView get")
//            return bool
//        }, set: { (newValue) in
//            print("superView set")
//            bool = newValue
//        }))
//    }
//}
