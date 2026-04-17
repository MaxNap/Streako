//
//  LoginView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentNonce: String?
    
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case email
        case password
    }
    
    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isFormValid: Bool {
        !trimmedEmail.isEmpty && !password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                    .onTapGesture {
                        focusedField = nil
                    }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        formSection
                        actionSection
                        dividerSection
                        socialSection
                        signUpSection
                        privacyPolicySection
                    }
                    .padding()
                    .padding(.top, 40)
                    .padding(.bottom, 24)
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(authViewModel)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.system(size: 34))
                .foregroundColor(.orange)
            
            Text("Welcome back")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
            
            Text("Sign in to continue building your streak")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    private var formSection: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.gray)
                
                TextField("Enter your email", text: $email)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onChange(of: email) { _, _ in
                        authViewModel.clearError()
                    }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.gray)
                
                SecureField("Enter your password", text: $password)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        submitLogin()
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onChange(of: password) { _, _ in
                        authViewModel.clearError()
                    }
            }
            
            Button("Forgot Password?") {
                focusedField = nil
                authViewModel.resetPassword(email: email)
            }
            .font(.footnote.weight(.medium))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
            
            if !authViewModel.errorMessage.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red.opacity(0.95))
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding()
                .background(Color.red.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            if !authViewModel.successMessage.isEmpty {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text(authViewModel.successMessage)
                        .foregroundColor(.green.opacity(0.95))
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding()
                .background(Color.green.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
    
    private var actionSection: some View {
        Button {
            submitLogin()
        } label: {
            Group {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Log In")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(isFormValid ? Color.white : Color.white.opacity(0.08))
            .foregroundColor(isFormValid ? .black : .gray)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!isFormValid || authViewModel.isLoading)
    }
    
    private var dividerSection: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 1)
            
            Text("or continue with")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Rectangle()
                .fill(Color.white.opacity(0.10))
                .frame(height: 1)
        }
    }
    
    private var socialSection: some View {
        VStack(spacing: 12) {
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    authViewModel.clearError()
                    let nonce = AuthService.shared.randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = AuthService.shared.sha256(nonce)
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential else {
                            authViewModel.errorMessage = "Failed to get Apple ID credential."
                            return
                        }
                        
                        guard let nonce = currentNonce else {
                            authViewModel.errorMessage = "Invalid authentication state."
                            return
                        }
                        
                        authViewModel.signInWithApple(
                            credential: appleIDCredential,
                            nonce: nonce
                        )
                        
                    case .failure(let error):
                        // Don't show error if user cancelled
                        let nsError = error as NSError
                        if nsError.code == 1001 { // ASAuthorizationError.canceled
                            return
                        }
                        authViewModel.errorMessage = error.localizedDescription
                    }
                }
            )
            .signInWithAppleButtonStyle(.white)
            .frame(height: 50)
            .cornerRadius(16)
            .disabled(authViewModel.isLoading)
            
            Button {
                authViewModel.signInWithGoogle()
            } label: {
                HStack(spacing: 9) {
                    Image("google_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("Continue with Google")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white.opacity(0.06))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(authViewModel.isLoading)
        }
    }
    
    private var signUpSection: some View {
        HStack(spacing: 6) {
            Text("Don’t have an account?")
                .foregroundColor(.gray)
            
            Button("Create Account") {
                showSignUp = true
            }
            .foregroundColor(.white)
            .fontWeight(.semibold)
        }
        .font(.footnote)
        .padding(.top, 4)
    }
    
    private var privacyPolicySection: some View {
        Button {
            if let url = URL(string: "https://www.freeprivacypolicy.com/live/f37a4b2c-7e9b-41dc-b216-81f9c0f7c322") {
                UIApplication.shared.open(url)
            }
        } label: {
            Text("Privacy Policy")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.7))
        }
    }
    
    private func submitLogin() {
        guard isFormValid, !authViewModel.isLoading else { return }
        focusedField = nil
        authViewModel.signIn(email: trimmedEmail, password: password)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
