//
//  BlueToothDiveListTableViewController.swift
//  tryToUseBlueTooth
//
//  Created by 李松青(SongqingLi)-顺丰科技 on 2019/9/26.
//  Copyright © 2019 李松青(SongqingLi)-顺丰科技. All rights reserved.
//

import UIKit
import CoreBluetooth

class BlueToothDiveListTableView: UITableView, UITableViewDelegate, UITableViewDataSource{
    
    var myDelegate: PeripheralTableViewDelegate?
    var peripheralLists = [CBPeripheral]()
    var timer: Timer!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect, style: UITableView.Style){
        super.init(frame:frame, style:style)
        self.backgroundColor = UIColor.gray
        self.delegate = self
        self.dataSource = self
        self.register(UITableViewCell.self, forCellReuseIdentifier: "peripheralCell")
        let name = NSNotification.Name(rawValue: "beginReload")
        NotificationCenter.default.addObserver(self, selector: #selector(buttonDownToReload), name: name, object: nil)
        print("init OK")
    }
    
    override func reloadData(){
        super.reloadData()
    }
    
    @objc func buttonDownToReload(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerStartLoad), userInfo: nil, repeats: true)
    }
    
    @objc func timerStartLoad(){
        peripheralLists=myDelegate!.getPeripherlDevice()
        print("reload")
        self.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identify:String = "peripheralCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath)
        cell.textLabel?.text=self.peripheralLists[indexPath.row].name ?? self.peripheralLists[indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myDelegate?.connectBlueToothDevice(peripheral: peripheralLists[indexPath.row])
        print("点击后开始匹配，停止刷新tableView")
        timer.invalidate()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
