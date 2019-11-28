//
//  BindingTest.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 10/19/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Global Data

var item0 = BudgetItem(name: "test State", amount: "100")
var item = BudgetItem(name: "Second Budget Item", amount: "10000")


// MARK: Model BudgetItem object

class BudgetItem: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String
    @Published var amount: String
    init(name: String, amount: String) {
        self.name = name
        self.amount = amount
    }
}


// MARK: - BindingTestView

struct BindingTest: View {
    /// The bindings act differently when all are present in the same view than if they are the only one in the view... 🤯
    @State private var stateItem = item0
    @ObservedObject var observedItem = item0
    @State private var arrayItem = [item0]

//    @ObservedObject var observedArrayItem = [item0] // Does not compile because Array doesn't conform to `ObservedObject`. The solution to this is MVVM (See `mvvmObservedObject`)
    init() {
    }
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                // I made the subViews variables instead of declaring them here so it is easier to comment out one or the other. I got into a state where when they were all visible they all acted the same way... so this makes it so you can validate behavior by commenting out all but one, or all but two, etc.
                HStack {
                    Text("Source of Truth").font(.title)
                    Text(item0.amount).font(.title)
                }
                Spacer(minLength: 24)
                bindingSubview // ❌
                stateArrayBinding // ❌ ✅
                observedObjectBinding // ✅
                publishedBinding // ✅
                mvvmObservedObject // 😇 ✅
                environmentBinding // ✅

            }
        }
        .padding()
            // if you want some fun colors, then you can uncomment this gradient:
//            .background(LinearGradient(gradient: Gradient(colors: [.blue, .yellow, .green]), startPoint: .topLeading, endPoint: .bottomTrailing))
//        .edgesIgnoringSafeArea(.all)
    }

    
    // MARK: - SubView Intiailizations
    
    /// Notice that @State ignores the `ObservableObject` protocol conformance and the @Binding to that @State inherits that ignorance. In other words, bindings to the state will not update when `@Published` variables of that object are updated.
    var bindingSubview: some View {
        VStack {
            Text("Binding to @State of Observed Object")
                .bold().multilineTextAlignment(.center)
            BindingSubView(item: $stateItem)
        }
    }
    
    /// Notice that the array is `@State`, but the objects inside of them have not been attached to an `@State` and its ignorance, so the `@Binding` to the `ObservableObject` is able to utilize the `ObservableObject` protocol conformance. 🤯
    var stateArrayBinding: some View {
        VStack {
            Text("\nBinding to item in @State array of Observed Object")
                .bold().multilineTextAlignment(.center)
            BindingSubView(item: $arrayItem[0])
        }
    }
    
    /// Once an `@ObservedObject` always an @ObservedObject (unless you pass in the `@Published` variables of the `ObservableObject`). `@ObservedObject` utilizes the `ObservableObject` protocol, so everything will update as expected.
    var observedObjectBinding: some View {
        VStack {
            Text("\n@ObservedObject from another @ObservedObject")
                .bold().multilineTextAlignment(.center)
            
            ObservedObjectSubView(item: observedItem)
        }
    }
    
    /// Another means of binding is to the variabls on an `@ObservedObject`. Binding seems to be intended to be used with a fileprivate `@State` variable or an `@Published` property on an `ObservableObject` variable.
    var publishedBinding: some View {
        VStack {
            Text("\n@Bindings from an @ObservedObjects @Published properties")
                .bold().multilineTextAlignment(.center)
            BindingFromObservedObjectSubView(amount: $observedItem.amount, name: $observedItem.name)
        }
    }
    
    /// MVVM is a design pattern: `Model -> ViewModel(container for all Model objects) -> View`. It essentially means each View has a ViewModel class that it references and that ViewModel class conforms to `ObservableObject`. Every `Model` object variable the View needs will exist on this ViewModel as `@Published var`s. This design pattern lends itself very well to SwiftUI because of some of the funkiness of when you can use `@Binding` vs `@ObservedObject` vs `@State` (like for an array of `ObservableObject`s).
    var mvvmObservedObject: some View {
        VStack {
            Text("\nMVVM: @ObservedObject to a view-specific ViewModel object.")
                .bold().multilineTextAlignment(.center)
            MVVMObservedObjectSubView(model: MVVMObservedObjectViewModel(item: item0))
        }
    }
    
    /// This is another valid option to pass data between Views. Once it is added to the environment of a view, that object is accessible by ALL subviews of that view 🎉.
    /// Environment doesn't seem to support holding multiple instances of the same type (at least I couldn't get it to work...).
    /// NOTE: You can add an environment variable to the first view by adding it to the initial View created in the Scene Delegate's `...willConnectTo...` method.
    var environmentBinding: some View {
        VStack {
            Text("\n@EnvironmentObject binding to an ObservableObject")
                .bold().multilineTextAlignment(.center)
            EnvironmentObjectBindingView()
                .environmentObject(item0)
                .environmentObject(item) // doesn't seem to work?
        }
    }
}


