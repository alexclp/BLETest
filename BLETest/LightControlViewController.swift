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
	var connectedPeripheral: CBPeripheral? // The connected peripheral received from the last ViewController
    var writeCharacteristic: CBCharacteristic? // The characteristic needed to write to the board
	private var characteristicUUID = CBUUID(string: "FFE1") // The characteristic's address
	private var writeType: CBCharacteristicWriteType = .withoutResponse // The type of writing (can be with a response as well)
	
	@IBOutlet weak var nameLabel: UILabel! // UI instance for the peripheral's name
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Setting the CBPeripheralDelegate to self
		connectedPeripheral?.delegate = self
		
		// Starting to scan the peripheral for the services available and we're not providing any service address
		connectedPeripheral?.discoverServices(nil)
		
		// Setting the label's text with the peripheral's name
		nameLabel.text = connectedPeripheral?.name
    }
	
	@IBAction func lightOnAction(sender: UIButton) {
		// If the peripheral is nil, just return
		guard let peripheral = connectedPeripheral else { return }
		
		// Sending the "1" String as Data (bytes) to the peripheral
		if let data = "1".data(using: String.Encoding.utf8) {
			peripheral.writeValue(data, for: writeCharacteristic!, type: writeType)
		}
	}
	
	@IBAction func lightOffAction(sender: UIButton) {
		// If the peripheral is nil, just return
		guard let peripheral = connectedPeripheral else { return }
		
		// Sending the "0" String as Data (bytes) to the peripheral
		if let data = "0".data(using: String.Encoding.utf8) {
			peripheral.writeValue(data, for: writeCharacteristic!, type: writeType)
		}
	}
}

extension LightControlViewController: CBPeripheralDelegate {
	// Method called when services are being discovered from the peripheral
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		// Code to discover characteristics of all the services discovered
		// Using if lets to make sure that the values are not nil
		if let services = peripheral.services, let peripheral = connectedPeripheral {
			for service in services {
				peripheral.discoverCharacteristics([characteristicUUID], for: service)
			}
		}
	}
	
	// Method called when a characteristic of a service has been discoverred
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		// For every characteristic we are looking for the write address ("FFE1")
		for characteristic in service.characteristics! {
			if characteristic.uuid == characteristicUUID {
				// Subscribe to this value (so we'll get notified when there is serial data for us..)
				peripheral.setNotifyValue(true, for: characteristic)
				// Keep a reference to this characteristic so we can write to it
				writeCharacteristic = characteristic
				// Find out writeType
				writeType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
			}
		}
	}
}
