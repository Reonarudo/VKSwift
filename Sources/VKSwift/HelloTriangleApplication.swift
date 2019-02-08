import Foundation
import CVulkan
import CGLFW
import HeliumLogger
import LoggerAPI



class HelloTriangleApplication {
    let WIDTH: Int32  = 800
    let HEIGHT: Int32 = 600
    let window: OpaquePointer?

    init(){
        var major:UnsafeMutablePointer<Int32>?
        var minor:UnsafeMutablePointer<Int32>?
        var rev:UnsafeMutablePointer<Int32>?
        glfwGetVersion(major, minor, rev)
        print("\(String(describing: major)), \(String(describing: minor)), \(String(describing: rev))")
        guard glfwInit() == GLFW_TRUE else{
            window = nil
            print("Failed to initialize GLFW")
            return
        }
        glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API)
        window = glfwCreateWindow(800, 600, "Vulkan", nil, nil)
        guard let _ = window else
        {
            print("Failed to create GLFW window")
            return
        }
        print("\(type(of:window))")
        glfwMakeContextCurrent(window)
        
        
    }

    func run() throws{
        try initVulkan()
        mainLoop()
        cleanup()
    }

    fileprivate func initVulkan() throws{
        var instance: VkInstance?
        var createInfo = VkInstanceCreateInfo()
        createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
        let result: VkResult? = vkCreateInstance(&createInfo, nil, &instance)
        guard let res = result else{
            throw GeneralError.message("unknown error")
        }
        if res == VkResult(-9) {
            Log.warning("Cannot find a compatible Vulkan ICD")
        }



        vkDestroyInstance(instance, nil)
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
        glfwDestroyWindow(window);

        glfwTerminate();
    }
};