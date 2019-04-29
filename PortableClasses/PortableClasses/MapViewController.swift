//
//  MapViewController.swift
//  PortableClasses
//
//  Created by david krauskopf-greene on 4/24/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class CityLocation: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        mapView.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        else {
            print("Please turn on location services or GPS")
        }
    }
    
    //MARK: CLLocationManager Delagates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        self.mapView.setRegion(region, animated: true)
        
        let db = Firestore.firestore()
        var userRef: DocumentReference? = nil
        userRef = db.collection("users").document((Auth.auth().currentUser?.email)!)
        userRef?.updateData(["location": GeoPoint(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)])
        
        let test = CityLocation(title: "Test", coordinate: CLLocationCoordinate2D(latitude: 37, longitude:-122))
        mapView.addAnnotation(test)
        mapView.addAnnotations([test])
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}
