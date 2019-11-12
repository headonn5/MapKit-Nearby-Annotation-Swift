import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var mapItems: [MKMapItem]?
    var boundingRegion: MKCoordinateRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the fetched region on to the map
        if let region = boundingRegion {
            mapView.setRegion(region, animated: true)
        }
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.delegate = self
        
        // Register the map view
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let mapItems = mapItems else { return }
        
        // Get annotations (required information) from mapItems
        let annotations = mapItems.compactMap { (mapItem) -> AirportAnnotation? in
            guard let coordinate = mapItem.placemark.location?.coordinate else { return nil}
            
            let annotation = AirportAnnotation(coordinate: coordinate)
            annotation.title = mapItem.name
            return annotation
        }
        
        mapView.addAnnotations(annotations)
    }

}

extension MapViewController: MKMapViewDelegate {
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("Failed to load the map: \(error)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? AirportAnnotation else { return nil }
        
        // Annotation views should be dequeued from a reuse queue to be efficent.
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as? MKMarkerAnnotationView
        // Display the information accessory button that will show the navigation
        // to the destination from the current location
        view?.canShowCallout = true
        let infoButton = UIButton(type: .detailDisclosure)
        view?.rightCalloutAccessoryView = infoButton
        
        return view
    }
    
    /*
     This implementation of the delegate method allows map to zoom in to the user's current location
     */
//    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
//        let annotationView = views.first!
//
//        if let annotation = annotationView.annotation {
//            if annotation is MKUserLocation {
//                var region = MKCoordinateRegion()
//                region.center = mapView.userLocation.coordinate
//                region.span.longitudeDelta = 0.25
//                region.span.latitudeDelta = 0.25
//
//                mapView.setRegion(region, animated: true)
//            }
//        }
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! AirportAnnotation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:
            MKLaunchOptionsDirectionsModeDriving]
        // Open the Maps to show the distance/route from current location to the destination annotation
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}

