//
//  IPHeader.swift
//  ICMP
//
//  Created by Михаил Конюхов on 10.11.2024.
//

import Foundation

struct IPHeader {
    
    var version: UInt8
    var type: UInt8
    var length: UInt16
    var identifier: UInt16
    var flags: UInt16
    var ttl: UInt8
    var `protocol`: UInt8
    var checksum: UInt16
    // IP-адрес отправителя
    var senderAddress: UInt32
    // IP-адрес получателя
    var recipientAddress: UInt32
    
    init?(data: [UInt8]) {
        guard data.count >= 20 else { // Минимальная длина IP заголовка 20 байт
            print("Недостаточно данных для формирования IP заголовка")
            return nil
        }
        
        version = data[0]
        type = data[1]
        length = UInt16(data[2]) << 8 | UInt16(data[3])
        identifier = UInt16(data[4]) << 8 | UInt16(data[5])
        flags = UInt16(data[6]) << 8 | UInt16(data[7])
        ttl = data[8]
        `protocol` = data[9]
        checksum = UInt16(data[10]) << 8 | UInt16(data[11])
        senderAddress = UInt32(data[12]) << 24 | UInt32(data[13]) << 16 | UInt32(data[14]) << 8 | UInt32(data[15])
        recipientAddress = UInt32(data[16]) << 24 | UInt32(data[17]) << 16 | UInt32(data[18]) << 8 | UInt32(data[19])
    }
    
    func convertIPToString(ipAddress: UInt32) -> String {
        // Извлекаем каждый байт из 32-битного адреса
        let byte1 = (ipAddress >> 24) & 0xFF
        let byte2 = (ipAddress >> 16) & 0xFF
        let byte3 = (ipAddress >> 8) & 0xFF
        let byte4 = ipAddress & 0xFF
        
        // Создаем строку в формате "X.X.X.X"
        return "\(byte1).\(byte2).\(byte3).\(byte4)"
    }
    
}
