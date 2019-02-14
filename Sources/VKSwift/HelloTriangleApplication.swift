import Foundation
import CVulkan
import CGLFW

#if DEBUG
    let enableValidationLayers = true;
#else
    let enableValidationLayers = false;
#endif

extension UInt32 {
    var version: String{
        get{
            return "\(self >> 22).\((self >> 12) & 0x3FF).\(self & 0xFFF)"
        }
    }
    static func fromVersion(
        major majNum:Int,
        minor minNum:Int,
        patch patNum:Int) -> UInt32{
            return UInt32((majNum&0x3FF<<22)|(minNum&0x3FF<<12)|(patNum&0x3FF))
    }
}

let VK_LAYER_LUNARG_standard_validation:UnsafePointer<Int8> = UnsafePointer<Int8>("VK_LAYER_LUNARG_standard_validation")

class HelloTriangleApplication {
    let WIDTH: Int32  = 800
    let HEIGHT: Int32 = 600
    var window: OpaquePointer? = nil
    var instance: VkInstance?
    var physicalDevice: VkPhysicalDevice?
    let validationLayers:UnsafePointer<UnsafePointer<Int8>?>? = UnsafePointer([VK_LAYER_LUNARG_standard_validation])
    
    init() {
        initWindow()
        initVulkan()
    }
    

    func run() throws{
        mainLoop()
        cleanup()
    }

