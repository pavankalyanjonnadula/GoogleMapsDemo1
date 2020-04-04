//
//  ViewController.swift
//  GoogleMapsDemo
//
//  Created by syamala on 13/04/18.
//  Copyright © 2018 syamala. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


class ViewController: UIViewController,CLLocationManagerDelegate,URLSessionDelegate,GMSMapViewDelegate,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var buttonsView: UIView!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var threeDotButton: UIButton!
    
    @IBOutlet weak var button1: UIButton!
    
    @IBOutlet weak var button3: UIButton!
    
    @IBOutlet weak var button2: UIButton!
    
    @IBOutlet weak var button4: UIButton!
    
    @IBOutlet weak var listtableView: UITableView!
    
    @IBOutlet weak var toLocationview: UIView!
    
    @IBOutlet weak var fromLocationView: UIView!
    
    @IBOutlet weak var fromLocationTextField: UITextField!
    
    @IBOutlet weak var toLocationtextfield: UITextField!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    // var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?
    var likelyPlaces: [GMSPlace] = []
    var isdestination = false
    var removepolyline : GMSPolyline?
    var istrrafficenable = true

    var source = CLLocationCoordinate2D(latitude: 16.439235, longitude: 80.568695)
    var destination = CLLocationCoordinate2D(latitude: 16.517452, longitude: 80.621674)
    let myarray = ["options1","options2","options3","options4","options5","options6","options7"]
    private var heatmapLayer: GMUHeatmapTileLayer!
    private var gradientColors = [UIColor.red, UIColor.green]
    private var gradientStartPoints = [0.2, 1.0] as? [NSNumber]
    
    
    override func viewDidLoad() {
//        let camera = GMSCameraPosition.camera(withLatitude: -33.868,longitude: 151.2086,zoom: zoomLevel)
//        mapView.camera = camera
//        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        mapView.camera = GMSCameraPosition.camera(withTarget: source, zoom: zoomLevel, bearing: 0, viewingAngle: 0)
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.padding = UIEdgeInsetsMake(0, 0, 10, 65)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapType = GMSMapViewType(rawValue: 1)!
        mapView.isHidden = true
        mapView.isMyLocationEnabled=true
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()
        circleButton(button: [threeDotButton,button1,button2,button3,button4])
        buttonsView.isHidden = true
        listtableView.isHidden = true
        listtableView.delegate = self
        listtableView.dataSource = self
        fromLocationView.isHidden = true
        toLocationview.isHidden = true
        initializeheatmap()
    }
    
    func initializeheatmap(){
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.radius = 100
        heatmapLayer.opacity = 1
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,
                                            startPoints: gradientStartPoints!,
                                            colorMapSize: 256)
        heatmapLayer.map = mapView
        
    }
    

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        mapView.clear()
//        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
//        circle(lat: coordinate.latitude, long: coordinate.longitude)
//        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude,
//                                              longitude: coordinate.longitude,
//                                              zoom: zoomLevel)
//        putmarker(camera: camera)
//
    }
    
    func putmarker(camera : GMSCameraPosition){
        let marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = "Hello World"
        marker.appearAnimation = GMSMarkerAnimation.none
        marker.map = mapView
    }

    @IBAction func moreButtonClicked(_ sender: Any) {
        listtableView.isHidden = true
        if buttonsView.isHidden{
            buttonsView.isHidden = false
            threeDotButton.setImage(#imageLiteral(resourceName: "ic_cancel"), for: .normal)
        }
        else{
            buttonsView.isHidden = true
            threeDotButton.setImage(#imageLiteral(resourceName: "ic_more_horiz"), for: .normal)
        }
        
    }
    @IBAction func button2clicked(_ sender: Any) {
        if listtableView.isHidden{
            listtableView.isHidden = false
        }
        else{
            listtableView.isHidden = true
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myarray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath) as! tableCell
        cell.myLabel.text = myarray[indexPath.row]
        return cell
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        circle(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        if self.mapView.isHidden {
            self.mapView.isHidden = false
            self.mapView.camera = camera
            mapView.animate(toViewingAngle: 55)
            putmarker(camera: camera)
        } else {
            mapView.animate(to: camera)
        }
    }
    
    func circle(lat : CLLocationDegrees,long : CLLocationDegrees){
        let circleCenter = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let circ = GMSCircle(position: circleCenter, radius: 500)
        circ.map = mapView
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            self.mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    func getPolylineRoute(){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving&key=AIzaSyD2LmNmIaI5vSEGaKi7a1WjCgoNkC8O_rQ")!
        print(url)
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        guard let routes = json["routes"] as? NSArray else {
                            return
                        }
                        DispatchQueue.main.async {
                            
                            if (routes.count > 0) {
                                let overview_polyline = routes[0] as? NSDictionary
                                let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
                                
                                let points = dictPolyline?.object(forKey: "points") as? String
                                self.showPath(polyStr: points!)
                                let bounds = GMSCoordinateBounds(coordinate: self.source, coordinate: self.destination)
                                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(170, 30, 30, 30))
                                self.mapView!.moveCamera(update)
                            }
                            else{
                                
                            }
                        }
                    }
                }
                catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    @IBAction func routesButtonClicked(_ sender: Any) {
        fromLocationTextField.text = nil
        toLocationtextfield.text = nil
        fromLocationView.isHidden = false
        if removepolyline != nil{
            removepolyline!.map = nil
            removepolyline = nil
        }
    }
    
    func getgeocoding(text : String){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address="+text+"&key=AIzaSyDGso9JQTUGErLrUMVRHAkP6QYycW-tiUQ")!
        print(url)
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                do {
                    let json : [String:Any] = (try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any])!
                    print(json)
                    let results = json["results"] as? [[String: AnyObject]]
                    let result = results![0]
                    guard let geometry = result["geometry"] as? [String:AnyObject],
                        let location = geometry["location"] as? [String:Double],
                        let lat = location["lat"],
                        let lng = location["lng"]
                        else {
                            //let error = NSError()
                            print("No Data")
                            return
                    }
                    DispatchQueue.main.async {
                        if self.isdestination{
                            self.destination = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                            
                            self.getPolylineRoute()
                        }
                        else{
                            self.source = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        }
                    }
                }
                catch {
                    print("error in JSONSerialization")
                    
                }
            }
        })
        task.resume()
        
    }
    
    
    func showPath(polyStr :String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        removepolyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.strokeColor = UIColor.blue
        polyline.map = mapView
    }
    
    
    @IBAction func goButtonClicked(_ sender: Any) {
        if toLocationtextfield.text?.isEmpty == false{
            isdestination = true
            getgeocoding(text: toLocationtextfield.text!)
            self.fromLocationView.isHidden = true
            self.toLocationview.isHidden = true
        }
        else{
            return
        }
    }
    
    
    @IBAction func nextButtonclicked(_ sender: Any) {
        if fromLocationTextField.text?.isEmpty == false{
            getgeocoding(text: fromLocationTextField.text!)
            fromLocationView.isHidden = true
            toLocationview.isHidden = false
            isdestination = false
        }
        else{
            return
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:challenge.protectionSpace.serverTrust!))
    }
    func circleButton(button : [AnyObject])
    {
        for item in button{
            item.layer.cornerRadius = 0.5 * item.bounds.size.width
            item.layer.borderColor = UIColor.black.cgColor
            item.layer.borderWidth = 2.0
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonOnePressed(_ sender: Any) {
        addHeatmap()
    }
    func addHeatmap()  {
        var list = [GMUWeightedLatLng]()
        do {
            // Get the data: latitude/longitude positions of police stations.
            if let path = Bundle.main.url(forResource: "police_stations", withExtension: "json") {
                let data = try Data(contentsOf: path)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [[String: Any]] {
                    for item in object {
                        let lat = item["lat"]
                        let lng = item["lng"]
                        let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat as! CLLocationDegrees, lng as! CLLocationDegrees), intensity: 1.0)
                        list.append(coords)
                    }
                    movethemap(list: object[0])

                } else {
                    print("Could not read the JSON.")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        // Add the latlngs to the heatmap layer.
        heatmapLayer.weightedData = list
        heatmapLayer.map = mapView
    }
    func movethemap(list : [String: Any]){
        
        let camera = GMSCameraPosition.camera(withLatitude: list["lat"] as! CLLocationDegrees,longitude: list["lng"] as! CLLocationDegrees,zoom: 5)
        mapView.camera = camera
        mapView.animate(to: camera)
    }
    @IBAction func buttonThreePressed(_ sender: Any) {
        if istrrafficenable{
        mapView.isTrafficEnabled = true
            istrrafficenable = false
        }
        else{
            istrrafficenable = true
            mapView.isTrafficEnabled = false

        }

    }
    
    
}

