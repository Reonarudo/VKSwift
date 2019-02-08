import Foundation
import CVulkan
import HeliumLogger
import LoggerAPI
import CGLFW

enum GeneralError: Error {
    case message(String)
}

let logger = HeliumLogger(.verbose)
Log.logger = logger

let app: HelloTriangleApplication = HelloTriangleApplication()

do {
    try app.run()
} catch GeneralError.message(let msg) {
    Log.error(msg)
}
