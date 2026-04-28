//
//  ValidationHelper.swift
//  formulario
//
//  Created by Luis Fernandez Rodriguez on 27/04/2026.
//

import Foundation

class ValidationHelper {
    
    // Valida título: 5-60 caracteres
    static func validateTitulo(_ text: String) -> (isValid: Bool, errorMessage: String?) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return (false, "El título es obligatorio")
        }
        if trimmed.count < 5 {
            return (false, "El título debe tener al menos 5 caracteres")
        }
        if trimmed.count > 60 {
            return (false, "El título no puede exceder 60 caracteres")
        }
        return (true, nil)
    }
    
    // Valida descripción: 20-500 caracteres
    static func validateDescripcion(_ text: String) -> (isValid: Bool, errorMessage: String?) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return (false, "La descripción es obligatoria")
        }
        if trimmed.count < 20 {
            return (false, "La descripción debe tener al menos 20 caracteres")
        }
        if trimmed.count > 500 {
            return (false, "La descripción no puede exceder 500 caracteres")
        }
        return (true, nil)
    }
    
    // Valida email
    static func validateEmail(_ text: String) -> (isValid: Bool, errorMessage: String?) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return (false, "El email es obligatorio")
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if !emailPredicate.evaluate(with: trimmed) {
            return (false, "El email no es válido")
        }
        return (true, nil)
    }
    
    // Valida prioridad: 1-5
    static func validatePrioridad(_ value: Int) -> (isValid: Bool, errorMessage: String?) {
        if value < 1 || value > 5 {
            return (false, "La prioridad debe estar entre 1 y 5")
        }
        return (true, nil)
    }
    
    // Valida categoría no vacía
    static func validateCategoria(_ text: String) -> (isValid: Bool, errorMessage: String?) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return (false, "La categoría es obligatoria")
        }
        return (true, nil)
    }
}
