package main

import "core:reflect"
import "core:c"
import "core:dynlib"
import "core:fmt"
import vk "vendor:vulkan"
import "vendor:glfw"

VULKAN_LIBRARY_NAME 				: string		: "libvulkan.so.1"
VALIDATION_LAYER_NAME				: cstring		: "VK_LAYER_KHRONOS_validation"

PhysicalDeviceInfo :: struct {
	properties: vk.PhysicalDeviceProperties,
	features: vk.PhysicalDeviceFeatures,
	vk11_features: vk.PhysicalDeviceVulkan11Features,
	vk12_features: vk.PhysicalDeviceVulkan12Features,
	vk13_features: vk.PhysicalDeviceVulkan13Features,
	vk14_features: vk.PhysicalDeviceVulkan14Features,
	ext_dynamic_state_features: vk.PhysicalDeviceExtendedDynamicStateFeaturesEXT,
}

@(private="file")
load_vulkan_library :: proc(library: ^dynlib.Library) {
	vulkan_lib, success := dynlib.load_library(VULKAN_LIBRARY_NAME)
	if !success do fmt.panicf("Failed to load vulkan library.")

	get_instance_proc_addr, found := dynlib.symbol_address(vulkan_lib, "vkGetInstanceProcAddr")
	if !found do fmt.panicf("Failed to find vkGetInstanceProcAddr.")

	vk.load_proc_addresses_global(get_instance_proc_addr)
	library^ = vulkan_lib
}

@(private="file")
get_instance_extension_props :: proc(alloc := context.allocator) -> ([]vk.ExtensionProperties, u32) {
	count: u32
	vk.EnumerateInstanceExtensionProperties(nil, &count, nil)

	props := make([]vk.ExtensionProperties, count, alloc)
	vk.EnumerateInstanceExtensionProperties(nil, &count, raw_data(props))

	return props, count
}

@(private="file")
get_instance_layer_props :: proc(alloc := context.allocator) -> ([]vk.LayerProperties, u32) {
	count: u32
	vk.EnumerateInstanceLayerProperties(&count, nil)

	props := make([]vk.LayerProperties, count, alloc)
	vk.EnumerateInstanceLayerProperties(&count, raw_data(props))

	return props, count
}

@(private="file")
validate_required_extensions :: proc(required_extensions: []cstring, avail_extensions: []vk.ExtensionProperties) {
	for required_extension in required_extensions {
		found := false
		for i in 0..<len(avail_extensions) {
			avail_extension := avail_extensions[i]
			if required_extension == byte_to_cstring(avail_extension.extensionName[:]) {
				found = true
				break
			}
		}
		if !found do fmt.panicf("Required extension %s not found.", required_extension)
	}
}

@(private="file")
validate_required_layers :: proc(required_layers: []cstring, avail_layers: []vk.LayerProperties) {
	for required_layer in required_layers {
		found := false
		for i in 0..<len(avail_layers) {
			avail_layer := avail_layers[i]
			if required_layer == byte_to_cstring(avail_layer.layerName[:]) {
				found = true
				break
			}
		}
		if !found do fmt.panicf("Required layer %s not found.", required_layer)
	}
}

@(private="file")
create_vulkan_instance :: proc(info: VFSInstanceCreateInfo, required_extension_props: []cstring, required_layers_props: []cstring) -> vk.Instance {
	app_info := vk.ApplicationInfo{
		sType = .APPLICATION_INFO,
		pApplicationName = info.app_name,
		applicationVersion = info.app_version,
		pEngineName = info.engine_name,
		engineVersion = info.engine_version,
		apiVersion = info.api_version,
	}

	create_info := vk.InstanceCreateInfo{
		sType = .INSTANCE_CREATE_INFO,
		pApplicationInfo = &app_info,
		enabledExtensionCount = u32(len(required_extension_props)),
		ppEnabledExtensionNames = raw_data(required_extension_props),
		enabledLayerCount = u32(len(required_layers_props)),
		ppEnabledLayerNames = raw_data(required_layers_props),
	}

	instance: vk.Instance
	if vk.CreateInstance(&create_info, nil, &instance) != .SUCCESS {
		fmt.panicf("Failed to create Vulkan instance.")}

	return instance
}

@(private="file")
create_drawable_surface :: proc(info: VFSInstanceCreateInfo, instance: vk.Instance) -> (vk.SurfaceKHR, glfw.WindowHandle) {
	glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
	glfw.WindowHint(glfw.RESIZABLE, glfw.FALSE)
	window := glfw.CreateWindow(info.window_width, info.window_height, info.window_title, nil, nil)
	if window == nil do fmt.panicf("Failed to create window.")

	glfw.MakeContextCurrent(window)

	create_info := vk.WaylandSurfaceCreateInfoKHR{
		sType = .WAYLAND_SURFACE_CREATE_INFO_KHR,
		display = (^vk.wl_display)(glfw.GetWaylandDisplay()),
		surface = (^vk.wl_surface)(glfw.GetWaylandWindow(window)),
	}

	surface: vk.SurfaceKHR
	if vk.CreateWaylandSurfaceKHR(instance, &create_info, nil, &surface) != .SUCCESS {
		fmt.panicf("Failed to create drawable surface.")}

	return surface, window
}