    fileprivate func initWindow(){
        guard glfwInit() == GLFW_TRUE else{
            window = nil
            print("Failed to initialize GLFW")
            return
        }

        glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API)
        glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE)

        window = glfwCreateWindow(WIDTH, HEIGHT, "Vulkan", nil, nil)
        guard let _ = window else
        {
            print("Failed to create GLFW window")
            return
        }
        print("\(type(of:window))")
        glfwMakeContextCurrent(window)
    }

    fileprivate func initVulkan() {
        do {
            try createInstance()
            try pickPhysicalDevice()
            try createLogicalDevice()
        } catch GeneralError.message(let msg) {
            print(msg)
        } catch let _ {
            //?
        }
        
    }

    fileprivate func createLogicalDevice() throws{
        guard let foundPhysicalDevice = physicalDevice else{
            throw GeneralError.message("""

                Error: Failed to find a suitable GPU!
                """)
        }
        let indices = findQueueFamilies(foundPhysicalDevice)
        var priority: Float = 1.0
        var queueCreateInfo = VkDeviceQueueCreateInfo(
            sType: VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO, 
            pNext: nil,
            flags: 0,
            queueFamilyIndex: indices.graphicsFamily!, 
            queueCount: 1,
            pQueuePriorities: &priority)

        var deviceFeatures = VkPhysicalDeviceFeatures()

        var enabledLayerCount:UInt32 = 0
        //var enabledLayerNames
        if (enableValidationLayers) {
            enabledLayerCount = UInt32(1)
            //enabledLayerNames = layers
        }

        var createInfo = VkDeviceCreateInfo(
            sType: VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
            pNext: nil,
            flags: 7,
            queueCreateInfoCount: 1,
            pQueueCreateInfos: &queueCreateInfo,
            enabledLayerCount: enabledLayerCount,
            ppEnabledLayerNames: validationLayers,
            enabledExtensionCount: 0,
            ppEnabledExtensionNames:nil,
            pEnabledFeatures: &deviceFeatures
        )
    }

    fileprivate func createInstance() throws{
        var appInfo = VkApplicationInfo(
            sType: VK_STRUCTURE_TYPE_APPLICATION_INFO,
            pNext: nil,
            pApplicationName: "Hello Triangle",
            applicationVersion: 1,
            pEngineName: nil,
            engineVersion: 0,
            apiVersion: 0
        )
        print("\(type(of:appInfo))")

        var glfwExtensionCount:UInt32 = 0
        let glfwExtensions = glfwGetRequiredInstanceExtensions(&glfwExtensionCount)

        var createInfo = VkInstanceCreateInfo(
            sType: VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO, 
            pNext: nil, 
            flags: 0,
            pApplicationInfo: &appInfo, 
            enabledLayerCount: 0,
            ppEnabledLayerNames: nil,
            enabledExtensionCount: 0,
            ppEnabledExtensionNames: glfwExtensions
            )

        
        let out = vkCreateInstance(&createInfo, nil, &instance)
        guard out == VK_SUCCESS else{
            throw GeneralError.message("""

                Error: Failed to create instance!
                Code:\(String(describing: out.rawValue))
                """)
        }
        
        print("\(String(describing: instance!))")
        //print("\(result)")

        /*if result == VK_ERROR_INCOMPATIBLE_DRIVER {
            print("Cannot find a compatible Vulkan ICD")
        }*/
    }

    fileprivate func deviceType(_ number:VkPhysicalDeviceType)->String{
        
        switch number {
            case VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU: return "INTEGRATED GPU"
            case VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU: return "DISCRETE GPU"
            case VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU: return "VIRTUAL GPU"
            case VK_PHYSICAL_DEVICE_TYPE_CPU: return "CPU"
            default: 
                return "OTHER"
            
        }
        
    }

    fileprivate func pickPhysicalDevice() throws{
        var deviceCount: UInt32 = 0
        vkEnumeratePhysicalDevices(instance, &deviceCount, nil)

        if (deviceCount == 0) {
            throw GeneralError.message("failed to find GPUs with Vulkan support!")
        }

        let devices: UnsafeMutablePointer<VkPhysicalDevice?>? = UnsafeMutablePointer<VkPhysicalDevice?>.allocate(capacity:Int(deviceCount))
        vkEnumeratePhysicalDevices(instance, &deviceCount, devices)

        let bufferPointer = UnsafeBufferPointer(start: devices, count: Int(deviceCount))
        var tmpPhysicalDevice: VkPhysicalDevice? = nil
        for (index, value) in bufferPointer.enumerated() {
            //print("value \(index): \(String(describing:value))")
            let propsPointer: UnsafeMutablePointer<VkPhysicalDeviceProperties>? = UnsafeMutablePointer<VkPhysicalDeviceProperties>.allocate(capacity: 1)
            //var props: VkPhysicalDeviceProperties
            vkGetPhysicalDeviceProperties(value, propsPointer)
            var props: VkPhysicalDeviceProperties = (propsPointer!).pointee
            print("""
                API version:    \(UInt32(props.apiVersion).version)
                Driver version: \(UInt32(props.driverVersion).version)
                Vendor ID:      \(String(format:"%02X", props.vendorID))
                Device ID:      \(String(format:"%02X", props.deviceID))
                Device type:    \(deviceType(props.deviceType))
                Device name:    \(
                    withUnsafeBytes(of: &props.deviceName) { (rawPtr) -> String in
                        let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
                        return String(cString: ptr)
                }))
            """)
            if let v = value, isDeviceSuitable(v) {
                tmpPhysicalDevice = v
                break
            }
        }

        guard let foundPhysicalDevice = tmpPhysicalDevice else{
            throw GeneralError.message("""

                Error: Failed to find a suitable GPU!
                """)
        }

        self.physicalDevice = foundPhysicalDevice
    }

    func isDeviceSuitable(_ device: VkPhysicalDevice) -> Bool {
        let indices = findQueueFamilies(device);

        return indices.isComplete();
    }

    func findQueueFamilies(_ device: VkPhysicalDevice) -> QueueFamilyIndices {
        var indices: QueueFamilyIndices = QueueFamilyIndices()

        var queueFamilyCount: UInt32 = 0
        vkGetPhysicalDeviceQueueFamilyProperties(device, &queueFamilyCount, nil)

        let queueFamilies: UnsafeMutablePointer<VkQueueFamilyProperties>? = UnsafeMutablePointer<VkQueueFamilyProperties>.allocate(capacity: Int(queueFamilyCount))
        vkGetPhysicalDeviceQueueFamilyProperties(device, &queueFamilyCount, queueFamilies);

        let bufferPointer = UnsafeBufferPointer(start: queueFamilies, count: Int(queueFamilyCount))
        for (index, value) in bufferPointer.enumerated() {
            
            let queueFamily = value
            if  type(of: queueFamily) == VkQueueFamilyProperties.self{
                if queueFamily.queueCount > 0, 
                (queueFamily.queueFlags & VK_QUEUE_GRAPHICS_BIT.rawValue) != 0{ //VK_QUEUE_GRAPHICS_BIT = 0x00000001
                    indices.graphicsFamily = UInt32(index)
                    print("Found suitable device")
                }
                if indices.isComplete() {
                    break
                }
            }
        }

        return indices;
    }

    struct QueueFamilyIndices{
        var graphicsFamily: UInt32?

        func isComplete() -> Bool{
            return graphicsFamily != nil
        }
    }


    fileprivate func mainLoop() {
        while (0 == glfwWindowShouldClose(window)){
            /* Render here */
            //glClear(GL_COLOR_BUFFER_BIT)

            /* Swap front and back buffers */
            glfwSwapBuffers(window)

            /* Poll for and process events */
            glfwPollEvents()
        }
    }

    fileprivate func cleanup() {
        vkDestroyInstance(instance, nil)
        glfwDestroyWindow(window);
        glfwTerminate();
    }
};