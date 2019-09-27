//
//  ViewController.swift
//  tryToUseBlueTooth
//
//  Created by 李松青(SongqingLi)-顺丰科技 on 2019/9/26.
//  Copyright © 2019 李松青(SongqingLi)-顺丰科技. All rights reserved.
//

//目前是要给搜索蓝牙设备一个搜索的时间限制，然后到时间，停止搜索，同时停止tableView的刷新

import UIKit
import CoreBluetooth

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate,PeripheralTableViewDelegate{
    
    var centralManager: CBCentralManager?
    var peripheralData = [CBPeripheral]()
    var connectedPeripheral: CBPeripheral?
    
    var freshLimitTimer: Timer!//按下搜索时开始计时，给予20S搜索时间，超过就不搜索了
    var TIME_LIMIT_SECOND = 20 //这里全局数值的设计是一个优化的点
    
    var activityCirleLogo: UIActivityIndicatorView!
    var searchButton :UIButton!
    var topContentView: UIView!
    var SCREEN_WIDTH: CGFloat!
    var SCREEN_HEIGHT:CGFloat!
    var STATE_OF_BLUE_TOOTH = 5//0.on ; 1.unKnown ; 2.reSetting ; 3.unSupported ; 4.unAuthorized ; 5. off
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SCREEN_WIDTH = self.view.bounds.width
        SCREEN_HEIGHT = self.view.bounds.height
        
        //设置约束条件,就是这个搞出的bug,是布局问题
        //let MarginTop=NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 20)
        
        self.view.backgroundColor=UIColor.gray
        
        topContentView=UIView(frame: CGRect(x:0,y:0,width: SCREEN_WIDTH,height: 220))
        topContentView.backgroundColor=UIColor.white
        
        activityCirleLogo=UIActivityIndicatorView(style: .medium)
        activityCirleLogo.frame.origin.y = 5
        activityCirleLogo.center=topContentView.center
        activityCirleLogo.alpha=0.0

        topContentView.addSubview(activityCirleLogo)
        
        
        
        searchButton=UIButton()
        searchButton.bounds.size=CGSize(width: 120, height: 55)
        searchButton.frame.origin.y = 5
        searchButton.setTitle("搜索", for: .normal)
        searchButton.setTitleColor(.black, for: .normal)
        searchButton.center=topContentView.center
        searchButton.alpha=1.0
        searchButton.addTarget(self, action: #selector(startSearch), for: .touchUpInside)
        topContentView.addSubview(searchButton)
        
        
        let centralQueue:DispatchQueue = DispatchQueue(label: "blueTooth.centralQueueName",attributes: .concurrent)
        centralManager=CBCentralManager(delegate: self, queue: centralQueue)
        
        //设置代理与TableVC
        let tableRect=CGRect(x: 0, y: 225, width: SCREEN_WIDTH, height: SCREEN_HEIGHT-225)
        let TableVC=BlueToothDiveListTableView(frame: tableRect, style: .plain)
        TableVC.myDelegate=self
        
        self.view.addSubview(topContentView)
        self.view.addSubview(TableVC)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .poweredOn:
            STATE_OF_BLUE_TOOTH = 0
        case .unknown:
            STATE_OF_BLUE_TOOTH = 1
        case .resetting:
            STATE_OF_BLUE_TOOTH = 2
        case .unsupported:
            STATE_OF_BLUE_TOOTH = 3
        case .unauthorized:
            STATE_OF_BLUE_TOOTH = 4
        case .poweredOff:
            STATE_OF_BLUE_TOOTH = 5
        @unknown default:
            fatalError("真真正正的母鸡啦")
            break
        }
    }
    
    
    //扫描到某些设备下调用该函数
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //print("description: \(peripheral.identifier.description)"+" uuidString: \(peripheral.identifier.uuidString)"+" RSSI: \(RSSI)")
        //目前的情况是有的设备只有description,没有name,那么就是有名字的存名字，莫得名字的再用description,传过去
        //上面的傻了，存peripheral就行了，到时候有name显示name,没name显示它的description不就行了吗，这里只要判断重复即可
        //扫描到重复设备的情况下去重,将结果保存至数组中，然后创建tableView显示
        if !peripheralData.contains(peripheral){
            print("去重一些设备")
            peripheralData.append(peripheral)
        }
        
    }
    
    //假如选定了某个设备，点击cell后的操作，代理函数,table那边同时终止reload
    func connectBlueToothDevice(peripheral: CBPeripheral) {
        centralManager?.connect(peripheral, options: nil)
        centralManager?.stopScan()
        DispatchQueue.main.async {
            () -> Void in
            self.activityCirleLogo.stopAnimating()
            self.activityCirleLogo.alpha=0.0
            self.searchButton.alpha=1.0
        }
    }
    
    //代理函数，给tableView做数据桥接
    func getPeripherlDevice() -> [CBPeripheral] {
        print("getPeripherlDevice")
        return peripheralData
        //这里只是返回目前扫描到的设备数据，那边需要每秒都reload一次，直到点击了cell，列表终止reload
    }
    
    //连接到外围设备时调用的代理方法
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //连接成功后
        print("你已连接成功/nHHHH")
        self.connectedPeripheral=peripheral
        if ((self.connectedPeripheral) != nil){
            self.connectedPeripheral!.delegate=self
            self.connectedPeripheral!.discoverServices(nil)
        } else{
            self.alert("big Error1")
            return
        }
    }
    
    //连接外设失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.alert("连接外设:\(String(describing: peripheral.name))失败")
        centralManager?.stopScan()
    }
    
    //扫描到服务后，扫描特性
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        
        if error != nil{
            self.alert("发现该设备错误的服务")
            print("错误的服务:\(error!.localizedDescription)")
            return
        }
        var servicesList=[String]()
        var num=1
        
        //扫描这个设备的第一个服务的所有特征
        for service:CBService in peripheral.services!{
            servicesList.append(service.uuid.uuidString)
            /*
             if service.uuid.uuidString=="666666"{
             //扫描这个66666服务的所有特性
             peripheral.discoverCharacteristics(nil, for: service)
             }
             */
            if(num==1){
                num-=1
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        print(servicesList)
    }
    
    //搜索到某一服务的特征后
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if(error != nil){
            self.alert("发现该设备\(service.uuid.uuidString)服务的错误特征")
            print("错误的特征:\(error!.localizedDescription)")
        }
        for characteristic in service.characteristics!{
            //罗列所有特征，查看哪些是notify方式的，那些事read方式的，那些是可写入的。
            print("服务UUID:\(service.uuid) ---- 特征UUID:\(characteristic.uuid)")
            switch characteristic.uuid.description {
            case "FFE1":
                self.connectedPeripheral!.setNotifyValue(true, for: characteristic)
            default:
                break
            }
        }
    }
    //获取外设发来的数据，read或notify，获取数据都从此方法中获取
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(error != nil){
            print("发送数据错误的特性是：\(characteristic.uuid)     错误信息：\(error!.localizedDescription)       错误数据：\(String(describing: characteristic.value))")
            return
        }
        // switch characteristic.uuid.description{}
    }
    
    
    @objc func startSearch(){
        switch STATE_OF_BLUE_TOOTH {
        case 1:
            print("您的蓝牙功能出现了未知问题，救不了，告辞")
            self.alert("蓝牙功能出现了未知问题")
        case 2:
            print("您的蓝牙正在重启")
            self.alert("您的蓝牙正在重启")
        case 3:
            print("您的设备不支持蓝牙")
            self.alert("您的设备不支持蓝牙")
        case 4:
            print("未赋予使用蓝牙的权限")
            self.alert("未赋予使用蓝牙的权限")
        case 5:
            print("您的蓝牙功能已关闭")
            self.alert("您的蓝牙功能已关闭")
        case 0:
            print("蓝牙能用")
            DispatchQueue.main.async {
                () -> Void in
                self.searchButton.alpha=0.0
                self.activityCirleLogo.alpha=1.0
                self.activityCirleLogo.startAnimating()
                //发广播，tableView开始刷新
                let name = NSNotification.Name(rawValue: "beginReload")
                //开始计时
                NotificationCenter.default.post(name: name,object: nil)
                print("发出通知")
            }
            //扫描所有的设备
            print("开始扫描")
            centralManager?.scanForPeripherals(withServices: nil,options: nil)
            
        default:
            self.alert("你碰上了苹果都没遇到的问题，手机可以扔了")
            break
        }
    }
    func startTimeCount(){
        freshLimitTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeCount), userInfo: nil, repeats: true)
        freshLimitTimer.fire()
    }
    @objc func timeCount(){
        if(TIME_LIMIT_SECOND>0){
            TIME_LIMIT_SECOND-=1
        }else{
            freshLimitTimer.invalidate()
            let name = NSNotification.Name(rawValue: "timeLimit")
            NotificationCenter.default.post(name: name, object: nil) // 这里objec的对象也是一个优化的点
            TIME_LIMIT_SECOND=20
        }
    }
    
}

