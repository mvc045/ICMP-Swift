//
//  ICMPErrors.swift
//  ICMP
//
//  Created by Михаил Конюхов on 25.11.2024.
//

import Foundation

public enum ICMPErrors: Error {
    /// Не удалось создать сокет
    case SocketInitializationError
    /// Не удалось разрешить адрес для host-а
    case UnableToResolveHost(String)
    /// Ошибка отправки сообщения
    case MessageSendError
    /// Ошибка получения ответа от сервера
    case ServerResponseError
}

extension ICMPErrors: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .SocketInitializationError:
            return "Не удалось создать сокет"
        case .UnableToResolveHost(let string):
            return string
        case .MessageSendError:
            return "Ошибка отправки сообщения"
        case .ServerResponseError:
            return "Ошибка получения ответа от сервера"
        }
    }
    
}
