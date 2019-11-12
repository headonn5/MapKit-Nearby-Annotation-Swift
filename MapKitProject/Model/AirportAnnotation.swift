import MapKit
import Contacts

class AirportAnnotation: NSObject, MKAnnotation {
    
    /*
     This property is declared with `@objc dynamic` to meet the API requirement that the coordinate property on all MKAnnotations
     must be KVO compliant.
     */
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    
    var locationName: String? {
        return self.title
    }
    
    /*
     This method returns the MKMapItem object from the location name of the annotation
    */
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: locationName!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = locationName!
        return mapItem
    }

}
