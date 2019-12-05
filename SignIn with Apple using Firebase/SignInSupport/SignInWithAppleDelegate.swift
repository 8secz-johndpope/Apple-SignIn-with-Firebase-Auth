//
//  SignInWithAppleDelegate.swift
//  SignIn with Apple using Firebase
//
//  Created by mohammad mugish on 05/12/19.
//  Copyright © 2019 mohammad mugish. All rights reserved.
//

import Foundation
import AuthenticationServices
import FirebaseAuth



class SignInWithAppleDelegates: NSObject {
    private let signInSucceeded: (Result<[String], Error>) -> ()
    private weak var window: UIWindow!
    private var nonce : String!
    
    init(window: UIWindow?, nonce : String?, onSignedIn: @escaping (Result<[String], Error>) -> ()) {
        self.window = window
        self.signInSucceeded = onSignedIn
        self.nonce = nonce
    }
    
    
}


extension SignInWithAppleDelegates: ASAuthorizationControllerDelegate {
    private func registerNewAccount(credential: ASAuthorizationAppleIDCredential) {
        print("Registering new account with user: \(credential.user)")
        self.signInSucceeded(.success([credential.user, (credential.email ?? "Not available"), (credential.fullName?.givenName ?? "Not available"), (credential.fullName?.familyName ?? "Not available")]))
        //        self.signInSucceeded(.success([credential.user, (credential.email ?? "Not available"), (credential.fullName ?? "Not available")]))
    }
    
    private func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) {
        print("Signing in with existing account with user: \(credential.user)")
        self.signInSucceeded(.success([credential.user, (credential.email ?? "Not available"), (credential.email ?? "Not available")]))
        //        self.signInSucceeded(.success(credential.user))
    }
    
    private func signInWithUserAndPassword(credential: ASPasswordCredential) {
        print("Signing in using an existing iCloud Keychain credential with user: \(credential.user)")
        self.signInSucceeded(.success([credential.user]))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        //         let userIdentifier = appleIDCredential.user
        //            let userFirstName = appleIDCredential.fullName?.givenName
        //            let userLastName = appleIDCredential.fullName?.familyName
        //            let userEmail = appleIDCredential.email
        
        
        
        func registerWithFirebase(Cre : ASAuthorizationAppleIDCredential,  onSuccess : @escaping (_ success:Bool) -> Void) {
            var registerSuccessful = false
            
            guard let nonce = nonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                onSuccess(false)
                
                
            }
            guard let appleIDToken = Cre.identityToken else {
                print("Unable to fetch identity token")
                onSuccess(false)
                
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                onSuccess(false)
                
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            print("FIrebase user cred : \(nonce)")
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error!.localizedDescription)
                    onSuccess(false)
                    
                    return
                }else{
                    // User is signed in to Firebase with Apple.
                    // ...
                    print("Firebase registration successful")
                    onSuccess(true)
                    
                }
                
            }
        }
        
        func loginWithFirebase(Cre : ASAuthorizationAppleIDCredential, onSuccess : @escaping (_ success : Bool) -> Void){
            // Initialize a fresh Apple credential with Firebase.
            
            guard let nonce = nonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                onSuccess(false)
                
                
            }
            
            guard let appleIDToken = Cre.identityToken else {
                print("Unable to fetch identity token")
                onSuccess(false)
                
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                onSuccess(false)
                
                return
            }
            
            
            let cred = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            
            // Reauthenticate current Apple user with fresh Apple credential.
            Auth.auth().currentUser!.reauthenticate(with: cred) { (authResult, error) in
                if error != nil {
                    print(error.debugDescription)
                    print("Reauth fail")
                    onSuccess(false)
                }else{
                    // Apple user successfully re-authenticated.
                    // ...
                    print("reauth done")
                    onSuccess(true)
                }
            }
        }
        
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            if let email = appleIdCredential.email, let userName = appleIdCredential.fullName {
                print(email)
                print(userName.givenName)
                print(userName.familyName)
                
                
                registerWithFirebase(Cre: appleIdCredential, onSuccess: { (result) in
                    
                    if result{
                        self.registerNewAccount(credential: appleIdCredential)
                    }else{
                        print("Registration fail")
                    }
                })
                
                
                
                
                
            } else {
                
                registerWithFirebase(Cre: appleIdCredential, onSuccess: { (result) in
                    
                    if result{
                    self.signInWithExistingAccount(credential: appleIdCredential)
                    }else{
                    print("Registration fail")
                    }
                    })
                
                
                
            }
            
            break
            
        case let passwordCredential as ASPasswordCredential:
            signInWithUserAndPassword(credential: passwordCredential)
            
            break
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.signInSucceeded(.failure(error))
        
    }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window
    }
}

