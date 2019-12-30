//
//  TypeListRow.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import SwiftUI

struct TypeListRow: View {
  var type: ObjectType
  
  var body: some View {
    ZStack(alignment: .bottomLeading) {
      Image(type.thumbnail)
        .resizable()
        .aspectRatio(contentMode: .fit)
      Text(type.name)
        .font(.headline)
        .foregroundColor(.white)
        .padding()
    }
  }
}

struct TypeListRow_Preview: PreviewProvider {
  static var previews: some View {
    TypeListRow(type: .sample(id: 1))
  }
}
