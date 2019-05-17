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
    
    // access to the map view and location manager
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    // access to table view of users
    @IBOutlet weak var tableView: UITableView!
    // array of users
    var usersArray = [String]()
    
    // user's email
    var userEmail:String!
    
    // variable of table title
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // style the nav bar
        label.textColor = UIColor(red:1.00, green:0.96, blue:0.41, alpha:1.0)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        // show the user's location if their location services are enabled
        mapView.showsUserLocation = true
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            // set the desired accuracy and update the user's location
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        // set table delegate to this view controller
        tableView.delegate = self
        tableView.dataSource = self
        
        // get reference to firebase
        let db = Firestore.firestore()
        // reference to the collection of users
        let allUsersRef: CollectionReference? = db.collection("users")
        // loop through all users
        allUsersRef?.getDocuments() { (querySnapshot, err) in
            if err != nil {}
            else {
                for document in querySnapshot!.documents {
                    // document id is the same as username
                    let username = document.documentID
                    // add users to the array to display in the table but don't include current user
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
    
    override func viewDidAppear(_ animated: Bool) {
        // get the index of the row selected
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    //MARK: CLLocationManager Delagates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // region to show on the map initially (user's location)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        self.mapView.setRegion(region, animated: true)
        
        // get reference to firebase
        let db = Firestore.firestore()
        // reference to the collection of users
        let allUsersRef: CollectionReference? = db.collection("users")
        // reference to the current user
        let currUserRef: DocumentReference? = allUsersRef?.document((Auth.auth().currentUser?.email)!)
        // update the user's location in firebase
        currUserRef?.updateData(["location": GeoPoint(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)])
        // loop through all users
        allUsersRef?.getDocuments() { (querySnapshot, err) in
            if err != nil {}
            else {
                for document in querySnapshot!.documents {
                    if document.data()["location"] != nil {
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
        // only update the location initially
        locationManager.stopUpdatingLocation()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows
        return usersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // configure the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "usernameCell", for: indexPath)
        cell.backgroundColor = UIColor(cgColor: (tableView.backgroundColor?.cgColor)!)
        let usr = usersArray[indexPath.row]
        // set the text field and style the text
        cell.textLabel?.text = usr
        cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // set the user's email to the email selected
        self.userEmail = self.usersArray[indexPath.row]
        // go to that user's semesters view
        performSegue(withIdentifier: "mapToSemesters", sender: self)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        // dismiss the map view
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToSemesters" {
            // pass the user's email to the semester view controller
            let semestersVC = segue.destination as! SemestersTableViewController
            semestersVC.userEmail = self.userEmail
        }
        
    }
}
