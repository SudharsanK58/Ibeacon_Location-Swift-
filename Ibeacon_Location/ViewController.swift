import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var nValueLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    var nValue:Float = 1
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
    
    @IBAction func nValueSlider(_ sender: UISlider) {
        nValue = sender.value
        nValueLabel.text = "n value : \(Int(nValue))"
    }
    func startScanning() {
        let uuid = UUID(uuidString: "88b78a0c-34ae-44d0-b30c-84153fec0f9a")!
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 100, minor: 37, identifier: "MyBeacon")

        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            let TxPower: Double = -61 // Fixed TxPower value for your beacon
            let RSSI: Double = Double(beacon.rssi)
            var printLabel: String = ""
            let distance = pow(10.0, (TxPower - RSSI) / Double((Int(nValue))))
            let distanceInFeet = distance * 3.28084
            let formattedDistance = String(format: "%.2f", distanceInFeet)
            printLabel = "Distance: \(formattedDistance) feet"
            print(printLabel)
            print(nValue)
            distanceLabel.text = printLabel
            rssiLabel.text = "Rssi: \(RSSI) db"
        }
    }


    
//    func updateDistance(_ distance: CLProximity) {
//        UIView.animate(withDuration: 0.8) {
//            switch distance {
//                case .unknown:
//                    self.view.backgroundColor = UIColor.gray
//
//                case .far:
//                    self.view.backgroundColor = UIColor.blue
//
//                case .near:
//                    self.view.backgroundColor = UIColor.orange
//
//                case .immediate:
//                    self.view.backgroundColor = UIColor.red
//
//                @unknown default:
//                    // Handle any future unknown values
//                    self.view.backgroundColor = UIColor.black
//            }
//
//        }
//    }
    
}
