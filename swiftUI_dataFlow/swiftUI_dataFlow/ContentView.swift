//
//  DataFlow.swift
//  DataFlowSwiftUI
//
//  Created by Benjamin Patch on 10/17/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI

// MARK: - Mock Data Holder

struct MockDataHolder {
    static var item0 = BudgetItem(name: "Groceries", amount: "400")
    static var item1 = BudgetItem(name: "Gas", amount: "100")
    static var item2 = BudgetItem(name: "Utilities", amount: "200")
    static var item3 = BudgetItem(name: "Rent", amount: "1500")
}


// MARK: - Main View

struct MainView: View {
    var body: some View {
        NavigationView {
            MyList(viewModel: MyListViewModel(items: [MockDataHolder.item0, MockDataHolder.item1, MockDataHolder.item2, MockDataHolder.item3]))
            .navigationBarTitle("Budget Items")
        }
    }
}


// MARK: - View Model for MyList

class MyListViewModel: ObservableObject {
    @Published var list: [BudgetItem]
    
    init(items: [BudgetItem]) {
        list = items
    }
}


// MARK: - MyList View

struct MyList: View {
    var viewModel: MyListViewModel
    /// SwiftUI lends itself well to the MVVM pattern (Model - View - ViewModel).
    /// MVVM is where there is a View binds with a ViewModel, which updates the Model layer. For SwiftUI, MVVM looks like this, where you have a model object for the View and that model object publishes it's variables so the View can bind to those published variables.
    /// For some situations (like the `BudgetCell` and the `BudgetDetailView`) you can just pass in an `ObservedObject` and that works fine. But the line below this does not compile, because Array does not coform to `ObservedObject` currently. But if we put that array in a ViewModel class and make that array `@Published` then we can get the proper bindings to it.
    /// You might be thinking, well lets make the array an `@Binding`, which would compile! If that's what you're thinking, then try it! You'll run into some problems, though...
    /// Using @Binding works, but makes it hard to get in to this page without originating from an `@State`, which we don't really want our original list to be. `@State` should only be accessible within the View it is declared (and its subviews via `@Binding`), thus it should always be declared `private`: `@State private var myVar: SomeType`.
    /// I said "`@Binding` makes it hard to get to this page without originating from an `@State`". To explain that... the only way to get an `@Binding` to an `ObservableObject` that I have found thus far is to create an `@State` array of your `ObservableObject` type and then pass in the binding to an item in the array. (NOTE: You can also pass in an `@ObservedObject` via that same code path, which is probably better because it is more consistent).

    var body: some View {
        List(viewModel.list) { item in
            BudgetCell(item: item)
        }
    }
}


// MARK: - BudgetCell

struct BudgetCell: View {
    @ObservedObject var item: BudgetItem
    
    var body: some View {
        NavigationLink(destination: BudgetDetailView(item: item)) {
            HStack {
                Text(item.name)
                Spacer()
                Text(item.amount)
            }
        }
    }
}


// MARK: - Budget Detail View

struct BudgetDetailView: View {
    @ObservedObject var item: BudgetItem
    
    var body: some View {
        HStack {
            TextField("Name", text: $item.name)
            TextField("amount", text: $item.amount)
        }
    }
}


// MARK: - Budget Item Model

//class BudgetItem: ObservableObject, Identifiable {
//    let id = UUID()
//    @Published var name: String
//    @Published var amount: String
//    init(name: String, amount: String) {
//        self.name = name
//        self.amount = amount
//    }
//}


// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
