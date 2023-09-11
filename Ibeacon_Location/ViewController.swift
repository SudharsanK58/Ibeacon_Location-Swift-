import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    var hexRecords: String?
    var locationManager: CLLocationManager!
    var centralManager: CBCentralManager!
    var targetPeripheral: CBPeripheral?

    @IBOutlet weak var nValueLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    var nValue: Float = 1
    let BLE_Characteristic_uuid_Tx = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")//(Property = Write without response)
        let BLE_Characteristic_uuid_Rx = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")// (Property = Read/Notify)
    var characteristicASCIIValue = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()

        centralManager = CBCentralManager(delegate: self, queue: nil)
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
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            // Handle Bluetooth not available or powered off state
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            if deviceName == "BIBO 1.1 C" {
                print("Found target device: \(deviceName)")
//                print(peripheral)
                targetPeripheral = peripheral
                centralManager.connect(peripheral, options: nil)
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name ?? "")")
        targetPeripheral?.delegate = self
        targetPeripheral?.discoverServices([CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)

        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            // Replace with the UUID of the UART characteristic if known
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                let message = "201010#Offline#0#12345678#12-02-2022 18:00#11-09-2024 16:00"
                if let data = message.data(using: .utf8) {
                    peripheral.writeValue(data, for: characteristic, type: .withResponse) // Or .withoutResponse if appropriate
                }
            }
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx){
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
        }
    }


    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing value to characteristic: \(error)")
        } else {
            print("Successfully wrote value to characteristic")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            if  characteristic.isNotifying {
                print("manisha",characteristic.isNotifying)
                
                if (characteristic.value != nil) {
                    if characteristic.uuid == BLE_Characteristic_uuid_Rx{
                        print("print",characteristic)
                        if let ASCIIstring = String(data: characteristic.value!, encoding: String.Encoding.utf8) {
                            characteristicASCIIValue = ASCIIstring
                            
                            if characteristicASCIIValue.count == 20 {
                                
                                
                                
                                print("Value Recieved: \((characteristicASCIIValue as String))\n")
                            }
                        }
                    }
                }
            }
        }
    
}
