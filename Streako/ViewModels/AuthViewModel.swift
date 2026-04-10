//
//  AuthViewModel.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import Foundation
import Combine
import FirebaseAuth

final class AuthViewModel: ObservableObject {
    
    @Published var user: AppUser?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    init() {
        listenToAuthState()
    }
    
    
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        AuthService.shared.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let firebaseUser):
                    self?.user = AppUser(
                        uid: firebaseUser.uid,
                        email: firebaseUser.email ?? email
                    )
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        AuthService.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let firebaseUser):
                    self?.user = AppUser(
                        uid: firebaseUser.uid,
                        email: firebaseUser.email ?? email
                    )
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signOut() {
        do {
            try AuthService.shared.signOut()
            user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user, let email = user.email {
                    self?.user = AppUser(uid: user.uid, email: email)
                } else {
                    self?.user = nil
                }
            }
        }
    }
}
