//
//  Solicitud.swift
//  formulario
//
//  Created by Luis Fernandez Rodriguez on 27/04/2026.
//

import Foundation

struct Solicitud: Codable {
    let id: Int?
    let titulo: String
    let descripcion: String
    let categoria: String
    let prioridad: Int
    let email: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case titulo
        case descripcion
        case categoria
        case prioridad
        case email
        case createdAt = "created_at"
    }
    
    init(id: Int? = nil, titulo: String, descripcion: String, categoria: String, prioridad: Int, email: String, createdAt: Date? = nil) {
        self.id = id
        self.titulo = titulo
        self.descripcion = descripcion
        self.categoria = categoria
        self.prioridad = prioridad
        self.email = email
        self.createdAt = createdAt
    }
}
