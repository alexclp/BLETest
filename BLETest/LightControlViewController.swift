//
//  LightControlViewController.swift
//  BLETest
//
//  Created by Alexandru Clapa on 11/10/2017.
//  Copyright © 2017 Alexandru Clapa. All rights reserved.
//

import UIKit
import CoreBluetooth

class LightControlViewController: UIViewController {
	var connectedPeripheral: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?
	private var characteristicUUID = CBUUID(string: "FFE1")
	private var writeType: CBCharacteristicWriteType = .withoutResponse
	
	@IBOutlet weak var nameLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		connectedPeripheral?.delegate = self
		connectedPeripheral?.discoverServices(nil)
		
		nameLabel.text = connectedPeripheral?.name
    }
	
	@IBAction func lightOnAction(sender: UIButton) {
		guard let peripheral = connectedPeripheral else { return }
		
		if let data = "1".data(using: String.Encoding.utf8) {
			peripheral.writeValue(data, for: writeCharacteristic!, type: writeType)
		}
	}
	
	@IBAction func lightOffAction(sender: UIButton) {
		guard let peripheral = connectedPeripheral else { return }
		
		if let data = "0".data(using: String.Encoding.utf8) {
			peripheral.writeValue(data, for: writeCharacteristic!, type: writeType)
		}
	}
}

extension LightControlViewController: CBPeripheralDelegate {
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		if let services = peripheral.services, let peripheral = connectedPeripheral {
			for service in services {
				peripheral.discoverCharacteristics([characteristicUUID], for: service)
			}
		}
	}
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		for characteristic in service.characteristics! {
			if characteristic.uuid == characteristicUUID {
				peripheral.setNotifyValue(true, for: characteristic)
				writeCharacteristic = characteristic
				writeType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
			}
		}
	}
}
