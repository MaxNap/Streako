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
import AuthenticationServices
import CryptoKit

final class AuthService {
    
    static let shared = AuthService()
    
    private init() {}
    
    var currentUser: User? {
        Auth.auth().currentUser
    }
    
    func signInWithApple(
        credential: ASAuthorizationAppleIDCredential,
        nonce: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        guard let appleIDToken = credential.identityToken else {
            completion(.failure(AuthError.missingToken))
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(AuthError.invalidToken))
            return
        }
        
        // Create the OAuth provider credential for Apple
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: credential.fullName
        )
        
        Auth.auth().signIn(with: firebaseCredential) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(AuthError.unknown))
                return
            }
            
            // Update the user's display name if this is a new account and we have the full name
            if let fullName = credential.fullName,
               let givenName = fullName.givenName,
               let familyName = fullName.familyName,
               user.displayName == nil || user.displayName?.isEmpty == true {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = "\(givenName) \(familyName)"
                changeRequest.commitChanges { _ in
                    // Name updated, but we don't need to wait for this
                }
            }
            
            completion(.success(user))
        }
    }
    
     func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms = (0..<16).map { _ in UInt8.random(in: 0...255) }
            
            randoms.forEach { random in
                if remainingLength == 0 {
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

     func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
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
    
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(AuthError.notAuthenticated))
            return
        }
        
        user.delete { error in
            if let error = error {
                // Check if reauthentication is required
                let nsError = error as NSError
                if let authErrorCode = AuthErrorCode(rawValue: nsError.code),
                   authErrorCode == .requiresRecentLogin {
                    completion(.failure(AuthError.requiresRecentLogin))
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            completion(.success(()))
        }
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
                // Check if user cancelled
                let nsError = error as NSError
                if nsError.code == -5 { // GIDSignInError.canceled
                    completion(.failure(AuthError.userCancelled))
                    return
                }
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

enum AuthError: LocalizedError, Equatable {
    case unknown
    case missingToken
    case invalidToken
    case userCancelled
    case notAuthenticated
    case requiresRecentLogin
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Something went wrong. Please try again."
        case .missingToken:
            return "Failed to get authentication token from Apple."
        case .invalidToken:
            return "The authentication token from Apple is invalid."
        case .userCancelled:
            return "Sign in was cancelled."
        case .notAuthenticated:
            return "You must be signed in to perform this action."
        case .requiresRecentLogin:
            return "For security, please sign in again to delete your account."
        }
    }
}
