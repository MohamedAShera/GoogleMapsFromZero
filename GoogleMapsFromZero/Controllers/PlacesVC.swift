//
//  PlacesVC.swift
//  GoogleMapsFromZero
//
//  Created by apple on 5/16/19.
//  Copyright © 2019 mohamed. All rights reserved.
//

import UIKit
import GooglePlaces
import SwiftyJSON
import Alamofire
import GoogleMaps

class PlacesVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextfield: UITextField!
    var currentLocation: CLLocation?
    var latitude: Double?
    var longitude: Double?
    var placeName = [String]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    var placeDistancce = [String]()
    var placeAddress = [String]()
    var result = [Results]()
    var coordinate: CLLocationCoordinate2D?
    var distanceInMeters: Double?

    private let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
    }
    func fetchPlacesNearCoordinate() {
        Alamofire.request(NetworkConstant.baseUrl + "\(latitude!),\(longitude!)&radius=1000&keyword=restaurant&key=" + googleApiKey).responseJSON{
            (response) in
            do {
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(ModelApi.self, from: response.data!)
                //responseModel.results?[0].geometry?.location?.lat
                print("nnnnnnnnnnn\(self.result.count)")
                let data = responseModel.results?.map{$0}
                for i in data! {
                    let coordinate0 = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
                    let coordinate1 = CLLocation(latitude: i.geometry?.location?.lat ?? 0.0, longitude: i.geometry?.location?.lng ?? 0.0)
                     self.placeName.append(i.name ?? "")
                    self.distanceInMeters = coordinate0.distance(from: coordinate1).rounded()
                    //self.placeDistancce.append("\(self.distanceInMeters!) meter")
                    if self.distanceInMeters! < 1000.0 {
                       self.placeDistancce.append("\(self.distanceInMeters!) meter")
                    } else {
                        self.placeDistancce.append("\(self.distanceInMeters! / 1000.0) KM")
                    }
                    self.latitudeArray.append((i.geometry?.location?.lat)!)
                    self.longitudeArray.append((i.geometry?.location?.lng)!)
                    self.placeAddress.append(i.vicinity!)
                }
                self.tableView.reloadData()
                 print("nnnnnnnnnnn\(self.result.count)")
            }catch{
                print("No internet connection")
            }
        }
    }
    
    // search in google place the action must be did begin edit 
    @IBAction func searchTxtFieldPressed(_ sender: Any) {
        searchTextfield.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
}
extension PlacesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PlacesCell
        cell.placeNameLbl.text = placeName[indexPath.row]
        cell.placeDistanceLbl.text = placeDistancce[indexPath.row]
        cell.placeAddressLbl.text = placeAddress[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "Map") as! MapVC
        vc.latitude = latitudeArray[indexPath.row]
        vc.longitude = longitudeArray[indexPath.row]
        vc.restaurantName = placeName[indexPath.row]
        vc.distance = "The distance is: \(placeDistancce[indexPath.row])"
        vc.address = placeAddress[indexPath.row]
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension PlacesVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // check if user grant your premission to access the location
        guard status == .authorizedWhenInUse else {
            return
        }
        //When have permissions to access location , ask the location manager for updates on the user’s location.
        locationManager.startUpdatingLocation()
       
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        print(self.placeName)
        self.placeName.removeAll()
        self.placeDistancce.removeAll()
        fetchPlacesNearCoordinate()
//        locationManager.stopUpdatingLocation()
    }
    
}
// to start search in google place
extension PlacesVC: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        searchTextfield.text = place.name
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
