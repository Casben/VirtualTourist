//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Herbert Dodge on 7/25/20.
//  Copyright © 2020 Herbert Dodge. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController {
    
    //MARK: - Properties
    
    let mapView = MKMapView()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let toolBar = UIToolbar()
    let newCollectionButton = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(handleLoadNewCollection))
    let toolBarSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    var passedInAnnotation: MKAnnotation!
    var passedInPin: Pin!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
    }
    
    
    //MARK: - Helpers
    
    func configure() {
        configureResultsController(passedInPin)
        view.addSubviews(mapView, collectionView, toolBar)
        view.backgroundColor = .white
        configureNavigationBar()
        configureMapView()
        
        if let photos = passedInPin.photo, photos.count == 0 {
            downloadPhotos()
        }
        
        configureCollectionView()
        toolBar.items = [toolBarSpacer, newCollectionButton, toolBarSpacer]
        toolBar.tintColor = .systemIndigo
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalToConstant: 120),
            
            toolBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: toolBar.bottomAnchor),
            
        ])
        
    }
    
    
    func configureNavigationBar() {
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissPhotoAlbum))
        navigationItem.rightBarButtonItem = doneButton
        navigationController?.navigationBar.tintColor = .systemIndigo
    }
    
    func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        collectionView.backgroundColor = .white
        
    }
    
    func configureMapView() {
        mapView.delegate = self
        mapView.addAnnotation(passedInAnnotation)
        mapView.isScrollEnabled = false
        mapView.fitAll()
    }
    
    func configureResultsController(_ pin: Pin) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("error fetching data")
        }
    }
    
    func downloadPhotos() {
        NetworkManager.shared.getPhotosAt(latitude: passedInPin.latitude, longitude: passedInPin.longitude) { (response, error) in
            if error != nil {
                print("unable to retrieve response data")
            }
            guard let response = response else { return }
            let photoUrls = NetworkManager.shared.constructPhotoUrl(response)
            
            for url in photoUrls {
                self.addPhoto(url: url.absoluteString)
                print(url.absoluteString)
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func addPhoto(url: String) {
        let photo = Photo(context: DataController.shared.viewContext)
        photo.name = url
        photo.pin = passedInPin
        try? DataController.shared.viewContext.save()
    }
    
    func configureImage(using cell: PhotoCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let image = photo.image {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = UIImage(data: image)
        } else {
            if let imageUrl = photo.name {
                cell.activityIndicator.startAnimating()
                guard let downloadUrl = URL(string: imageUrl) else { return }
                NetworkManager.shared.downloadImage(imageUrl: downloadUrl) { (data, error) in
                    if error != nil {
                        print("unable to download image")
                        return
                    }
                    guard let data = data else { return }
                    DispatchQueue.main.async {
                        if let currentCell = collectionView.cellForItem(at: index) as? PhotoCell {
                        if currentCell.imageUrl == imageUrl {
                            currentCell.imageView.image = UIImage(data: data)
                            cell.activityIndicator.stopAnimating()
                        }
                    }
                        photo.image = NSData(data: data) as Data
                        DispatchQueue.global(qos: .background).async {
                            try? DataController.shared.backgroundContext.save()
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Methods
    
    @objc func dismissPhotoAlbum() {
        dismiss(animated: true)
    }
    
    @objc func handleLoadNewCollection() {
        for photos in fetchedResultsController.fetchedObjects! {
            DataController.shared.viewContext.delete(photos)
        }
        try? DataController.shared.viewContext.save()
        downloadPhotos()
    }
    
    
    
}
