import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var nValueLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    var nValue:Float = 1
    let test = KalmanFilter(R: 0.008, Q: 0.1)

    // Test data
    let testData: [Float] = [-66, -64, -63, -63, -63, -66, -65, -67, -58, -60, -61, -59, -60, -63, -65, -67, -66, -68, -69, -68, -69, -70, -72, -70, -71, -70, -72, -71, -73, -72]

    // Arrays to store the data for plotting
    var x_values: [Float] = []
    var filtered_values: [Float] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
//        for x in testData {
//            let filtered_x = test.filter(measurement: x)
//
//            // Append the values to the respective arrays
//            x_values.append(x)
//            filtered_values.append(filtered_x)
//
//            // Print the data and filtered data
//            print("Data:", x)
//            print("Filtered Data:", filtered_x)
//        }
        
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
            let filtered_rssi = test.filter(measurement: Float(RSSI))
            x_values.append(Float(RSSI))
            filtered_values.append(filtered_rssi)
            rssiLabel.text = "Rssi: \(RSSI) db"
//            var printLabel: String = ""
//            let distance = pow(10.0, (TxPower - RSSI) / Double((Int(nValue))))
//            let distanceInFeet = distance * 3.28084
//            let formattedDistance = String(format: "%.2f", distanceInFeet)
//            printLabel = "Filtered Rssi: \(formattedDistance) db"
//            print(printLabel)
//            print(nValue)

            
            if filtered_values.count >= 10 && filtered_values.count % 10 == 0 {
                let average_rssi = filtered_values.suffix(10).reduce(0, +) / 10.0
                let formattedDistance = String(format: "%.2f", average_rssi)
                let printLabel = "Filtered RSSI: \(formattedDistance) db"
                distanceLabel.text = printLabel
                print(filtered_values)
            }
            
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
