//
//  AuthService.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import Foundation
import FirebaseAuth

class AuthService {
    
    static let shared = AuthService()
    
    private init() {}
    
    // MARK: - Current User
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let user = result?.user {
                completion(.success(user))
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
