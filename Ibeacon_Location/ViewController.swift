import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    let beaconNames: [UUID: String] = [
        UUID(uuidString: "88b78a0c-34ae-44d0-b30c-84153fec0f9a")!: "My Beacon 1",
        // Add more UUID-name pairs as needed
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "88b78a0c-34ae-44d0-b30c-84153fec0f9a")!
        let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: "MyBeacon")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            if let beaconName = beaconNames[beacon.uuid] {
                print("Beacon Name: \(beaconName)")
            }
            print("UUID: \(beacon.uuid.uuidString)")
            print("Major: \(beacon.major)")
            print("Minor: \(beacon.minor)")
            print("RSSI: \(beacon.rssi)")
            print("Accuracy: \(beacon.accuracy)")
            print("Timestamp: \(beacon.timestamp)")
            print("Description: \(beacon.description)")
            print("-----")
        }
    }
}
