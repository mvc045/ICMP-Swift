//
//  ViewController.swift
//  ExampleApp
//
//  Created by Михаил Конюхов on 25.11.2024.
//

import UIKit
import ICMP

class ViewController: UIViewController {
    
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    var icmp: ICMP!
    var dataSource: [PingResponse] = []
    
    override func loadView() {
        super.loadView()
        view.addSubview(tableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        icmp = ICMP(host: "google.com")
        icmp.delegate = self
        icmp.ping(requestCount: 10, interval: 2.0)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let response = dataSource[indexPath.row]
        let ms = String(format: "%.3f", response.duration)
        let line = "\(response.bytesLength) bytes from \(response.ip): icmp_seq=\(response.seq) ttl=\(response.ttl) time=\(ms) ms"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = line
        return cell
    }
    
}

extension ViewController: ICMPDelegate {
    
    func didReceive(_ response: PingResponse?, _ error: ICMPErrors?) {
        guard let response else { print("\(error!.localizedDescription)"); return }
        dataSource.append(response)
        tableView.reloadData()
    }
    
}
