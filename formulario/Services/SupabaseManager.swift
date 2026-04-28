//
//  SupabaseManager.swift
//  formulario
//
//  Created by Luis Fernandez Rodriguez on 27/04/2026.
//

import Foundation

enum SupabaseError: Error {
    case invalidURL
    case networkError
    case unauthorized
    case serverError
    case decodingError
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .networkError:
            return "No hay conexión a internet. Verifica tu conexión."
        case .unauthorized:
            return "No tienes permisos   para realizar esta acción."
        case .serverError:
            return "Error en el servidor. Intenta de nuevo más tarde."
        case .decodingError:
            return "Error al procesar los datos."
        case .invalidData:
            return "Datos inválidos."
        }
    }
}

class SupabaseManager {
    static let shared = SupabaseManager()
    private let tableName = "Formulario"
    private let supabaseKey = Secrets.supabaseKey
    private let supabaseURL = Secrets.supabaseURL
    
    private init() {}
    
    // MARK: - Insert Solicitud
    func insertSolicitud(_ solicitud: Solicitud, completion: @escaping (Result<Solicitud, SupabaseError>) -> Void) {
        print("🚀 [SupabaseManager] Iniciando insertSolicitud...")
        
        guard let url = URL(string: "\(supabaseURL)/rest/v1/\(tableName)") else {
            print("❌ [SupabaseManager] URL inválida")
            completion(.failure(.invalidURL))
            return
        }
        
        print("✅ [SupabaseManager] URL válida: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("return=representation", forHTTPHeaderField: "Prefer")
        
        // Preparar datos para enviar (sin id ni created_at, los genera Supabase)
        let solicitudToSend: [String: Any] = [
            "titulo": solicitud.titulo,
            "descripcion": solicitud.descripcion,
            "categoria": solicitud.categoria,
            "prioridad": solicitud.prioridad,
            "email": solicitud.email
        ]
        
        print("📦 [SupabaseManager] Datos a enviar: \(solicitudToSend)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: solicitudToSend)
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 [SupabaseManager] JSON a enviar: \(jsonString)")
            }
        } catch {
            print("❌ [SupabaseManager] Error al serializar datos: \(error)")
            completion(.failure(.invalidData))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("📡 [SupabaseManager] Respuesta recibida")
            
            // Error de red
            if let error = error {
                print("❌ [SupabaseManager] Error de red: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.networkError))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [SupabaseManager] No se pudo obtener HTTPURLResponse")
                DispatchQueue.main.async {
                    completion(.failure(.serverError))
                }
                return
            }
            
            print("📊 [SupabaseManager] Código HTTP: \(httpResponse.statusCode)")
            
            // Verificar código de respuesta
            switch httpResponse.statusCode {
            case 200...299:
                print("✅ [SupabaseManager] Respuesta exitosa (2xx)")
                
                guard let data = data else {
                    print("❌ [SupabaseManager] No hay datos en la respuesta")
                    DispatchQueue.main.async {
                        completion(.failure(.invalidData))
                    }
                    return
                }
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 [SupabaseManager] JSON recibido: \(jsonString)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let solicitudes = try decoder.decode([Solicitud].self, from: data)
                    print("✅ [SupabaseManager] Decodificación exitosa: \(solicitudes.count) solicitud(es)")
                    if let insertedSolicitud = solicitudes.first {
                       
                        DispatchQueue.main.async {
                            completion(.success(insertedSolicitud))
                        }
                    } else {
                        print("❌ [SupabaseManager] Array vacío en la respuesta")
                        DispatchQueue.main.async {
                            completion(.failure(.invalidData))
                        }
                    }
                } catch {
                    print("❌ [SupabaseManager] Error de decodificación: \(error)")
                    print("❌ [SupabaseManager] Detalles del error: \(error.localizedDescription)")
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("❌ Campo faltante: \(key.stringValue), contexto: \(context.debugDescription)")
                        case .typeMismatch(let type, let context):
                            print("❌ Tipo incorrecto: esperado \(type), contexto: \(context.debugDescription)")
                        case .valueNotFound(let type, let context):
                            print("❌ Valor no encontrado para tipo: \(type), contexto: \(context.debugDescription)")
                        case .dataCorrupted(let context):
                            print("❌ Datos corruptos: \(context.debugDescription)")
                        @unknown default:
                            print("❌ Error de decodificación desconocido")
                        }
                    }
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
                
            case 401, 403:
                print("❌ [SupabaseManager] Error de autorización: \(httpResponse.statusCode)")
                if let data = data, let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Respuesta del servidor: \(errorString)")
                }
                DispatchQueue.main.async {
                    completion(.failure(.unauthorized))
                }
                
            default:
                print("❌ [SupabaseManager] Error del servidor: \(httpResponse.statusCode)")
                if let data = data, let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Respuesta del servidor: \(errorString)")
                }
                DispatchQueue.main.async {
                    completion(.failure(.serverError))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Fetch Solicitudes
    func fetchSolicitudes(forEmail email: String, completion: @escaping (Result<[Solicitud], SupabaseError>) -> Void) {
        // Construir URL con filtro por email y orden descendente por fecha
        let urlString = "\(supabaseURL)/rest/v1/\(tableName)?email=eq.\(email)&order=created_at.desc"
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURLString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Error de red
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(.networkError))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.serverError))
                }
                return
            }
            
            // Verificar código de respuesta
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(.failure(.invalidData))
                    }
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let solicitudes = try decoder.decode([Solicitud].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(solicitudes))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
                
            case 401, 403:
                DispatchQueue.main.async {
                    completion(.failure(.unauthorized))
                }
                
            default:
                DispatchQueue.main.async {
                    completion(.failure(.serverError))
                }
            }
        }
        
        task.resume()
    }
}
