import Foundation
import CVulkan
import CGLFW

class HelloTriangleApplication {
    let WIDTH: Int32  = 800
    let HEIGHT: Int32 = 600
    var window: OpaquePointer? = nil
    var instance: VkInstance?
    var physicalDevice: VkPhysicalDevice? = nil

    func run() throws{
        initWindow()
        try initVulkan()
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

    fileprivate func initVulkan() throws{
        createInstance()
        // pickPhysicalDevice()
    }

    fileprivate func createInstance() throws{
        var appInfo = VkApplicationInfo(
            sType: VK_STRUCTURE_TYPE_APPLICATION_INFO,
            pNext: nil,
            pApplicationName: "Hello Triangle",
            applicationVersion: 1,
            pEngineName: "No Engine",
            engineVersion: 0,
            apiVersion: UInt32(VK_VERSION_1_0)
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
            enabledExtensionCount: glfwExtensionCount,
            ppEnabledExtensionNames: glfwExtensions
            )

        
        let result: VkResult? = vkCreateInstance(&createInfo, nil, &instance)
        guard result != VK_SUCCESS else{
            throw GeneralError.message("unknown error")
        }
        if result == VK_ERROR_INCOMPATIBLE_DRIVER {
            print("Cannot find a compatible Vulkan ICD")
        }
    }

    // fileprivate func pickPhysicalDevice() throws{
    //     var deviceCount: UInt32 = 0
    //     vkEnumeratePhysicalDevices(instance, &deviceCount, nil)

    //     if (deviceCount == 0) {
    //         throw GeneralError.message("failed to find GPUs with Vulkan support!")
    //     }

    //     var devices:[VkPhysicalDevice]=[]
    //     vkEnumeratePhysicalDevices(instance, &deviceCount, devices.enumerated())

    //     devices.forEach{
    //         if (isDeviceSuitable($0)) {
    //             physicalDevice = $0
    //             break
    //         }
    //     }

    //     if (physicalDevice == VK_NULL_HANDLE) {
    //         throw std::runtime_error("failed to find a suitable GPU!")
    //     }
    // }


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