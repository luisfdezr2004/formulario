//
//  Formulario.swift
//  formulario
//
//  Created by Luis Fernandez Rodriguez on 27/04/2026.
//

import Foundation
import UIKit

class FormularioViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tTitulo: UITextField!
    // NUEVO: Cambiado a UITextView
    @IBOutlet weak var tDescripcion: UITextView!
    @IBOutlet weak var tCategoria: UITextField!
    @IBOutlet weak var tPrioridad: UITextField!
    @IBOutlet weak var tEmail: UITextField!
    @IBOutlet weak var botonEnviar: UIButton!
    
    // MARK: - Properties
    private var isSubmitting = false
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupValidation()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Nueva Solicitud"
        
        // Botón para ver solicitudes
        let verSolicitudesButton = UIBarButtonItem(
            title: "Mis Solicitudes",
            style: .plain,
            target: self,
            action: #selector(verMisSolicitudes)
        )
        navigationItem.rightBarButtonItem = verSolicitudesButton
        
        // Configurar activity indicator en el botón
        if let boton = botonEnviar {
            activityIndicator.color = .white
            activityIndicator.hidesWhenStopped = true
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            boton.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerYAnchor.constraint(equalTo: boton.centerYAnchor),
                activityIndicator.trailingAnchor.constraint(equalTo: boton.trailingAnchor, constant: -20)
            ])
        }
        
        // Configurar tipos de teclado
        tEmail?.keyboardType = .emailAddress
        tEmail?.autocapitalizationType = .none
        tPrioridad?.keyboardType = .numberPad
        
        // NUEVO: Añadir estilo al UITextView para que se parezca a un UITextField normal
        tDescripcion?.layer.borderColor = UIColor.systemGray4.cgColor
        tDescripcion?.layer.borderWidth = 1.0
        tDescripcion?.layer.cornerRadius = 6.0
        
        // Gesto para cerrar teclado
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupValidation() {
        // Añadir listeners para validación en tiempo real en los TextFields
        tTitulo?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        tCategoria?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        tPrioridad?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        tEmail?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // NUEVO: El UITextView no usa addTarget, usa su delegado para escuchar cambios
        tDescripcion?.delegate = self
        
        // Validación inicial
        updateButtonState()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange() {
        updateButtonState()
    }
    
    // MARK: - Validation
    private func updateButtonState() {
        let isValid = validateAllFields()
        botonEnviar?.isEnabled = isValid && !isSubmitting
        botonEnviar?.alpha = (isValid && !isSubmitting) ? 1.0 : 0.5
    }
    
    private func validateAllFields() -> Bool {
        guard let titulo = tTitulo?.text,
              let descripcion = tDescripcion?.text,
              let categoria = tCategoria?.text,
              let prioridadText = tPrioridad?.text,
              let email = tEmail?.text else {
            return false
        }
        
        let tituloValidation = ValidationHelper.validateTitulo(titulo)
        let descripcionValidation = ValidationHelper.validateDescripcion(descripcion)
        let categoriaValidation = ValidationHelper.validateCategoria(categoria)
        let emailValidation = ValidationHelper.validateEmail(email)
        
        // Validar prioridad (1-5)
        guard let prioridad = Int(prioridadText), prioridad >= 1 && prioridad <= 5 else {
            return false
        }
        
        return tituloValidation.isValid &&
               descripcionValidation.isValid &&
               categoriaValidation.isValid &&
               emailValidation.isValid
    }
    
    private func showValidationErrors() -> String? {
        var errors: [String] = []
        
        if let titulo = tTitulo?.text {
            let validation = ValidationHelper.validateTitulo(titulo)
            if !validation.isValid {
                errors.append("• \(validation.errorMessage ?? "Error en título")")
            }
        }
        
        if let descripcion = tDescripcion?.text {
            let validation = ValidationHelper.validateDescripcion(descripcion)
            if !validation.isValid {
                errors.append("• \(validation.errorMessage ?? "Error en descripción")")
            }
        }
        
        if let categoria = tCategoria?.text {
            let validation = ValidationHelper.validateCategoria(categoria)
            if !validation.isValid {
                errors.append("• \(validation.errorMessage ?? "Error en categoría")")
            }
        }
        
        if let prioridadText = tPrioridad?.text {
            if let prioridad = Int(prioridadText), prioridad >= 1 && prioridad <= 5 {
                // Válido
            } else {
                errors.append("• La prioridad debe ser un número entre 1 y 5")
            }
        }
        
        if let email = tEmail?.text {
            let validation = ValidationHelper.validateEmail(email)
            if !validation.isValid {
                errors.append("• \(validation.errorMessage ?? "Error en email")")
            }
        }
        
        return errors.isEmpty ? nil : errors.joined(separator: "\n")
    }
    
    // MARK: - Submit Action
    @IBAction func tocarBoton(_ sender: Any) {
        print("🔘 [FormularioVC] Botón 'Enviar' presionado")
        
        guard !isSubmitting else {
            print("⚠️ [FormularioVC] Ya hay un envío en curso, ignorando")
            return
        }
        
        // Validación final
        print("🔍 [FormularioVC] Validando campos...")
        if !validateAllFields() {
            print("❌ [FormularioVC] Validación fallida")
            if let errorMessage = showValidationErrors() {
                showAlert(title: "Campos inválidos", message: errorMessage, isError: true)
            }
            return
        }
        
        // Obtener valores
        guard let titulo = tTitulo?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let descripcion = tDescripcion?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let categoria = tCategoria?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let prioridadText = tPrioridad?.text,
              let prioridad = Int(prioridadText),
              let email = tEmail?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            print("❌ [FormularioVC] Error obteniendo valores de los campos")
            return
        }
        
        print("✅ [FormularioVC] Validación exitosa")
        print("📝 [FormularioVC] Valores: titulo=\(titulo), desc=\(descripcion.prefix(30))..., cat=\(categoria), pri=\(prioridad), email=\(email)")
        
        // Cambiar estado a "Enviando..."
        setSubmittingState(true)
        print("⏳ [FormularioVC] Estado cambiado a 'Enviando...'")
        
        // Crear solicitud
        let solicitud = Solicitud(
            titulo: titulo,
            descripcion: descripcion,
            categoria: categoria,
            prioridad: prioridad,
            email: email
        )
        
        print("📦 [FormularioVC] Solicitud creada, enviando a Supabase...")
        
        // Enviar a Supabase
        SupabaseManager.shared.insertSolicitud(solicitud) { [weak self] result in
            print("📬 [FormularioVC] Respuesta recibida de SupabaseManager")
            guard let self = self else { return }
            
            self.setSubmittingState(false)
            
            switch result {
            case .success(let solicitud):
                print("🎉 [FormularioVC] ¡Éxito! Solicitud insertada con ID: \(solicitud.id?.description ?? "sin ID")")
                self.showAlert(title: "¡Éxito!", message: "Tu solicitud ha sido enviada correctamente.", isError: false)
                self.clearForm()
                
            case .failure(let error):
                print("❌ [FormularioVC] Error al enviar: \(error.localizedDescription)")
                self.showErrorAlert(error: error)
            }
        }
    }
    
    // MARK: - UI State
    private func setSubmittingState(_ isSubmitting: Bool) {
        self.isSubmitting = isSubmitting
        
        if isSubmitting {
            botonEnviar?.setTitle("Enviando...", for: .normal)
            botonEnviar?.isEnabled = false
            activityIndicator.startAnimating()
        } else {
            botonEnviar?.setTitle("Enviar Solicitud", for: .normal)
            activityIndicator.stopAnimating()
            updateButtonState()
        }
        
        // Deshabilitar campos durante el envío
        tTitulo?.isEnabled = !isSubmitting
        
        // NUEVO: El UITextView usa 'isEditable' en lugar de 'isEnabled'
        tDescripcion?.isEditable = !isSubmitting 
        tDescripcion?.alpha = isSubmitting ? 0.6 : 1.0 // Un pequeño toque visual al bloquearlo
        
        tCategoria?.isEnabled = !isSubmitting
        tPrioridad?.isEnabled = !isSubmitting
        tEmail?.isEnabled = !isSubmitting
    }
    
    // MARK: - Alerts
    private func showAlert(title: String, message: String, isError: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(error: SupabaseError) {
        let alert = UIAlertController(
            title: "Error al enviar",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Reintentar", style: .default) { [weak self] _ in
            self?.tocarBoton(self?.botonEnviar as Any)
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    @objc private func verMisSolicitudes() {
        // Obtener email del campo si existe y es válido
        let currentEmail = tEmail?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Si hay un email válido en el campo, usarlo directamente
        if !currentEmail.isEmpty && ValidationHelper.validateEmail(currentEmail).isValid {
            let misSolicitudesVC = MisSolicitudesViewController(email: currentEmail)
            navigationController?.pushViewController(misSolicitudesVC, animated: true)
            return
        }
        
        // Si no hay email o no es válido, mostrar diálogo para introducirlo
        mostrarDialogoEmail(emailSugerido: currentEmail)
    }
    
    private func mostrarDialogoEmail(emailSugerido: String) {
        let alert = UIAlertController(
            title: "Introduce tu email",
            message: "Para ver tus solicitudes, por favor introduce tu dirección de email:",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "tu@email.com"
            textField.keyboardType = .emailAddress
            textField.autocapitalizationType = .none
            textField.text = emailSugerido
        }
        
        alert.addAction(UIAlertAction(title: "Ver Solicitudes", style: .default) { [weak self, weak alert] _ in
            guard let email = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !email.isEmpty else {
                self?.showAlert(title: "Email vacío", message: "Por favor introduce un email válido.", isError: true)
                return
            }
            
            // Validar email
            let validation = ValidationHelper.validateEmail(email)
            if !validation.isValid {
                self?.showAlert(title: "Email inválido", message: validation.errorMessage ?? "Por favor introduce un email válido.", isError: true)
                return
            }
            
            // Navegar a Mis Solicitudes
            let misSolicitudesVC = MisSolicitudesViewController(email: email)
            self?.navigationController?.pushViewController(misSolicitudesVC, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Clear Form
    private func clearForm() {
        tTitulo?.text = ""
        tDescripcion?.text = ""
        tCategoria?.text = ""
        tPrioridad?.text = ""
        tEmail?.text = ""
        updateButtonState()
    }
}

// MARK: - NUEVO: UITextViewDelegate
// Esta extensión captura cada letra que se escribe en el UITextView para validar el formulario en tiempo real
extension FormularioViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateButtonState()
    }
}