@(private="file")
get_physical_devices :: proc(instance: vk.Instance, alloc := context.allocator) -> ([]vk.PhysicalDevice, u32) {
	count: u32
	vk.EnumeratePhysicalDevices(instance, &count, nil)

	devices := make([]vk.PhysicalDevice, count, alloc)
	vk.EnumeratePhysicalDevices(instance, &count, raw_data(devices))

	return devices, count
}

@(private="file")
get_physical_device_info :: proc(device: vk.PhysicalDevice) -> PhysicalDeviceInfo {
	vk11_features := vk.PhysicalDeviceVulkan11Features{sType = .PHYSICAL_DEVICE_VULKAN_1_1_FEATURES}
	vk12_features := vk.PhysicalDeviceVulkan12Features{sType = .PHYSICAL_DEVICE_VULKAN_1_2_FEATURES}
	vk13_features := vk.PhysicalDeviceVulkan13Features{sType = .PHYSICAL_DEVICE_VULKAN_1_3_FEATURES}
	vk14_features := vk.PhysicalDeviceVulkan14Features{sType = .PHYSICAL_DEVICE_VULKAN_1_4_FEATURES}
	ext_dynamic_state_features := vk.PhysicalDeviceExtendedDynamicStateFeaturesEXT{sType = .PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_FEATURES_EXT}

	vk11_features.pNext = &vk12_features
	vk12_features.pNext = &vk13_features
	vk13_features.pNext = &vk14_features
	vk14_features.pNext = &ext_dynamic_state_features

	props: vk.PhysicalDeviceProperties
	features := vk.PhysicalDeviceFeatures2{
		sType = .PHYSICAL_DEVICE_FEATURES_2,
		pNext = &vk11_features,
	}

	vk.GetPhysicalDeviceProperties(device, &props)
	vk.GetPhysicalDeviceFeatures2(device, &features)

	physical_device_info := PhysicalDeviceInfo{
		properties = props,
		features = features.features,
		vk11_features = vk11_features,
		vk12_features = vk12_features,
		vk13_features = vk13_features,
		vk14_features = vk14_features,
		ext_dynamic_state_features = ext_dynamic_state_features,
	}

	return physical_device_info
}

@(private="file")
get_physical_device_extention_props :: proc(device: vk.PhysicalDevice, alloc := context.allocator) -> ([]vk.ExtensionProperties, u32) {
	count: u32
	vk.EnumerateDeviceExtensionProperties(device, nil, &count, nil)
	if count == 0 do return nil, 0

	props := make([]vk.ExtensionProperties, count, alloc)
	vk.EnumerateDeviceExtensionProperties(device, nil, &count, raw_data(props))

	return props, count
}

@(private="file")
get_physical_device_queue_families :: proc(device: vk.PhysicalDevice, alloc := context.allocator) -> ([]vk.QueueFamilyProperties, u32) {
	count: u32
	vk.GetPhysicalDeviceQueueFamilyProperties(device, &count, nil)
	if count == 0 do return nil, 0

	queue_families := make([]vk.QueueFamilyProperties, count, alloc)
	vk.GetPhysicalDeviceQueueFamilyProperties(device, &count, raw_data(queue_families))

	return queue_families, count
}

@(private="file")
validate_dedicated_queue_family :: proc(queue_families: []vk.QueueFamilyProperties, family: vk.QueueFlag) -> bool {
	for queue_family in queue_families {
		if family in queue_family.queueFlags && queue_family.queueCount == 1 do return true
	}
	return false
}

@(private="file")
validate_seperated_queue_family :: proc(queue_families: []vk.QueueFamilyProperties, family: vk.QueueFlag) -> bool {
	for queue_family in queue_families {
		if family in queue_family.queueFlags && !(vk.QueueFlag.COMPUTE in queue_family.queueFlags) do return true
	}
	return false
}

@(private="file")
validate_desire_queue_families :: proc(queue_families: []vk.QueueFamilyProperties, desire_families: DesireQueueFamilies) -> bool {
	for desire_family in desire_families {
		pass_validation := false

		switch desire_family {
		case .DedicatedComputeQueue:
			if validate_dedicated_queue_family(queue_families, .COMPUTE) do pass_validation = true
		case .DedicatedTransferQueue:
			if validate_dedicated_queue_family(queue_families, .TRANSFER) do pass_validation = true
		case .SeperatedComputeQueue:
			if validate_seperated_queue_family(queue_families, .COMPUTE) do pass_validation = true
		case .SeperatedTransferQueue:
			if validate_seperated_queue_family(queue_families, .TRANSFER) do pass_validation = true
		}

		if !pass_validation do return false
	}

	return true
}

