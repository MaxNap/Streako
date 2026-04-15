//
//  LoginView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        formSection
                        actionSection
                        dividerSection
                        socialSection
                        signUpSection
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
            .onTapGesture {
                focusedField = nil
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
            Button {
                // Apple sign in will go here
            } label: {
                HStack {
                    Image(systemName: "applelogo")
                    Text("Continue with Apple")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            Button {
                authViewModel.signInWithGoogle()
            } label: {
                HStack {
                    Image("google_icon")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Continue with Google")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
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
