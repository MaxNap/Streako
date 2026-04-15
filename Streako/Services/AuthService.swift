//
//  AuthService.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn
import FirebaseCore

final class AuthService {
    
    static let shared = AuthService()
    
    private init() {}
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(AuthError.unknown))
                return
            }
            
            completion(.success(user))
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(AuthError.unknown))
                return
            }
            
            completion(.success(user))
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func signInWithGoogle(completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthError.unknown))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = scene.windows.first?.rootViewController else {
            completion(.failure(AuthError.unknown))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(AuthError.unknown))
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let firebaseUser = result?.user else {
                    completion(.failure(AuthError.unknown))
                    return
                }
                
                completion(.success(firebaseUser))
            }
        }
    }
}

enum AuthError: LocalizedError {
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
