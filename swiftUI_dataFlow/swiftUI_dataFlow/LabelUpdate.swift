//
//  LabelUpdate.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 10/29/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI

struct LabelUpdate: View {
    @Binding var sizeModel: SizeModel
    var plusAction: () -> Void

    var body: some View {
        HStack {
            Button(action: plusAction) { Text("+") }
            Text("\(sizeModel.size)")
//            TextField("", text: $size).frame(width: 50, height: 30, alignment: .center)
            Button(action: { self.sizeModel.size -= 1 }) { Text("-") }
        }
    }
}


class SizeModel: ObservableObject, Equatable, Hashable {
    static func == (lhs: SizeModel, rhs: SizeModel) -> Bool {
        lhs.size == rhs.size
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(size)
    }
    
    @Published var size: Int
    init(_ size: Int) {
        self.size = size
    }
}

class Model1: ObservableObject {
    @Published var sizes: Set<SizeModel> = [SizeModel(0), SizeModel(2), SizeModel(5)]
    static var singleton = Model1()
}

struct Wrapper: View {
    @ObservedObject var my = Model1()

    var body: some View {
        Text("")
//        ForEach(
////        ForEach($my.sizes) { sizeModel in
//////            return Text("ts")
//////            LabelUpdate(sizeModel: sizeModel, plusAction: {
//////                sizeModel.wrappedValue.size += 1
//////            })
////        }
    }
}

struct LabelUpdate_Previews: PreviewProvider {
    // Static state wasn't working...
    static var previews: some View {
        Wrapper()
    }
}
