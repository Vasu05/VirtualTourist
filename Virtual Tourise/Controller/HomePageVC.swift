//
//  ViewController.swift
//  Virtual Tourise
//
//  Created by vasu on 15/01/19.
//  Copyright © 2019 Vasu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class HomePageVC: UIViewController {

    @IBOutlet weak var mMapView: MKMapView!
    var dataController:DataController!
    
    var mapPins: [Pin] = []
    
    var mCenterPoint : CenterPoint!
 
    var tappedLocationCoordinate : CLLocationCoordinate2D!
    var selectedPin : Pin?
    
    fileprivate func setupFetchedResults() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        if let result =  try? dataController.viewContext.fetch(fetchRequest){
          
            mapPins = result
        
        }else{
            print("Error while fetching Pins from CoreData.....")
        }
        
         var annotations = [MKPointAnnotation]()
        
        for pin in mapPins{
            
            let lat = CLLocationDegrees(pin.latitude)
            let long = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Tap to know more"
            annotations.append(annotation)
        }
        
        mMapView.addAnnotations(annotations)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResults()
        configureUI()
        
    }
    
    func configureUI(){
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.5
        mMapView.addGestureRecognizer(longPressRecogniser)
        mMapView.delegate = self
        
        let fetchRequest:NSFetchRequest<CenterPoint> = CenterPoint.fetchRequest()

        if let result =  try? dataController.viewContext.fetch(fetchRequest){

            if result.count > 0{
                mCenterPoint = result[result.count - 1]
                let coordinate = CLLocationCoordinate2D(latitude: mCenterPoint.latitude, longitude: mCenterPoint.longitude)
              
                let span = MKCoordinateSpan(latitudeDelta: mCenterPoint.latitudeDelta  , longitudeDelta:mCenterPoint.longituteDelta)
                
                 let coordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
                mMapView.setRegion(coordinateRegion, animated: true)

            }

        }else{
            print("Error while fetching center location from CoreData.....")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.isHidden = true
    }
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        
        let touchPoint = gestureRecognizer.location(in: mMapView)
        let touchMapCoordinate = mMapView.convert(touchPoint, toCoordinateFrom: mMapView)
        
        let annotation  = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        annotation.title = "Tap to know more"
        mMapView.addAnnotation(annotation)
        
        //-------coredata saving....
        savePinLocation(latlong: touchMapCoordinate)
      
    }
    
    func savePinLocation(latlong:CLLocationCoordinate2D){
        
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = latlong.latitude
        pin.longitude = latlong.longitude
        
        do{
            try dataController.viewContext.save()
        }catch{
             print("Error while saving .....\(error.localizedDescription)  ....")
        }
        mapPins.append(pin)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "PhotoDisplayVC" {
        
            if let vc = segue.destination as? PhotoDisplayVC {
                
                vc.pCoordinate = tappedLocationCoordinate
                vc.dataController = dataController
                vc.pPin = selectedPin
            }
        }
    }
        
    
}

extension HomePageVC : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let cgPoint = mMapView.centerCoordinate
        
        let extra = mMapView.region.span
        
        if mCenterPoint != nil{
            mCenterPoint.latitude = cgPoint.latitude
            mCenterPoint.longitude = cgPoint.longitude
            
            mCenterPoint.latitudeDelta = extra.latitudeDelta
            mCenterPoint.longituteDelta = extra.longitudeDelta
        }
        else{
            
            let center = CenterPoint(context: dataController.viewContext)
            center.latitude = cgPoint.latitude
            center.longitude = cgPoint.longitude
            center.latitudeDelta = extra.latitudeDelta
            center.longituteDelta = extra.longitudeDelta
            
            
            do{
                try dataController.viewContext.save()
                
            }catch{
                
                print("delegate method: Error while saving .....\(error.localizedDescription)  ....")
            }
        }
      
        //print(coordinate)
    }
    
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            let annotation = view.annotation
            let index = (mMapView.annotations as NSArray).index(of: annotation!)
            
            selectedPin =  mapPins[index]
            tappedLocationCoordinate = view.annotation?.coordinate
            performSegue(withIdentifier: "PhotoDisplayVC", sender: nil)
            print(selectedPin!.latitude)
  
        }
    }

}

