//
//  ViewController.swift
//  GoogleMapsFromZero
//
//  Created by apple on 5/16/19.
//  Copyright © 2019 mohamed. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class MapVC: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var goOut: UIButton!
    //(Start) to show the current Location of user
    var currentLocation: CLLocation?
    private let locationManager = CLLocationManager()
    //(End) to show the current Location of user
    var latitude: Double?
    var longitude: Double?
    var currentLatitude: Double?
    var currentLongitude: Double?
    var restaurantName: String?
    var distance: String?
    var address: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        makeMarker()
        let labelHeight = self.goOut.intrinsicContentSize.height
        mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0,
                                            bottom: labelHeight, right: 0)
    }
    func makeMarker() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        marker.title = restaurantName!
        marker.snippet = "\(address!)\n\(distance!)"
        marker.icon = UIImage(named: "restaurant_pin")
        marker.map = mapView
    }
    func fetchRoutingJSON() {
        Alamofire.request("https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLatitude!),\(currentLongitude!)&destination=\(latitude!),\(longitude!)&mode=driving&key=" + googleApiKey).responseJSON { (response) in
            if response.result.value != nil
            {
                let JsonData = try! JSON(data: response.data!)
                let data = JsonData["routes"].array
                for route in data!
                {
                    let routeOverviewPolyline = route["overview_polyline"].dictionary
                    let points = routeOverviewPolyline?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    let polyline = GMSPolyline.init(path: path)
                    polyline.strokeColor = #colorLiteral(red: 0.3427731991, green: 0.5294686556, blue: 0.8347114921, alpha: 1)
                    polyline.strokeWidth = 5
                    polyline.map = self.mapView
                }
            }
        }
    }

    @IBAction func goNowBtn(_ sender: Any) {
        fetchRoutingJSON()
        mapView.camera = GMSCameraPosition(latitude: latitude!, longitude: longitude!, zoom: 15.7, bearing: 0, viewingAngle: 0)
    }
}
// (Start) this extension to get the current location of user and update the location if changed
extension MapVC: CLLocationManagerDelegate {
    // this funcation to grant Authorization to access the current location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // check if user grant your premission to access the location
        guard status == .authorizedWhenInUse else {
            return
        }
        //When have permissions to access location , ask the location manager for updates on the user’s location.
        locationManager.startUpdatingLocation()
        // draws a light blue dot where the user is located
        mapView.isMyLocationEnabled = true
        //adds a button to the map that, when tapped, centers the map on the user’s location
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
    }
    //executes when the location manager receives new location data.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        currentLatitude = location.coordinate.latitude
        currentLongitude = location.coordinate.longitude
        //updates the map’s camera to center around the user’s current location
//        fetchRoutingJSON()
        mapView.camera = GMSCameraPosition(latitude: latitude!, longitude: longitude!, zoom: 17, bearing: 0, viewingAngle: 0)
        
        locationManager.stopUpdatingLocation()


    }
}
// (End) this extension to get the current location of user and update the location if changed
