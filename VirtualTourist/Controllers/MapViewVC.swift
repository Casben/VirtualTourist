//
//  MapViewVC.swift
//  VirtualTourist
//
//  Created by Herbert Dodge on 7/25/20.
//  Copyright © 2020 Herbert Dodge. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewVC: UIViewController {
    
    //MARK: - Properties
    
    let mapView = MKMapView()
    let editHeaderView = UIView()
    let editLabel = CustomLabel(title: "Tap on a pin to delete.", fontSize: 22)
    var pinAnnotation: MKPointAnnotation? = nil
    var pins: [Pin] = []
    

    //MARK: - Lifecyles
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        loadAllPins()
    }
    
    
    
    //MARK: - Methods
    
    func loadAllPins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? DataController.shared.viewContext.fetch(fetchRequest) {
            pins = result
        }
        loadAllPinsToMap()
    }
    
    func loadAllPinsToMap() {
        DispatchQueue.main.async {
            for pin in self.pins {
                let coordinates = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                self.mapView.addAnnotation(annotation)
            }
        }
    }

    func retrieveASinglePin(latitude: Double, longitude: Double) -> Pin? {
        for pin in pins {
            if pin.latitude == latitude && pin.longitude == longitude {
                return pin
            }
        }
        return nil
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        editHeaderView.isHidden = !editing
    }
    
    //MARK: - Helpers
    
    @objc func handleAddPinToMap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: mapView)
        let locationCoordinates = mapView.convert(location, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            pinAnnotation = MKPointAnnotation()
            pinAnnotation?.coordinate = locationCoordinates
            
            mapView.addAnnotation(pinAnnotation!)
        } else if sender.state == .ended {
            
            let pinToBeSaved = Pin(context: DataController.shared.viewContext)
            pinToBeSaved.latitude = pinAnnotation!.coordinate.latitude
            pinToBeSaved.longitude = pinAnnotation!.coordinate.longitude
            pins.append(pinToBeSaved)
            do {
                try DataController.shared.viewContext.save()
            } catch {
                print("Unable to save pin to context.")
            }
        }
    }
    
    func configure() {
        configureMapView()
        configureNavigationBar()
        view.addSubviews(editHeaderView)
        editHeaderView.addSubviews(editLabel)
        
        NSLayoutConstraint.activate([
            editHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            editHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editHeaderView.heightAnchor.constraint(equalToConstant: 50),
            
            editLabel.centerYAnchor.constraint(equalTo: editHeaderView.centerYAnchor),
            editLabel.centerXAnchor.constraint(equalTo: editHeaderView.centerXAnchor),
            editLabel.leadingAnchor.constraint(equalTo: editHeaderView.leadingAnchor),
            editLabel.trailingAnchor.constraint(equalTo: editHeaderView.trailingAnchor)
        ])
        
        editHeaderView.backgroundColor = .systemIndigo
        editHeaderView.isHidden = true
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .systemIndigo
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    func configureMapView() {
        view = mapView
        mapView.delegate = self
        let longPressTap = UILongPressGestureRecognizer(target: self, action: #selector(handleAddPinToMap(_:)))
        mapView.addGestureRecognizer(longPressTap)
    }
    
}
//MARK: - MapView Delegate
extension MapViewVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.pinTintColor = .systemIndigo
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        mapView.deselectAnnotation(annotation, animated: true)
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        if let pin = retrieveASinglePin(latitude: latitude, longitude: longitude) {
            if isEditing {
                mapView.removeAnnotation(annotation)
                DataController.shared.viewContext.delete(pin)
                do {
                    try DataController.shared.viewContext.save()
                } catch {
                    print("unable to delete pin")
                }
                return
            }
            let photoVC = PhotoAlbumVC()
            photoVC.passedInAnnotation = annotation
            photoVC.passedInPin = pin
            let destinationVC = UINavigationController(rootViewController: photoVC)
            destinationVC.modalPresentationStyle = .fullScreen
            present(destinationVC, animated: true)
        }
    }
    
}
