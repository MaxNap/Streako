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
    @Published var successMessage = ""
    
    init() {
        listenToAuthState()
    }
    
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        AuthService.shared.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let firebaseUser):
                    self.user = AppUser(
                        uid: firebaseUser.uid,
                        email: firebaseUser.email ?? email
                    )
                case .failure(let error):
                    self.errorMessage = self.mapAuthError(error)
                }
            }
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        AuthService.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let firebaseUser):
                    self.user = AppUser(
                        uid: firebaseUser.uid,
                        email: firebaseUser.email ?? email
                    )
                case .failure(let error):
                    self.errorMessage = self.mapAuthError(error)
                }
            }
        }
    }
    
    func signInWithGoogle() {
        isLoading = true
        errorMessage = ""
        
        AuthService.shared.signInWithGoogle { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let firebaseUser):
                    self.user = AppUser(
                        uid: firebaseUser.uid,
                        email: firebaseUser.email ?? ""
                    )
                case .failure(let error):
                    self.errorMessage = self.mapAuthError(error)
                }
            }
        }
    }
    
    func resetPassword(email: String) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter your email first."
            successMessage = ""
            return
        }
        
        guard isValidEmail(trimmedEmail) else {
            errorMessage = "Please enter a valid email address."
            successMessage = ""
            return
        }
        
        isLoading = true
        errorMessage = ""
        successMessage = ""
        
        AuthService.shared.resetPassword(email: trimmedEmail) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                
                switch result {
                case .success:
                    self.successMessage = "If an account exists, a reset link has been sent. Please check your inbox and spam folder."
                case .failure(let error):
                    self.errorMessage = self.mapAuthError(error)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try AuthService.shared.signOut()
            user = nil
            errorMessage = ""
        } catch {
            errorMessage = mapAuthError(error)
        }
    }
    
    func clearError() {
        errorMessage = ""
        successMessage = ""
    }
    
    private func listenToAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                guard let self else { return }
                
                if let user, let email = user.email {
                    self.user = AppUser(uid: user.uid, email: email)
                } else {
                    self.user = nil
                }
            }
        }
    }
    
    private func mapAuthError(_ error: Error) -> String {
        if let authErrorCode = AuthErrorCode(rawValue: (error as NSError).code) {
            switch authErrorCode {
            case .invalidEmail:
                return "Please enter a valid email address."
            case .emailAlreadyInUse:
                return "This email is already in use."
            case .weakPassword:
                return "Your password is too weak. Use at least 6 characters."
            case .wrongPassword:
                return "Incorrect password."
            case .userNotFound:
                return "No account was found with that email."
            case .networkError:
                return "Network error. Please check your connection and try again."
            case .tooManyRequests:
                return "Too many attempts. Please try again later."
            case .invalidCredential:
                return "Invalid login credentials."
            default:
                return error.localizedDescription
            }
        }
        
        return error.localizedDescription
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}
