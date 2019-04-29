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

// class that represents user on the map
class UserLocation: NSObject, MKAnnotation {
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
        
        let allUsersRef: CollectionReference? = db.collection("users")
        
        let currUserRef: DocumentReference? = allUsersRef?.document((Auth.auth().currentUser?.email)!)
        
        currUserRef?.updateData(["location": GeoPoint(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)])
        
        // loop through all users
        allUsersRef?.getDocuments() { (querySnapshot, err) in
            if err != nil {
                print("Error getting all users")
            } else {
                
                for document in querySnapshot!.documents {
                    
                    if document.data()["location"] != nil {
                        
                        // TODO: create public/private bool to determine whether to show user on map
                        
                        // document id is the same as username
                        let username = document.documentID
                        
                        // don't annotate map with current user
                        if username != Auth.auth().currentUser?.email {
                            let gp: GeoPoint = document.data()["location"] as! GeoPoint
                            
                            let userToShow = UserLocation(title: username, coordinate: CLLocationCoordinate2D(latitude: gp.latitude, longitude: gp.longitude))
                            
                            // place pin on map with username under it
                            self.mapView.addAnnotation(userToShow)
                        }
                        
                    }
                    
                }
            }
        }
        
    
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
