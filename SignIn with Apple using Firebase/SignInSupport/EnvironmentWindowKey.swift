//
//  EnvironmentWindowKey.swift
//  SignIn with Apple using Firebase
//
//  Created by mohammad mugish on 05/12/19.
//  Copyright © 2019 mohammad mugish. All rights reserved.
//


import UIKit
import SwiftUI

struct WindowKey: EnvironmentKey {
    struct Value {
        weak var value: UIWindow?
    }
    
    static let defaultValue: Value = .init(value: nil)
}

extension EnvironmentValues {
    var window: UIWindow? {
        get { return self[WindowKey.self].value }
        set { self[WindowKey.self] = .init(value: newValue) }
    }
}


