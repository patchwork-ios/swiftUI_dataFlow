//
//  HelpOthers.swift
//  swiftUI_dataFlow
//
//  Created by Benjamin Patch on 12/4/19.
//  Copyright © 2019 Patchwork. All rights reserved.
//

import SwiftUI

struct HelpOthers: View {
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text("product.formattedSize")
                    .minimumScaleFactor(0.25)
                    .lineLimit(1)
                    .frame(width: geometry.size.width/2, height: 100, alignment: .center)
                
                Text("product.formattedPrice")
                    .minimumScaleFactor(0.25)
                    .lineLimit(1)
                    .frame(width: geometry.size.width/2, height: 100, alignment: .center)
            }
            .frame(minWidth: 20, maxWidth: .infinity, alignment: .trailing)
                
            .font(.title)
        }
    }
}

struct HelpOthers_Previews: PreviewProvider {
    static var previews: some View {
        HelpOthers()
    }
}
