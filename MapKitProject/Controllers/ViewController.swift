import UIKit
import MapKit

class ViewController: UIViewController {
    

    @IBOutlet weak var showPortsButton: UIButton!
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
    
    func removeSpinner() {
        if let sv = spinner {
            sv.removeFromSuperview()
            spinner = nil
        }
    }
    
    func addSpinner(withText text: String) {
        spinner = SpinnerView(frame: self.view.frame)
        spinner!.labelColor = UIColor.gray
        spinner!.addChildView(toView: self.view, atYOffset: -100.0, andXOffset: 0.0, withText: text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Spinner view
        addSpinner(withText: "Fetching Location...")
        
        // Disable show ports button
        showPortsButton.isUserInteractionEnabled = false
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) {[unowned self] (_) in
            self.locationManager.requestLocation()
        }
        
        self.currentLocationObserver = NotificationCenter.default.addObserver(forName: Notification.Name("CurrentLocationUpdated"), object: nil, queue: nil) { [weak self] (_) in
            if let location = self?.locationManager.currentLocation {
                
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 50_000, longitudinalMeters: 50_000)
                self?.boundingRegion = region
            }
            
            // Enable show ports button
            self?.showPortsButton.isUserInteractionEnabled = true
            
            // Remove the spinner from the view
            DispatchQueue.main.async {
                self?.removeSpinner()
            }
        }
    }

    @IBAction func showPorts(_ sender: UIButton) {
        // MKLocalSearch Request should not be called from the completion handler. This gives error occasionally
        search(for: "International airports nearby")
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
        // Add Spinner
        addSpinner(withText: "Searching...")
        
        // Confine the map search area to an area around the user's current location.
        if let region = boundingRegion {
            searchRequest.region = region
        }
        
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [weak self] (response, error) in
            
            // Remove Spinner
            DispatchQueue.main.async {
                self?.removeSpinner()
            }
            
            guard error == nil else {
                self?.displaySearchError(error)
                return
            }
            
            self?.places = response?.mapItems
            
            // Used when setting the map's region in `prepareForSegue`.
            self?.boundingRegion = response?.boundingRegion
            
            // Move to maps view when the search results are shown
            self?.performSegue(withIdentifier: "showPortsSegue", sender: self)
        }
    }
    
    private func displaySearchError(_ error: Error?) {
        if let error = error as NSError?, error.code == 4 {
            let alertController = UIAlertController(title: "Could not find any places.", message: "Press OK to re-search or Cancel to abort", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
                print("The key window did not have a root view controller")
                return
            }
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
}

