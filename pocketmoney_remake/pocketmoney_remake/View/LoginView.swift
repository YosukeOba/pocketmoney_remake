//
//  LoginView.swift
//  pocketmoney_remake
//
//  Created by Yosuke Oba on 2023/03/08.
//

import FirebaseAuth
import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 30) {
            Group {
                Text("ログインしましょう！")
                TextField("メール", text: $email)
                    .keyboardType(.emailAddress)
                    .font(.body)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 1)
                    )
                    .padding()
                SecureField("パスワード", text: $password)
                    .keyboardType(.alphabet)
                    .font(.body)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 1)
                    )
                    .padding()
                Button(action: {
                           if email == "" {
                               errorMessage = "メールアドレスを入力してね"
                           } else if password == "" {
                               errorMessage = "パスワードを入力してね"
                           } else {
                               Auth.auth().signIn(withEmail: self.email, password: self.password) { authResults, _ in
                                   if authResults?.user != nil {
                                       print(authResults)
                                   }
                                   print("nil")
                                   print(authResults)
                               }
                           }
                       },
                       label: {
                           Text("ログイン")
                               .font(.title)
                               .multilineTextAlignment(.center)
                               .padding()
                       })
                       .overlay(
                           RoundedRectangle(cornerRadius: 10)
                               .stroke(Color.blue, lineWidth: 1)
                       )
                       .padding()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
