//
//  LoginView.swift
//  SignIn with Apple using Firebase
//
//  Created by mohammad mugish on 05/12/19.
//  Copyright © 2019 mohammad mugish. All rights reserved.
//


import SwiftUI
import AuthenticationServices
import CryptoKit

struct LoginView: View {
    
    @Environment(\.window) var window : UIWindow?
    @EnvironmentObject var signInWithAppleManager : SignInWithAppleManager
       
    @State private var signInWithAppleDelegates : SignInWithAppleDelegates! = nil
       
    
    @State private var isAlertPresented = false
    @State private var errorDescription = ""
    var currentNonce: String = ""
    
    
    init(){
        currentNonce = randomNonceString()
    }
    
    var body: some View {
       
        SignInWithAppleButton().frame(width: 280, height: 60)
            .padding()
            .onTapGesture {
                self.showAppleLogin()
            }
    }
    
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if length == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
   func showAppleLogin(){

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(currentNonce)
    
        performSignIn(using: [request])
    }
    
    private func performSignIn(using requests : [ASAuthorizationRequest]){

        signInWithAppleDelegates = SignInWithAppleDelegates(window: window, nonce: currentNonce, onSignedIn: { (result) in
            switch result {
                
            case .success(let userId):
                 self.signInWithAppleManager.isUserAuthenticated = .signedIn
                               print("userId[0] = \(userId[0])")
                               print("userId[1] = \(userId[1])")
                               print("userId[2] = \(userId[2])")
                 print("Currnet Nonce \(self.currentNonce)")
                 
                 UserDefaults.standard.set(self.currentNonce, forKey: "CurrentNonce")
                UserDefaults.standard.set(userId[0], forKey: self.signInWithAppleManager.userIdentifierKey)
                UserDefaults.standard.set(userId[1], forKey: self.signInWithAppleManager.email)
                UserDefaults.standard.set(userId[2], forKey: self.signInWithAppleManager.username)
                self.signInWithAppleManager.isUserAuthenticated = .signedIn
            case .failure(let err):
                self.errorDescription = err.localizedDescription
                self.isAlertPresented = true
            }
        })

        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = signInWithAppleDelegates
        controller.presentationContextProvider = signInWithAppleDelegates as! ASAuthorizationControllerPresentationContextProviding

        controller.performRequests()
    }

}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
