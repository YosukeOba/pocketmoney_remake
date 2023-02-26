//
//  InputButtonStyle.swift
//  pocketmoney_remake
//
//  Created by 大場　洋介 on 2022/02/01.
//

import SwiftUI

struct numButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 60, height: 60)
            .imageScale(.large)
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(Circle())
    }
}

struct InputButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title)
            .multilineTextAlignment(.center)
            .padding()
            .foregroundColor(Color.primary)
            .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 1)
        )
            .padding()
    }
}
