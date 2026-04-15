//
//  SignUpView.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-08.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case email
        case password
        case confirmPassword
    }
    
    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var localErrorMessage: String {
        if trimmedEmail.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            return ""
        }
        
        if !trimmedEmail.contains("@") || !trimmedEmail.contains(".") {
            return "Please enter a valid email address."
        }
        
        if password.count < 6 {
            return "Password must be at least 6 characters."
        }
        
        if password != confirmPassword {
            return "Passwords do not match."
        }
        
        return ""
    }
    
    private var isFormValid: Bool {
        !trimmedEmail.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        localErrorMessage.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    formSection
                    actionSection
                    signInSection
                }
                .padding()
                .padding(.top, 40)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            focusedField = nil
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.system(size: 34))
                .foregroundColor(.orange)
            
            Text("Create your account")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
            
            Text("Start building your streak with Streako")
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
                    .textContentType(.newPassword)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .confirmPassword
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onChange(of: password) { _, _ in
                        authViewModel.clearError()
                    }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.gray)
                
                SecureField("Re-enter your password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.go)
                    .onSubmit {
                        submitSignUp()
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .onChange(of: confirmPassword) { _, _ in
                        authViewModel.clearError()
                    }
            }
            
            if !localErrorMessage.isEmpty {
                errorCard(message: localErrorMessage)
            } else if !authViewModel.errorMessage.isEmpty {
                errorCard(message: authViewModel.errorMessage)
            }
        }
    }
    
    private var actionSection: some View {
        Button {
            submitSignUp()
        } label: {
            Group {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text("Create Account")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(isFormValid ? Color.green : Color.white.opacity(0.08))
            .foregroundColor(isFormValid ? .white : .gray)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!isFormValid || authViewModel.isLoading)
    }
    
    private var signInSection: some View {
        HStack(spacing: 6) {
            Text("Already have an account?")
                .foregroundColor(.gray)
            
            Button("Log In") {
                dismiss()
            }
            .foregroundColor(.white)
            .fontWeight(.semibold)
        }
        .font(.footnote)
        .padding(.top, 4)
    }
    
    private func errorCard(message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .foregroundColor(.red.opacity(0.95))
                .font(.footnote)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private func submitSignUp() {
        guard isFormValid, !authViewModel.isLoading else { return }
        focusedField = nil
        authViewModel.signUp(email: trimmedEmail, password: password)
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
