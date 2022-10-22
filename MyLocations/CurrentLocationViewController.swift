//
//  ViewController.swift
//  MyLocations
//
//  Created by Celeste Urena on 10/21/22.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    // Stores user's location
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateLabels()
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(didTimeOut),
                userInfo: nil,
                repeats: false)
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    @objc func didTimeOut() {
        // print("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(
                domain: "MyLocationsErrorDomain",
                code: 1,
                userInfo: nil)
            updateLabels()
        }
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    func string(from placemark: CLPlacemark) -> String {
        // Create a new string variable for the first line of text
        var line1 = ""
        // If the placemark has a subThoroughfare, add it to the string
        if let tmp = placemark.subThoroughfare {
            line1 += tmp + " "
        }
        // Adding the thoroghfare or street name
        if let tmp = placemark.thoroughfare {
            line1 += tmp
        }
        // Same logic for the second line
        var line2 = ""
        if let tmp = placemark.locality {
            line2 += tmp + " "
        }
        if let tmp = placemark.administrativeArea {
            line2 += tmp + " "
        }
        if let tmp = placemark.postalCode {
            line2 += tmp
        }
        // The two lines are concatenated
        return line1 + "\n" + line2
    }
    
    // MARK: - Actions
    // Tells the location manager to receive locations with an accuracy of up to ten meters
    @IBAction func getLocation() {
        
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        // Tells user that location services are disabled if so
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // print("didFailWithError \(error.localizedDescription)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        let newLocation = locations.last!
        // print("didUpdateLocations \(newLocation)")
        
        // cached result if location result takes over 5 secs
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        // To determine whether new readings are more accurate than previous
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        // Calculates the distance between the new reading and the previous reading, if there was one
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            // Clears out previous error and stores the new CLLocation object into the location var
            lastLocationError = nil
            location = newLocation
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                // Forces a reverse geocoding for the final location
                if distance > 0 {
                    performingReverseGeocoding = false
                }
                
                // print("*** We're done!")
                stopLocationManager()
            }
            updateLabels()
            
            // If coordinate from reading is not significantly diff. after more than 10 secs, then stop reading
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                // print("*** Force done!")
                stopLocationManager()
                updateLabels()
            }
            
            if !performingReverseGeocoding {
                // print("*** Going to geocode")
                
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation) {placemarks, error in
                    self.lastGeocodingError = error
                    if error == nil, let places = placemarks, !places.isEmpty {
                        self.placemark = places.last!
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                }
            }
            
        }
    }
    
    // MARK: - Helper Methods
    // Displays message if location setting isn't allowed in app
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(
                format: "%.8f",
                location.coordinate.latitude)
            longitudeLabel.text = String(
                format: "%.8f",
                location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
        configureGetButton()
    }
    
}


