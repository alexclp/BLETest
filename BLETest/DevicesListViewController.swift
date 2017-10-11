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
		// Do any additional setup after loading the view, typically from a nib.
		
		centralManager = CBCentralManager.init()
		centralManager.delegate = self
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showLightControlSegue" {
			let destination = segue.destination as! LightControlViewController
			destination.connectedPeripheral = selectedPeripheral
		}
	}
}

extension DevicesListViewController: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		centralManager.scanForPeripherals(withServices: nil, options: nil)
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		if peripheral.name != nil {
			peripherals.insert(peripheral)
			tableView.reloadData()
		}
	}
	
	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		centralManager.stopScan()
		selectedPeripheral = peripheral
		performSegue(withIdentifier: "showLightControlSegue", sender: self)
	}
}

extension DevicesListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "discoveredDeviceCell", for: indexPath) as! DiscoveredDeviceTableViewCell
		let name = peripherals.sorted { (o1, o2) -> Bool in
			return o1.name! < o2.name!
		}[indexPath.row].name!
		cell.nameLabel.text = name
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return peripherals.count
	}
}

extension DevicesListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let peripheral = peripherals.sorted { (o1, o2) -> Bool in
			return o1.name! < o2.name!
			}[indexPath.row]
		centralManager.connect(peripheral, options: nil)
	}
}
