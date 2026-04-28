//
//  SolicitudTableViewCell.swift
//  formulario
//
//  Created by Luis Fernandez Rodriguez on 27/04/2026.
//

import UIKit

class SolicitudTableViewCell: UITableViewCell {
    
    static let identifier = "SolicitudTableViewCell"
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tituloLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descripcionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoriaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let prioridadView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let prioridadLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fechaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        prioridadView.addSubview(prioridadLabel)
        
        containerView.addSubview(tituloLabel)
        containerView.addSubview(descripcionLabel)
        containerView.addSubview(categoriaLabel)
        containerView.addSubview(prioridadView)
        containerView.addSubview(fechaLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            tituloLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            tituloLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            tituloLabel.trailingAnchor.constraint(equalTo: prioridadView.leadingAnchor, constant: -8),
            
            prioridadView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            prioridadView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            prioridadView.widthAnchor.constraint(equalToConstant: 32),
            prioridadView.heightAnchor.constraint(equalToConstant: 24),
            
            prioridadLabel.centerXAnchor.constraint(equalTo: prioridadView.centerXAnchor),
            prioridadLabel.centerYAnchor.constraint(equalTo: prioridadView.centerYAnchor),
            
            descripcionLabel.topAnchor.constraint(equalTo: tituloLabel.bottomAnchor, constant: 6),
            descripcionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            descripcionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            categoriaLabel.topAnchor.constraint(equalTo: descripcionLabel.bottomAnchor, constant: 8),
            categoriaLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            fechaLabel.topAnchor.constraint(equalTo: descripcionLabel.bottomAnchor, constant: 8),
            fechaLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            fechaLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configure
    func configure(with solicitud: Solicitud) {
        tituloLabel.text = solicitud.titulo
        descripcionLabel.text = solicitud.descripcion
        categoriaLabel.text = "📁 \(solicitud.categoria)"
        
        // Configurar prioridad
        prioridadLabel.text = "\(solicitud.prioridad)"
        configurePrioridad(solicitud.prioridad)
        
        // Formatear fecha
        if let fecha = solicitud.createdAt {
            fechaLabel.text = formatDate(fecha)
        } else {
            fechaLabel.text = ""
        }
    }
    
    private func configurePrioridad(_ prioridad: Int) {
        switch prioridad {
        case 1:
            prioridadView.backgroundColor = .systemGreen
        case 2:
            prioridadView.backgroundColor = .systemTeal
        case 3:
            prioridadView.backgroundColor = .systemYellow
        case 4:
            prioridadView.backgroundColor = .systemOrange
        case 5:
            prioridadView.backgroundColor = .systemRed
        default:
            prioridadView.backgroundColor = .systemGray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d MMM yyyy, HH:mm"
        return formatter.string(from: date)
    }
}
