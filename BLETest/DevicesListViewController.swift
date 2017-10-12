//
//  ViewController.swift
//  BLETest
//
//  Created by Alexandru Clapa on 11/10/2017.
//  Copyright © 2017 Alexandru Clapa. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesListViewController: UIViewController {
	var centralManager: CBCentralManager!
	var selectedPeripheral: CBPeripheral?
	var peripherals = Set<CBPeripheral>()
	
	@IBOutlet weak var tableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Initialising the central manager and setting the delegate to self so we're subscribed to events
		centralManager = CBCentralManager.init()
		centralManager.delegate = self
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Method called right before executing a segue (switching screens)
		// Using this to pass data to the LightControlViewController
		if segue.identifier == "showLightControlSegue" {
			let destination = segue.destination as! LightControlViewController
			destination.connectedPeripheral = selectedPeripheral
		}
	}
}

extension DevicesListViewController: CBCentralManagerDelegate {
	// Method called every time the manager updates its state
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		// Starting to scan for peripherals here, where the manager is ready to do that
		centralManager.scanForPeripherals(withServices: nil, options: nil)
	}
	
	// Method called after a peripheral has been discovered
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		// Only storing a peripheral if it has a name
		// Putting it into a set so we don't have repeating objects
		// Reloading the table view after so it will have the latest data in
		if peripheral.name != nil {
			peripherals.insert(peripheral)
			tableView.reloadData()
		}
	}
	
	// Method called right after we have connected to a peripheral
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		// Stopping the scanner after we have connected to a peripheral
		centralManager.stopScan()
		// Storing the connected peripheral
		selectedPeripheral = peripheral
		// Switching to the next screen (because this will be called after a tap on the table view)
		performSegue(withIdentifier: "showLightControlSegue", sender: self)
	}
}

extension DevicesListViewController: UITableViewDataSource {
	// Method called every time a cell is being drawn on the screen
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Creating a cell from our custom class
		let cell = tableView.dequeueReusableCell(withIdentifier: "discoveredDeviceCell", for: indexPath) as! DiscoveredDeviceTableViewCell
		// Getting the name that matches the index of the row
		// A set is a collection of unsorted elements so we are sorting it first (a bit unefficient)
		let name = peripherals.sorted { (o1, o2) -> Bool in
			return o1.name! < o2.name!
		}[indexPath.row].name!
		// Setting the cell's label to the name
		cell.nameLabel.text = name
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		// We only need 1 section in this example
		return 1
	}
	
	// Method to provide the number of rows in the table view
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// Returning how many elements our set has
		return peripherals.count
	}
}

extension DevicesListViewController: UITableViewDelegate {
	// Method called after the user taps a cell
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// Deselecting the selected row
		tableView.deselectRow(at: indexPath, animated: true)
		// Sorting again as before
		let peripheral = peripherals.sorted { (o1, o2) -> Bool in
			return o1.name! < o2.name!
			}[indexPath.row]
		// Connecting to the matching peripheral (didConnect will be called when it is done)
		centralManager.connect(peripheral, options: nil)
	}
}
