//
//  PingResponse.swift
//  ICMP
//
//  Created by Михаил Конюхов on 10.11.2024.
//

import Foundation

public struct PingResponse {
    
    var ip: String
    var seq: Int
    var ttl: Int
    var bytesLength: Int
    var duration: Double
    
}
