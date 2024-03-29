import UIKit
import CoreLocation

class LocationManager: NSObject {
    
    private let locationManager = CLLocationManager()
    
    // Property observer that post notification when the current location is set
    var currentLocation: CLLocation? {
        didSet {
            NotificationCenter.default.post(Notification(name: Notification.Name("CurrentLocationUpdated")))
            print("Current Location is set")
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            displayLocationServicesDisabledAlert()
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

    }
    
    private func displayAlert(_ controller: UIAlertController) {
        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
            print("The key window did not have a root view controller")
            return
        }
        viewController.present(controller, animated: true, completion: nil)
    }
    
    private func displayLocationServicesDisabledAlert() {
        let message = NSLocalizedString("LOCATION_SERVICES_DISABLED", comment: "Location services are disabled")
        let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: "OK alert button"), style: .default, handler: nil))
        displayAlert(alertController)
    }
    
    private func displayLocationServicesDeniedAlert() {
        let message = NSLocalizedString("LOCATION_SERVICES_DENIED", comment: "Location services are denied")
        let alertController = UIAlertController(title: NSLocalizedString("LOCATION_SERVICES_ALERT_TITLE", comment: "Location services alert title"),
                                                message: message,
                                                preferredStyle: .alert)
        let settingsButtonTitle = NSLocalizedString("BUTTON_SETTINGS", comment: "Settings alert button")
        let openSettingsAction = UIAlertAction(title: settingsButtonTitle, style: .default) { (_) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                // Take the user to the Settings app to change permissions.
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        
        let cancelButtonTitle = NSLocalizedString("BUTTON_CANCEL", comment: "Location denied cancel button")
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(openSettingsAction)
        displayAlert(alertController)
    }

}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            displayLocationServicesDeniedAlert()
            currentLocation = nil
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle any errors returned from Location Services.
    }
}
