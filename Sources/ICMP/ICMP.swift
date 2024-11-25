//
//  ICMP.swift
//  ICMP
//
//  Created by Михаил Конюхов on 10.11.2024.
//

import Foundation

protocol ICMPDelegate: AnyObject {
    func didReceive(_ response: PingResponse?, _ error: ICMPErrors?)
}

final class ICMP {
    
    let host: String
    let identifier: UInt16
    let message: String
    
    weak var delegate: ICMPDelegate?
    
    init(host: String, message: String = "Ping") {
        self.host = host
        self.identifier = UInt16.random(in: 0...10_000)
        self.message = message
    }
    
    func ping() {
        var seq: UInt16 = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            do {
                guard let (socketFD, infoPointer) = try self.setupSocket(to: self.host) else { return }
                let packet = self.buildPacket(identifier: self.identifier, seq: seq, message: self.message)
                try self.sendPacket(socketFD: socketFD, info: infoPointer, packetData: packet)
                self.cancleSocket(socketFD, infoPointer)
                seq += 1
            } catch(let error) {
                self.delegate?.didReceive(nil, (error as! ICMPErrors))
            }
        }
        timer.fire()
    }
    
    /// requestCount - кол-во echo запросов
    /// interval - интервал с каким будут отправляться echo запросы. Default = 1 сек.
    func ping(requestCount: Int, interval: TimeInterval = 1.0) {
        var seq: UInt16 = 0
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            do {
                guard let (socketFD, infoPointer) = try self.setupSocket(to: self.host) else { return }
                let packet = self.buildPacket(identifier: self.identifier, seq: seq, message: self.message)
                try self.sendPacket(socketFD: socketFD, info: infoPointer, packetData: packet)
                self.cancleSocket(socketFD, infoPointer)
                seq += 1
                if requestCount == Int(seq) {
                    timer.invalidate()
                }
            } catch(let error) {
                self.delegate?.didReceive(nil, (error as! ICMPErrors))
            }
        }
        timer.fire()
    }
    
    // Формируем пакет
    func buildPacket(identifier: UInt16, seq: UInt16, message: String) -> Data {
        let messageData = message.data(using: .utf8)!
        var packet = ICMPPacket(type: .echo, code: 0, identifier: identifier, seq: seq, data: messageData)
        packet.checksum = packet.calculateChecksum()
        let packetData = packet.encode()
        return packetData
    }
    
}

// MARK: Ping
private extension ICMP {
    
    // Создаем соединение
    func setupSocket(to host: String) throws -> (Int32, UnsafeMutablePointer<addrinfo>)? {
        let socketFD = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP)
        guard socketFD >= 0 else {
            throw ICMPErrors.SocketInitializationError
        }
        
        // Разрешаем адрес хоста
        var hints = addrinfo(ai_flags: 0,
                             ai_family: AF_INET, // IPv4
                             ai_socktype: SOCK_RAW,
                             ai_protocol: 0, //ICMP
                             ai_addrlen: 0,
                             ai_canonname: nil,
                             ai_addr: nil,
                             ai_next: nil)
        var infoPointer: UnsafeMutablePointer<addrinfo>?
        let result = getaddrinfo(host, nil, &hints, &infoPointer)
        
        guard result == 0, let info = infoPointer else {
            let code = String(cString: gai_strerror(result))
            throw ICMPErrors.UnableToResolveHost("Не удалось разрешить адрес для \(host) | Ошибка: \(code)")
        }
            
        return (socketFD, info)
    }
    
    func cancleSocket(_ socketFD: Int32, _ infoPointer: UnsafeMutablePointer<addrinfo>) {
        close(socketFD)
        freeaddrinfo(infoPointer)
    }
        
    // Отправляем пакет, получаем ответ
    func sendPacket(socketFD: Int32, info: UnsafeMutablePointer<addrinfo>, packetData: Data) throws {
        var startTime: Date?
        var endTime: Date?
        
        // Отправляем
        try packetData.withUnsafeBytes { buffer in
            let bytesSent = sendto(socketFD,
                                   buffer.baseAddress,
                                   buffer.count,
                                   0,
                                   info.pointee.ai_addr,
                                   info.pointee.ai_addrlen)
            
            if bytesSent > 0 {
                startTime = Date()
            } else {
                throw ICMPErrors.MessageSendError
            }
        }
                
        // Получаем
        var responseBuffer = [UInt8](repeating: 0, count: 1024)
        let bytesRead = recv(socketFD, &responseBuffer, responseBuffer.count, 0)
        
        if bytesRead > 0 {
            endTime = Date()
            guard let startTime, let endTime else { return }
            parseResponse(responseBuffer, bytesRead, (startTime, endTime))
        } else {
            throw ICMPErrors.ServerResponseError
        }
    }
    
    func parseResponse(_ response: [UInt8], _ bytesRead: Int, _ interval: (start: Date, end: Date)) {
        guard let header = IPHeader(data: response) else { return }
        let senderAddress = header.convertIPToString(ipAddress: header.senderAddress)
        let seq = UInt16(response[26]) << 8 | UInt16(response[27])
        let ttl = response[8]
        let ms = interval.end.timeIntervalSince(interval.start) * 1000
        let response = PingResponse(ip: senderAddress, seq: Int(seq), ttl: Int(ttl), bytesLength: bytesRead, duration: ms)
        delegate?.didReceive(response, nil)
    }
        
}
