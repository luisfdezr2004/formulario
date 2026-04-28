//
//  MisSolicitudesViewController.swift
//  formulario
//
//  Created by Luis Fernandez Rodriguez on 27/04/2026.
//

import UIKit

class MisSolicitudesViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No tienes solicitudes todavía"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let emptyStateIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "doc.text.magnifyingglass")
        imageView.tintColor = .secondaryLabel
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refresh
    }()
    
    // MARK: - Properties
    private var solicitudes: [Solicitud] = []
    private let userEmail: String
    
    // MARK: - Init
    init(email: String) {
        self.userEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchSolicitudes()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Mis Solicitudes"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateIcon)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            emptyStateIcon.widthAnchor.constraint(equalToConstant: 80),
            emptyStateIcon.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateIcon.bottomAnchor, constant: 20),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SolicitudTableViewCell.self, forCellReuseIdentifier: SolicitudTableViewCell.identifier)
        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    // MARK: - Fetch Data
    private func fetchSolicitudes() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
        emptyStateIcon.isHidden = true
        emptyStateLabel.isHidden = true
        
        SupabaseManager.shared.fetchSolicitudes(forEmail: userEmail) { [weak self] result in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let solicitudes):
                self.solicitudes = solicitudes
                self.tableView.reloadData()
                
                if solicitudes.isEmpty {
                    self.showEmptyState()
                } else {
                    self.tableView.isHidden = false
                }
                
            case .failure(let error):
                self.showErrorAlert(error: error)
            }
        }
    }
    
    @objc private func refreshData() {
        fetchSolicitudes()
    }
    
    // MARK: - Empty State
    private func showEmptyState() {
        tableView.isHidden = true
        emptyStateIcon.isHidden = false
        emptyStateLabel.isHidden = false
    }
    
    // MARK: - Error Alert
    private func showErrorAlert(error: SupabaseError) {
        let alert = UIAlertController(
            title: "Error al cargar solicitudes",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Reintentar", style: .default) { [weak self] _ in
            self?.fetchSolicitudes()
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableView DataSource
extension MisSolicitudesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solicitudes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SolicitudTableViewCell.identifier, for: indexPath) as? SolicitudTableViewCell else {
            return UITableViewCell()
        }
        
        let solicitud = solicitudes[indexPath.row]
        cell.configure(with: solicitud)
        return cell
    }
}

// MARK: - UITableView Delegate
extension MisSolicitudesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
