//
//  LoginView.swift
//  pocketmoney_remake
//
//  Created by Yosuke Oba on 2023/03/08.
//

import FirebaseAuth
import FirebaseCore
import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    @AppStorage("isLoginView") var isLoginView: Bool = true

    var body: some View {
        VStack(spacing: 30) {
            Group {
                Text("新規登録/ログインしましょう！")
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
                               showAlert = true
                           } else if password == "" {
                               errorMessage = "パスワードを入力してね"
                               showAlert = true
                           } else {
                               Auth.auth().signIn(withEmail: self.email, password: self.password) { authResults, _ in
                                   if authResults?.user != nil {
                                       isLoginView = false
                                   } else {
                                       Auth.auth().createUser(withEmail: self.email, password: self.password) { authResult, _ in
                                       }
                                       errorMessage = "新規登録しました"
                                       showAlert = true
                                       isLoginView = false
                                   }
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
                Button(action: {
                    do {
                        try Auth.auth().signOut()
                    } catch let error as NSError {
                        print(error)
                    }
                }, label: {
                    Text("ログアウト")
                })
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("エラー"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