@(private="file")
validate_memory_size :: proc(physical_device: vk.PhysicalDevice, memory_size: vk.DeviceSize) -> bool {
	memory_properties: vk.PhysicalDeviceMemoryProperties
	vk.GetPhysicalDeviceMemoryProperties(physical_device, &memory_properties)

	total_memory: vk.DeviceSize
	for memory_heap in memory_properties.memoryHeaps {
		total_memory += memory_heap.size
	}

	return total_memory >= memory_size
}

@(private="file")
validate_present_support :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR) -> bool {
	count: u32
	vk.GetPhysicalDeviceQueueFamilyProperties(physical_device, &count, nil)

	for i in 0..<count {
		supported: b32
		vk.GetPhysicalDeviceSurfaceSupportKHR(physical_device, i, surface, &supported)
		if supported do return true
	}

	return false
}

VFSInstance :: struct {
	library: dynlib.Library,
	instance: vk.Instance,
	window: glfw.WindowHandle,
	surface: vk.SurfaceKHR,
}

VFSInstanceCreateInfo :: struct {
	app_name: cstring,
	app_version: u32,
	engine_name: cstring,
	engine_version: u32,
	api_version: u32,

	window_width: c.int,
	window_height: c.int,
	window_title: cstring,

	enable_extensions: []cstring,
	enable_layers: []cstring,
	enable_validation_layers: bool,
}

create_instance :: proc(info: VFSInstanceCreateInfo) -> VFSInstance {
	vulkan_lib: dynlib.Library
	load_vulkan_library(&vulkan_lib)

	if !glfw.Init() do fmt.panicf("Failed to initialize GLFW.")
	glfw_extensions := glfw.GetRequiredInstanceExtensions()
	glfw_extensions_count := u32(len(glfw_extensions))

	avail_extension_props, _ := get_instance_extension_props()
	required_extension_props: []cstring
	if info.enable_extensions != nil {
		required_extension_props = concat(info.enable_extensions, glfw_extensions)
	} else {
		required_extension_props = make([]cstring, glfw_extensions_count)
		copy(required_extension_props, glfw_extensions)
	}

	defer {
		delete(avail_extension_props)
		delete(required_extension_props)
	}

	validate_required_extensions(required_extension_props, avail_extension_props)

	avail_layers_props, _ := get_instance_layer_props()
	required_layers_props: []cstring
	if info.enable_layers != nil {
		required_layers_props = info.enable_layers
	} else {
		required_layers_props = []cstring{}
	}

	if info.enable_validation_layers {
		required_layers_props = concat(required_layers_props, []cstring{VALIDATION_LAYER_NAME})
	}

	defer {
		delete(avail_layers_props)
		delete(required_layers_props)
	}

	validate_required_layers(required_layers_props, avail_layers_props)

	instance := create_vulkan_instance(info, required_extension_props, required_layers_props)
	vk.load_proc_addresses_instance(instance)

	surface, window := create_drawable_surface(info, instance)

	vfs_instance := VFSInstance{
		library = vulkan_lib,
		instance = instance,
		window = window,
		surface = surface,
	}

	return vfs_instance
}

destroy_instance :: proc(ctx: VFSInstance) {
	vk.DestroySurfaceKHR(ctx.instance, ctx.surface, nil)
	glfw.DestroyWindow(ctx.window)
	vk.DestroyInstance(ctx.instance, nil)
	dynlib.unload_library(ctx.library)
}

DesireQueueFamilies :: distinct bit_set[DesireQueueFamily; u8]
DesireQueueFamily :: enum {
	DedicatedComputeQueue = 0,
	DedicatedTransferQueue = 1,
	SeperatedComputeQueue = 2,
	SeperatedTransferQueue = 3,
}

VFSDesireFeatures :: struct {
	vulkan_11_features: Vulkan11Features,
	vulkan_12_features: Vulkan12Features,
	vulkan_13_features: Vulkan13Features,
	vulkan_14_features: Vulkan14Features,
	ext_dynamic_state_features: ExtDynamicStateFeatures,
}

VFSSelectPhysicalDeviceInfo :: struct {
	surface: vk.SurfaceKHR,

	desire_queue_families: DesireQueueFamilies,
	prefer_device_type: vk.PhysicalDeviceType,
	require_present_support: b32,
	require_device_memory_size: vk.DeviceSize,
	minimum_vulkan_version: u32,

	desire_features: VFSDesireFeatures,
}

