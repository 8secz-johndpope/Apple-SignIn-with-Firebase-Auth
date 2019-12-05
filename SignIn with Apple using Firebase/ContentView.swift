//
//  ContentView.swift
//  SignIn with Apple using Firebase
//
//  Created by mohammad mugish on 04/12/19.
//  Copyright © 2019 mohammad mugish. All rights reserved.
//

import SwiftUI



struct ContentView: View {
    
    
    @EnvironmentObject var signInWithAppleManager : SignInWithAppleManager
    
    var body: some View {
        ZStack{
            if signInWithAppleManager.isUserAuthenticated == .undefined {
                 LaunchView()
            }else if signInWithAppleManager.isUserAuthenticated == .signedIn{
                 MainView()
            }else if signInWithAppleManager.isUserAuthenticated == .signedOut{
                 LoginView()
            }
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
