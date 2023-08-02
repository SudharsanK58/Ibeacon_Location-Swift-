import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    var hexRecords: String?
    var storedLines: [String] = []
    var locationManager: CLLocationManager!
    var centralManager: CBCentralManager!
    var targetPeripheral: CBPeripheral?
    var responseString: String?
    
    @IBOutlet weak var nValueLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    var nValue: Float = 1

    override func viewDidLoad() {
        super.viewDidLoad()
//        // Call the function to store the non-empty lines from the dynamic API response
//        storeNonEmptyLinesFromDynamicResponse()

        // Wait for a moment to allow API request and response
//        sleep(4)

//        // Call the function to print the stored lines with a delay of 100 milliseconds
//        printStoredLinesOneByOne()
////        fetchHexRecords()
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
            if deviceName == "QE_V2" {
                print("Found target device: \(deviceName)")
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
            peripheral.discoverCharacteristics([CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")], for: service)

        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            guard let characteristics = service.characteristics else { return }

            for characteristic in characteristics {
//                print(characteristic)
                // Replace with the UUID of the UART characteristic if known
                if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
//                    let message = ":100000004643464200000156000000000103030081\n:1000100000000000000000000000000000000000E0"
                    let message = ":0200000460009A\r:100000004643464200000156000000000103030081\r:1000100000000000000000000000000000000000E0\r:100060000000000000000000000000000000000090\r:00000001FF"
                    print(message.count)
                    if let data = message.data(using: .utf8) {
                        peripheral.writeValue(data, for: characteristic, type: .withResponse) // Or .withoutResponse if appropriate
                    }
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
    func sendHex(hexLine: String) -> String{
        return hexLine
    }
    func printLinesWithDelay(lines: [String], currentIndex: Int) {
        if currentIndex < lines.count {
            let line = lines[currentIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            if !line.isEmpty {
                print(line)
            }
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 1) {
                self.printLinesWithDelay(lines: lines, currentIndex: currentIndex + 1) // Call recursively with a delay of 1 second (1000ms)
            }
        }
    }

    func fetchHexRecords() {
        let url = URL(string: "https://karthi.ind.in/trynew.hex")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                print("No data received")
                return
            }

            // Remove empty lines and whitespace characters from the response string
            let filteredResponse = responseString.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")

            // Print the response line by line with a delay of 1 second
            let lines = filteredResponse.components(separatedBy: ":")
            self.printLinesWithDelay(lines: lines, currentIndex: 0)
        }.resume()
    }

    func storeNonEmptyLinesFromDynamicResponse() {
        // The API URL
        let urlString = "https://iot-api.karthi.ind.in/news-api/download/frimware?url=https://karthi.ind.in/trynew.hex"
        
        // Create a URL from the string
        if let url = URL(string: urlString) {
            // Create a URLSession
            let session = URLSession.shared
            
            // Create a data task with the URL
            let task = session.dataTask(with: url) { data, response, error in
                // Check for errors
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                // Check if we received a response
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("No response received")
                    return
                }
                
                // Check the status code of the response
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Invalid response: \(httpResponse.statusCode)")
                    return
                }
                
                // Check if we received any data
                guard let responseData = data else {
                    print("No data received")
                    return
                }
                
                // Process and print the data as a String
                if let responseString = String(data: responseData, encoding: .utf8) {
                    print("API Response:\n\(responseString)")
                } else {
                    print("Invalid data format")
                }
            }
            
            // Start the data task
            task.resume()
        } else {
            print("Invalid URL")
        }
    }

    
    func printStoredLinesOneByOne() {
        // Iterate through the stored lines
        for line in storedLines {
            // Print the line
            print(line)
            
            // Add a delay of 100 milliseconds
            Thread.sleep(forTimeInterval: 0.1)
        }
    }

}
