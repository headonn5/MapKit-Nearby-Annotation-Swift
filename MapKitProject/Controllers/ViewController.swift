import UIKit
import MapKit

class ViewController: UIViewController {
    

    @IBOutlet var locationManager: LocationManager!
    private var boundingRegion: MKCoordinateRegion?
    private var currentLocationObserver: NSObjectProtocol?
    private var spinner: SpinnerView?
    
    private var places: [MKMapItem]?
    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            places = nil
            localSearch?.cancel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner = SpinnerView(frame: self.view.frame)
        spinner!.labelColor = UIColor.gray
        spinner!.addChildView(toView: self.view, atYOffset: -100.0, andXOffset: 0.0, withText: "Fetching Location...")
        
        self.currentLocationObserver = NotificationCenter.default.addObserver(forName: Notification.Name("CurrentLocationUpdated"), object: nil, queue: nil) { [weak self] (_) in
            if let location = self?.locationManager.currentLocation {
                
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 50_000, longitudinalMeters: 50_000)
                self?.boundingRegion = region
                self?.search(for: "International Airport nearby")
            }
            // Remove the spinner from the view
            DispatchQueue.main.async {
                if let sv = self?.spinner {
                    sv.removeFromSuperview()
                    self?.spinner = nil
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestLocation()
    }

    @IBAction func showPorts(_ sender: UIButton) {
        performSegue(withIdentifier: "showPortsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPortsSegue" {
            
            guard let mapViewController = segue.destination as? MapViewController else {
                return
            }
            
            // Pass the new bounding region to the map destination view controller.
            mapViewController.boundingRegion = boundingRegion
            
            // Pass the list of places found to our map destination view controller.
            mapViewController.mapItems = places

        } 
    }
    
    /// - Parameter queryString: A search string from the text the user entered into `UISearchBar`
    private func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }
    
    private func search(using searchRequest: MKLocalSearch.Request) {
        // Confine the map search area to an area around the user's current location.
        if let region = boundingRegion {
            searchRequest.region = region
        }
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [weak self] (response, error) in
            guard error == nil else {
                self?.displaySearchError(error)
                return
            }
            
            self?.places = response?.mapItems
            
            // Used when setting the map's region in `prepareForSegue`.
            self?.boundingRegion = response?.boundingRegion
        }
    }
    
    private func displaySearchError(_ error: Error?) {
        if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: "Could not find any places.", message: errorString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
}

