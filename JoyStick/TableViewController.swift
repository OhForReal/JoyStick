//
//  TableViewController.swift

import UIKit

class TableViewController: UITableViewController {
    
    // on access, setup this variable
    lazy var bleShield:BLE = (UIApplication.shared.delegate as! AppDelegate).bleShield
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(scanForDevices), for: .valueChanged)
        self.refreshControl = refresh
    }
    
    
    // MARK: ======= Table view data source ======
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bleShield.peripherals.count
    }
    
    @objc func scanForDevices() {
        
        // disconnect from any peripherals
        for peripheral in bleShield.peripherals {
            if(peripheral.state == .connected){
                bleShield.disconnectFromPeripheral(peripheral: peripheral)
            }
        }
        
        //start search for peripherals with a timeout of 3 seconds
        // this is an asynchronous call and will return before search is complete
        if(bleShield.startScanning(timeout: 3.0)){
            // after three seconds, try to connect to first peripheral
            Timer.scheduledTimer(withTimeInterval: 3.0,
                                 repeats: false,
                                 block: self.didFinishScanning)
        }
        
    }
    
    func didFinishScanning(timer:Timer){
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "simpleCell", for: indexPath)
        let peripheral = self.bleShield.peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name!
        cell.detailTextLabel?.text = peripheral.identifier.uuidString
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = self.bleShield.peripherals[indexPath.row]
        self.bleShield.connectToPeripheral(peripheral: peripheral)
    }
    
}

