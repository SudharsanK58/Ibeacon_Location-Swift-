import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager: CBCentralManager!
    var targetPeripheral: CBPeripheral?
    var uartCharacteristic: CBCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "37-Device" {
            centralManager.stopScan()
            targetPeripheral = peripheral
            targetPeripheral?.delegate = self
            centralManager.connect(targetPeripheral!, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name ?? "Unknown Device")")
        // Now that we're connected, discover services and characteristics.
        targetPeripheral?.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                // Discover characteristics for the service.
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                // Check if this is the UART characteristic.
                if characteristic.uuid == CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e") {
                    uartCharacteristic = characteristic // Store the UART characteristic reference.
                    // Send the string "301" over the UART characteristic.
                    if let data = "201001#vasanthaka#0#69207825#08-23-2023 20:31#08-23-2023 23:31".data(using: .utf8) {
                        peripheral.writeValue(data, for: characteristic, type: .withResponse)
                    }
                }
            }
        }
    }
}