// MARK: - Binding Subview

struct BindingSubView: View {
    @Binding var item: BudgetItem
    var body: some View {
        LayoutView(nameTextField: TextField("name placeholder", text: $item.name), amountTextField: TextField("amount placeholder", text: $item.amount), nameText: Text(item.name), amountText: Text(item.amount))
    }
}


// MARK: - ObservedObject Subview

struct ObservedObjectSubView: View {
    @ObservedObject var item: BudgetItem
    var body: some View {
        LayoutView(nameTextField: TextField("name placeholder", text: $item.name), amountTextField: TextField("amount placeholder", text: $item.amount), nameText: Text(item.name), amountText: Text(item.amount))
    }
}


// MARK: - Binding from ObservedObject Subview

struct BindingFromObservedObjectSubView: View {
    @Binding var amount: String
    @Binding var name: String // this can be a pain this option could be with a lot of published properties on an object.
    var body: some View {
        LayoutView(nameTextField: TextField("name placeholder", text: $name), amountTextField: TextField("amount placeholder", text: $amount), nameText: Text(name), amountText: Text(amount))
    }
}


// MARK: - MVVM Model Object

class MVVMObservedObjectViewModel: ObservableObject {
    // @Published lives in the model layer (not the view layer) and is the best way to conform to `ObservableObject`. The alternative is to set a variable that changes have happened each time any variable updates on the Object.
    @Published var item: BudgetItem
    init(item: BudgetItem) {
        self.item = item
    }
}


// MARK: - MVVM ObservedObject SubView

/// MVVM allows us to make the ViewModel an `@ObservedObject` and easily/cleanly get bindings out of it's variables.
struct MVVMObservedObjectSubView: View {
    @ObservedObject var model: MVVMObservedObjectViewModel
    var body: some View {
        LayoutView(nameTextField: TextField("name placeholder", text: $model.item.name), amountTextField: TextField("amount placeholder", text: $model.item.amount), nameText: Text(model.item.name), amountText: Text(model.item.amount))
    }
}


// MARK: - EnvironmentObject Binding Subview

struct EnvironmentObjectBindingView: View {
    var body: some View {
        EnvironmentBindingSubView() // To show that the environment variable is accessible to subViews and not just this view. You could do the same thing `EnvironmentBindingSubView` does in this View and it would work the same.
    }
}


// MARK: - EnvironmentObject Binding Sub-subview

struct EnvironmentBindingSubView: View {
    @EnvironmentObject var item: BudgetItem
    @EnvironmentObject var item1: BudgetItem

    var body: some View {
        LayoutView(nameTextField: TextField("name placeholder", text: $item.name), amountTextField: TextField("amount placeholder", text: $item.amount), nameText: Text(item.name), amountText: Text(item.amount))
        // Using `item1 instead of item yeilds the same result... 😢 so I'm commenting it out for cleanliness
//        LayoutView(nameTextField: TextField("name placeholder", text: $item1.name), amountTextField: TextField("amount placeholder", text: $item1.amount), nameText: Text(item1.name), amountText: Text(item1.amount))

    }
}


// MARK: - PreviewProvider

struct BindingTest_Previews: PreviewProvider {
    static var previews: some View {
        BindingTest()
    }
}

struct LayoutView: View {
    var nameTextField: TextField<Text>
    var amountTextField: TextField<Text>
    var nameText: Text
    var amountText: Text
    var latestTimeViewWasRendered: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "s:S"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("TextFields: ").italic()
                nameTextField
                    .frame(width: 100, height: 30, alignment: .center)
                    .background(Color.init(white: 0.98))
                    .multilineTextAlignment(.center)
                amountTextField
                    .frame(width: 100, height: 30, alignment: .center)
                    .background(Color.init(white: 0.98))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            HStack {
                Spacer()
                Text("Labels:").italic()
                nameText
                .frame(width: 100, height: 30, alignment: .center)
                amountText
                .frame(width: 100, height: 30, alignment: .center)
                Spacer()
            }
//            Text(latestTimeViewWasRendered) // Uncomment this to see which Views are being updated at the same time.
        }
    }
}
