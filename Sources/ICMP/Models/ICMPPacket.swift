//
//  ICMPPacket.swift
//  ICMP
//
//  Created by Михаил Конюхов on 10.11.2024.
//

import Foundation

enum ICMPType: UInt8 {
    /// Эхо-ответ
    case echoReply = 0
    /// Эхо-запрос
    case echo = 8
}

struct ICMPPacket {
    
    // Тип сообщения
    var type: ICMPType
    // Код сообщения
    var code: UInt8
    // Контрольная сумма
    var checksum: UInt16 = 0
    // Идентификатор
    var identifier: UInt16
    // Номер пакета
    var seq: UInt16
    // Данные
    var data: Data
        
    func calculateChecksum() -> UInt16 {
        var sum: UInt32 = 0
        let data = encode()
        
        for i in stride(from: 0, to: data.count, by: 2) {
            let word = UInt16(data[i]) << 8 | (i + 1 < data.count ? UInt16(data[i + 1]) : 0)
            sum += UInt32(word)
        }
        
        // Добавляем старшие биты к младшим
        sum = (sum & 0xFFFF) + (sum >> 16)
        sum += (sum >> 16)  // Повторный перенос, если снова больше 16 бит

        return ~UInt16(sum & 0xFFFF)  // Инвертируем и возвращаем
    }

    func encode() -> Data {
        var packetData = Data()
        packetData.append(type.rawValue)
        packetData.append(code)
        packetData.append(UInt8(checksum >> 8))      // Старший байт контрольной суммы
        packetData.append(UInt8(checksum & 0x00FF))  // Младший байт контрольной суммы
        packetData.append(UInt8(identifier >> 8))
        packetData.append(UInt8(identifier & 0x00FF))
        packetData.append(UInt8(seq >> 8))
        packetData.append(UInt8(seq & 0x00FF))
        packetData.append(data)
        return packetData
    }
    
}
