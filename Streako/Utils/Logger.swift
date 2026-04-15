//
//  Logger.swift
//  Streako
//
//  Created by Maksim Napolskikh on 2026-04-12.
//

import Foundation

enum Log {
    
    static func info(_ message: String) {
        #if DEBUG
        print("ℹ️ \(message)")
        #endif
    }
    
    static func success(_ message: String) {
        #if DEBUG
        print("✅ \(message)")
        #endif
    }
    
    static func error(_ message: String) {
        #if DEBUG
        print("❌ \(message)")
        #endif
    }
    
    static func debug(_ message: String) {
        #if DEBUG
        print("🐛 \(message)")
        #endif
    }
}
