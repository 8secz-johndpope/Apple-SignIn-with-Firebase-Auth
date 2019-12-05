//
//  MainView.swift
//  SignIn with Apple using Firebase
//
//  Created by mohammad mugish on 05/12/19.
//  Copyright © 2019 mohammad mugish. All rights reserved.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct MainView: View {
    
    @EnvironmentObject var signInWithAppleManager : SignInWithAppleManager
    var name : String = ""
  
    
    
    var body: some View {
        VStack{
            
            Text("User Name : \(UserDefaults.standard.string(forKey: signInWithAppleManager.username)!)")
            Text("User Email : \(UserDefaults.standard.string(forKey: signInWithAppleManager.email)!)")
            Text("Firebase Auth : \(Auth.auth().currentUser?.email ?? "No Email")")
    
            
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
