ICMP
============

[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)

Простая, библиотека ICMP echo (ping) на Swift.

# Usage

```swift
import ICMP

var icmp = ICMP(host: "google.com")
icmp.delegate = self // ICMPDelegate

// Бесконечный ping
icmp.ping()

// 10 запросов с интервалом 2 сек.
icmp.ping(requestCount: 10, interval: 2.0)
```

![Запись экрана 2024-11-26 в 00 01 11](https://github.com/user-attachments/assets/144f7cb9-7af2-4de9-822a-d2e2b65e3d5c)

### Delegate Protocol

```swift
extension ViewController: ICMPDelegate {
    
    func didReceive(_ response: PingResponse?, _ error: ICMPErrors?) {
      // Обработка пакета
    }
    
}
```

Модель ответа:
```swift
struct PingResponse {
    
    var ip: String
    var seq: Int
    var ttl: Int
    var bytesLength: Int
    var duration: Double

}
```

# Installation

### Swift Package Manager
To add ICMP-Swift to a [Swift Package Manager](https://swift.org/package-manager/) based project, add:

```swift
.package(url: "https://github.com/mvc045/ICMP-Swift", branch: "main"),
```
to your `Package.swift` files `dependencies` array.

