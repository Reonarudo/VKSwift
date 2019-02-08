import Foundation
import CVulkan
import CGLFW

enum GeneralError: Error {
    case message(String)
}

let app: HelloTriangleApplication = HelloTriangleApplication()

do {
    try app.run()
} catch GeneralError.message(let msg) {
    print(msg)
}
