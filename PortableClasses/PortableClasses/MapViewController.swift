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

class MapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var tableView: UITableView!
    var usersArray = [String]()
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        label.textColor = UIColor(red:1.00, green:0.96, blue:0.41, alpha:1.0)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
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
        
        // set table delegate to this view controller
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let db = Firestore.firestore()
        let allUsersRef: CollectionReference? = db.collection("users")
        
        // loop through all users
        allUsersRef?.getDocuments() { (querySnapshot, err) in
            if err != nil {
                print("Error getting all users")
            } else {
                for document in querySnapshot!.documents {
                    // TODO: create public/private bool to determine whether to show user on map
                    
                    // document id is the same as username
                    let username = document.documentID
                    
                    // // add users to the array to display in the table but don't include current user
                    if username != Auth.auth().currentUser?.email {
                        
                        // only show public users
                        if document.data()["public"] as! Bool {
                             self.usersArray.append(username)
                        }
                       
                        // asynchronously reload table everytime a user is added to the array
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
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
                            // don't show private users
                            if document.data()["public"] as! Bool {
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
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    // table methods
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return usersArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usernameCell", for: indexPath)
        
        
        cell.backgroundColor = UIColor(cgColor: (tableView.backgroundColor?.cgColor)!)
        
        let usr = usersArray[indexPath.row]
        cell.textLabel?.text = usr
        
        cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(usersArray[indexPath.row])
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