select_physical_device :: proc(ctx: VFSInstance, info: VFSSelectPhysicalDeviceInfo) -> vk.PhysicalDevice {
	l_info := info
	physical_devices, _ := get_physical_devices(ctx.instance)
	defer delete(physical_devices)

	desire_features := info.desire_features

	selected_physical_device: vk.PhysicalDevice
	for device in physical_devices {
		device_info := get_physical_device_info(device)
		fmt.println(string(byte_to_cstring(device_info.properties.deviceName[:])))

		queue_familes, _ := get_physical_device_queue_families(device)
		device_exts, _ := get_physical_device_extention_props(device)
		defer {
			delete(queue_familes)
			delete(device_exts)
		}

		if info.desire_queue_families != nil && !validate_desire_queue_families(queue_familes, info.desire_queue_families) do continue
		if info.prefer_device_type != nil && device_info.properties.deviceType != info.prefer_device_type do continue
		if info.require_present_support != false && !validate_present_support(device, info.surface) do continue
		if info.require_device_memory_size != 0 && !validate_memory_size(device, info.require_device_memory_size) do continue
		if info.minimum_vulkan_version != 0 && device_info.properties.apiVersion < info.minimum_vulkan_version do continue
		if desire_features.vulkan_11_features != {} && !validate_vk11_features(desire_features.vulkan_11_features, device_info.vk11_features) do continue
		if desire_features.vulkan_12_features != {} && !validate_vk12_features(desire_features.vulkan_12_features, device_info.vk12_features) do continue
		if desire_features.vulkan_13_features != {} && !validate_vk13_features(desire_features.vulkan_13_features, device_info.vk13_features) do continue
		if desire_features.vulkan_14_features != {} && !validate_vk14_features(desire_features.vulkan_14_features, device_info.vk14_features) do continue
		if desire_features.ext_dynamic_state_features != {} && !validate_ext_dynamic_state_features(desire_features.ext_dynamic_state_features, device_info.ext_dynamic_state_features) do continue

		selected_physical_device = device
		break
	}


	if selected_physical_device == nil do fmt.panicf("No physical device met the requirements.")
	return selected_physical_device
}

VFSLogicalDeviceCreateInfo :: struct {
	desire_features: VFSDesireFeatures,
	desire_queue_flag: vk.QueueFlag,
	queue_priority: f32,
	device_extensions: []cstring,
}

create_logical_device :: proc(physical_device: vk.PhysicalDevice, info: VFSLogicalDeviceCreateInfo) -> (vk.Device, vk.Queue, u32) {
	l_info := info
	queue_families, count := get_physical_device_queue_families(physical_device)

	queue_family_index: u32
	for i in 0..<count {
		queue_family := queue_families[i]
		if info.desire_queue_flag in queue_family.queueFlags {
			queue_family_index = i
			break
		}
	}

	desire_features := l_info.desire_features
	vulkan_11_features := make_vulkan_11_features(desire_features.vulkan_11_features)
	vulkan_12_features := make_vulkan_12_features(desire_features.vulkan_12_features)
	vulkan_13_features := make_vulkan_13_features(desire_features.vulkan_13_features)
	vulkan_14_features := make_vulkan_14_features(desire_features.vulkan_14_features)
	ext_dynamic_state_features := make_ext_dynamic_state_features(desire_features.ext_dynamic_state_features)

	vulkan_11_features.pNext = &vulkan_12_features
	vulkan_12_features.pNext = &vulkan_13_features
	vulkan_13_features.pNext = &vulkan_14_features
	vulkan_14_features.pNext = &ext_dynamic_state_features

	queue_create_info := vk.DeviceQueueCreateInfo{
		sType = .DEVICE_QUEUE_CREATE_INFO,
		queueFamilyIndex = queue_family_index,
		queueCount = 1,
		pQueuePriorities = &l_info.queue_priority,
	}

	device_features := vk.PhysicalDeviceFeatures2{
		sType = .PHYSICAL_DEVICE_FEATURES_2,
		pNext = &vulkan_11_features,
	}
	device_create_info := vk.DeviceCreateInfo{
		sType = .DEVICE_CREATE_INFO,
		pNext = &device_features,
		queueCreateInfoCount = 1,
		pQueueCreateInfos = &queue_create_info,
		enabledExtensionCount = u32(len(l_info.device_extensions)),
		ppEnabledExtensionNames = raw_data(l_info.device_extensions[:]),
	}

	logical_device: vk.Device
	queue: vk.Queue
	vk.CreateDevice(physical_device, &device_create_info, nil, &logical_device)
	vk.GetDeviceQueue(logical_device, queue_family_index, 0, &queue)
	return logical_device, queue, queue_family_index
}

destroy_logical_device :: proc(logical_device: vk.Device) {
	vk.DestroyDevice(logical_device, nil)
}
