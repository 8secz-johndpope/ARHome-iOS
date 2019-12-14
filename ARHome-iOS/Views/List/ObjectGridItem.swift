//
//  ObjectGridItem.swift
//  ARHome-iOS
//
//  Created by 高健 on 2019/12/13.
//  Copyright © 2019 高健. All rights reserved.
//

import SwiftUI

struct ObjectGridItem: View {
  let object: Object
  
  var body: some View {
    VStack(alignment: .leading) {
      Image(object.imageName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 150, height: 150)
        .shadow(radius: 8)
      Text(object.name)
        .font(.footnote)
        .bold()
    }
  }
}

struct ObjectGridItem_Previews: PreviewProvider {
  static var previews: some View {
    ObjectGridItem(object: .sample(id: 1))
  }
}
