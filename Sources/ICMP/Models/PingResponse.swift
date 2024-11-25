//
//  PingResponse.swift
//  ICMP
//
//  Created by Михаил Конюхов on 10.11.2024.
//

import Foundation

public struct PingResponse {
    
    public var ip: String
    public var seq: Int
    public var ttl: Int
    public var bytesLength: Int
    public var duration: Double
    
}
