//
//  peripheralTableViewDelegate.swift
//  tryToUseBlueTooth
//
//  Created by 李松青(SongqingLi)-顺丰科技 on 2019/9/26.
//  Copyright © 2019 李松青(SongqingLi)-顺丰科技. All rights reserved.
//

import CoreBluetooth
import UIKit

protocol PeripheralTableViewDelegate {
    func connectBlueToothDevice(peripheral:CBPeripheral)
    func getPeripherlDevice() -> [CBPeripheral]
}
