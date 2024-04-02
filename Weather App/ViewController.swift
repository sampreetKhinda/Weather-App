//
//  ViewController.swift
//  Weather App
//
//  Created by Sampreet singh on 01/04/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var ciscriptionLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    let degreeSymbol = "\u{00B0}"
    
    var URL_LATITUDE = "30.6099"
    var URL_LONGITUDE = "76.2307"
    let URL_API_KEY = "API_key"
    var URL_GET_ONE_CALL = ""
    let URL_BASE = "https://api.openweathermap.org/data/2.5"
    
    var locationManger: CLLocationManager!
    var currentlocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getLocation()
    }
    
    func metersPerSecondToKilometersPerHour(_ metersPerSecond: Double) -> String {
        let conversionFactor = 3.6
        return String(metersPerSecond * conversionFactor)
    }

    func buildURL() -> String {
        URL_GET_ONE_CALL = "/weather?lat=" + URL_LATITUDE + "&lon=" + URL_LONGITUDE + "&units=imperial" + "&appid=" + URL_API_KEY
        return URL_BASE + URL_GET_ONE_CALL
    }
    
    func makeAPICall() {
        guard let url = URL(string: buildURL()) else { return }
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            
            if let data = data {
                do {
                    let jsonData = try JSONDecoder().decode(Result.self, from: data)
                    DispatchQueue.main.async {
                        self.cityLabel.text = jsonData.name
                        self.ciscriptionLabel.text = String(jsonData.weather?[0].description ?? "").capitalized
                        self.tempLabel.text = String(jsonData.main?.temp! ?? 0.0 ) + "\(self.degreeSymbol)"
                        self.humidityLabel.text = "Humidity : "+String(jsonData.main?.humidity ?? 0) + "%"
                        self.windLabel.text = "Wind : " + self.metersPerSecondToKilometersPerHour(jsonData.wind?.speed ?? 0.0) + " km/h"
                        self.weatherImageView.image = UIImage(named: jsonData.weather?[0].icon ?? "02d")
                    }
                    
                } catch {
                    print("SOME ERROR IN DATA.")
                }
            } else {
                print("SOME ERROR FROM SERVER.")
            }
        }
        task.resume()
    }
    
    func getLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManger = CLLocationManager()
            locationManger.delegate = self
            locationManger.desiredAccuracy = kCLLocationAccuracyBest
            locationManger.requestWhenInUseAuthorization()
            locationManger.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentlocation = location
            
            let latitude: Double = self.currentlocation!.coordinate.latitude
            let longitude: Double = self.currentlocation!.coordinate.longitude
            
            URL_LATITUDE = String(latitude)
            URL_LATITUDE = String(longitude)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
            }
            self.locationManger.stopUpdatingLocation()
            makeAPICall()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint(error.localizedDescription)
    }
}
