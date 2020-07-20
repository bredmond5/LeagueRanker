//
//  HorizontalButton.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/13/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct SpanningLabel: View {
    let color: Color
    let content: String
    
    init(color: Color, content: String) {
        self.content = content
        self.color = color
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text(content)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 12)
                
            Spacer()
            }
        .background(color)
        .cornerRadius(4)
            
    }
}
