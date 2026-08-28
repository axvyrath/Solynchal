package main

import "core:c"
import "core:fmt"
import "core:dynlib"
import vk "vendor:vulkan"
import "vendor:glfw"

APPLICATION_NAME 					: cstring				: "Solynchal"
REQUIRED_EXTENSIONS					: []cstring				: {}
REQUIRED_LAYERS						: []cstring				: {}
DEFAULT_WINDOW_WIDTH 				: c.int					: 800
DEFAULT_WINDOW_HEIGHT 				: c.int					: 600

Context :: struct {
	library					: dynlib.Library,
	instance				: vk.Instance,
	window					: glfw.WindowHandle,
	physical_device			: vk.PhysicalDevice,
	logical_device			: vk.Device,
	surface					: vk.SurfaceKHR,
}

vfs_create_info := VFSInstanceCreateInfo{
	app_name = APPLICATION_NAME,
	app_version = vk.MAKE_VERSION(1, 0, 0),
	engine_name = "Optato",
	engine_version = vk.MAKE_VERSION(1, 0, 0),
	api_version = vk.API_VERSION_1_4,
	window_width = DEFAULT_WINDOW_WIDTH,
	window_height = DEFAULT_WINDOW_HEIGHT,
	window_title = APPLICATION_NAME,
	enable_extensions = REQUIRED_EXTENSIONS,
	enable_layers = REQUIRED_LAYERS,
	enable_validation_layers = true,
}

vfs_desire_features := VFSDesireFeatures{
	vulkan_11_features = {.shaderDrawParameters},
	vulkan_13_features = {.dynamicRendering, .synchronization2},
	ext_dynamic_state_features = {.extendedDynamicState}
}

main :: proc() {
	instance := create_instance(vfs_create_info)
	defer destroy_instance(instance)

	select_physical_device_info := VFSSelectPhysicalDeviceInfo{
		surface = instance.surface,
		prefer_device_type = .DISCRETE_GPU,
		require_present_support = true,
		minimum_vulkan_version = vk.API_VERSION_1_4,
		desire_features = vfs_desire_features,
	}

	device := select_physical_device(instance, select_physical_device_info)

	device_create_info := VFSLogicalDeviceCreateInfo{
		desire_features = vfs_desire_features,
		desire_queue_flag = .GRAPHICS,
		queue_priority = 0.5,
	}

	logical_device, queue, _ := create_logical_device(device, device_create_info)
	defer destroy_logical_device(logical_device)
}
