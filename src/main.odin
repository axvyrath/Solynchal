package main

import "core:math"
import "core:image/png"
import "core:strings"
import "core:c"
import "core:fmt"
import "core:os"
import "core:dynlib"
import vk "vendor:vulkan"
import "vendor:glfw"
import "vendor:zlib"

APPLICATION_NAME 					: cstring				: "Solynchal"
REQUIRED_DEVICE_EXTENSIONS			: []cstring				: {vk.KHR_SWAPCHAIN_EXTENSION_NAME}
DEFAULT_WINDOW_WIDTH 				: c.int					: 800
DEFAULT_WINDOW_HEIGHT 				: c.int					: 600

PNG_HEADER							: u64					: 0x89504E470D0A1A0A
PNG_IHDR_ID							: u32					: 0x49484452
PNG_PLTE_ID							: u32					: 0x504C5445
PNG_PHYS_ID							: u32					: 0x70485973
PNG_TEXT_ID							: u32					: 0x74455874
PNG_IDAT_ID							: u32					: 0x49444154
PNG_IEND_ID							: u32					: 0x49454E44

Context :: struct {
	library					: dynlib.Library,
	instance				: vk.Instance,
	window					: glfw.WindowHandle,
	physical_device			: vk.PhysicalDevice,
	logical_device			: vk.Device,
	surface					: vk.SurfaceKHR,
	queue					: vk.Queue,
	queue_family_idx		: u32,
	swapchain				: vk.SwapchainKHR,
	swapchain_images		: []vk.Image,
	swapchain_surf_format	: vk.Format,
	swapchain_ext			: vk.Extent2D,
	swapchain_image_views	: []vk.ImageView,
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
	enable_validation_layers = true,
}

vfs_desire_features := VFSDesireFeatures{
	vulkan_11_features = {.shaderDrawParameters},
	vulkan_13_features = {.dynamicRendering, .synchronization2},
	ext_dynamic_state_features = {.extendedDynamicState},
}

@(private="file")
get_surface_capabilities :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR, alloc := context.allocator) -> vk.SurfaceCapabilitiesKHR {
	capabilities: vk.SurfaceCapabilitiesKHR
	vk.GetPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, surface, &capabilities)

	return capabilities
}

@(private="file")
get_surface_formats :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR, alloc := context.allocator) -> ([]vk.SurfaceFormatKHR, u32) {
	count: u32
	vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &count, nil)
	if count == 0 do return nil, 0

	formats := make([]vk.SurfaceFormatKHR, count, alloc)
	vk.GetPhysicalDeviceSurfaceFormatsKHR(physical_device, surface, &count, raw_data(formats))

	return formats, count
}

@(private="file")
get_surface_present_modes :: proc(physical_device: vk.PhysicalDevice, surface: vk.SurfaceKHR, alloc := context.allocator) -> ([]vk.PresentModeKHR, u32) {
	count: u32
	vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &count, nil)
	if count == 0 do return nil, 0

	present_modes := make([]vk.PresentModeKHR, count, alloc)
	vk.GetPhysicalDeviceSurfacePresentModesKHR(physical_device, surface, &count, raw_data(present_modes))

	return present_modes, count
}

@(private="file")
get_swapchain_images :: proc(logical_device: vk.Device, swapchain: vk.SwapchainKHR, alloc := context.allocator) -> ([]vk.Image, u32) {
	count: u32
	vk.GetSwapchainImagesKHR(logical_device, swapchain, &count, nil)
	if count == 0 do return nil, 0

	images := make([]vk.Image, count, alloc)
	vk.GetSwapchainImagesKHR(logical_device, swapchain, &count, raw_data(images))

	return images, count
}

read_png_file :: proc(path: string, alloc := context.allocator) -> []byte {
	data, _ := os.read_entire_file_from_path(path, alloc)
	defer delete(data)

	if eight_byte_to_number(data[:8]) != PNG_HEADER do fmt.panicf("File is not PNG.")

	offset: u32 = 8
	idat_length: u32
	concatnated: [dynamic]byte
	defer delete(concatnated)

	width: u32
	height: u32
	bit_depth: u8
	color_type: u8
	compression_method: u8
	filter_method: u8
	interlace_method: u8

	read_chunk: for true {
		chunk_length := four_byte_to_number(data[offset:offset+4])
		chunk_name := four_byte_to_number(data[offset+4:offset+8])
		chunk_data := data[offset+8:offset+8+chunk_length]

		switch chunk_name {
		case PNG_IHDR_ID:
			width = four_byte_to_number(chunk_data[0:4])
			height = four_byte_to_number(chunk_data[4:8])
			bit_depth = chunk_data[8]
			color_type = chunk_data[9]
			compression_method = chunk_data[10]
			filter_method = chunk_data[11]
			interlace_method = chunk_data[12]
		case PNG_IDAT_ID:
			for b in chunk_data {
				append(&concatnated, b)
				idat_length += 1
			}
		case PNG_IEND_ID:
			break read_chunk
		}

		offset += 12 + chunk_length
	}

	fmt.println(width, height, bit_depth, color_type, compression_method, filter_method, interlace_method)
	channels: u8
	if color_type == 2 {
		channels = 3
	} else if color_type == 3 {
		channels = 1
	} else if color_type == 4 {
		channels = 2
	} else if color_type == 6 {
		channels = 4
	}
	row_bytes := u64(math.ceil(f64(u64(width) * u64(channels) * u64(bit_depth) / 8)))
	decompressed_size := u64(height) * (1 + row_bytes)

	decompressed := make([]byte, decompressed_size)
	zlib.uncompress(raw_data(decompressed), &decompressed_size, raw_data(concatnated), u64(idat_length))

	filter := decompressed[0]
	unfiltered: []byte
	if filter == 0 {

	} else if filter == 1 {

	} else if filter == 2 {

	} else if filter == 3 {

	} else if filter == 4 {

	} else {
		fmt.panicf("Filter type not exist.")
	}

	return nil
}

create_swapchain :: proc(ctx: ^Context) {
	surface_caps := get_surface_capabilities(ctx.physical_device, ctx.surface)
	surface_formats, _ := get_surface_formats(ctx.physical_device, ctx.surface)
	surface_present_modes, _ := get_surface_present_modes(ctx.physical_device, ctx.surface)
	defer {
		delete(surface_formats)
		delete(surface_present_modes)
	}

	chosen_format: vk.SurfaceFormatKHR
	for surf_format in surface_formats {
		if surf_format.format != .R8G8B8A8_SRGB || surf_format.colorSpace != .SRGB_NONLINEAR do continue
		chosen_format = surf_format
		break
	}

	chosen_present_mode: vk.PresentModeKHR
	for present_mode in surface_present_modes {
		if present_mode != .MAILBOX do continue
		chosen_present_mode = present_mode
		break
	}

	chosen_swap_ext: vk.Extent2D
	if surface_caps.currentExtent.width != max(u32) {
		chosen_swap_ext = surface_caps.currentExtent
	} else {
		width, height := glfw.GetFramebufferSize(ctx.window)
		chosen_swap_ext.width = clamp(u32(width), surface_caps.minImageExtent.width, surface_caps.maxImageExtent.width)
		chosen_swap_ext.height = clamp(u32(height), surface_caps.minImageExtent.height, surface_caps.maxImageExtent.height)
	}

	min_image_count := max(3, surface_caps.minImageCount)
	if surface_caps.maxImageCount > 0 && min_image_count > surface_caps.maxImageCount {
		min_image_count = surface_caps.maxImageCount
	}

	create_info := vk.SwapchainCreateInfoKHR{
		sType = .SWAPCHAIN_CREATE_INFO_KHR,
		surface = ctx.surface,
		minImageCount = min_image_count,
		imageFormat = chosen_format.format,
		imageColorSpace = chosen_format.colorSpace,
		imageExtent = chosen_swap_ext,
		imageArrayLayers = 1,
		imageUsage = {.COLOR_ATTACHMENT},
		imageSharingMode = .EXCLUSIVE,
		preTransform = surface_caps.currentTransform,
		compositeAlpha = {.OPAQUE},
		presentMode = chosen_present_mode,
		clipped = true
	}

	vk.CreateSwapchainKHR(ctx.logical_device, &create_info, nil, &ctx.swapchain)

	ctx.swapchain_images, _ = get_swapchain_images(ctx.logical_device, ctx.swapchain)
	ctx.swapchain_surf_format = chosen_format.format
	ctx.swapchain_ext = chosen_swap_ext
}

destory_swapchain :: proc(ctx: ^Context) {
	vk.DestroySwapchainKHR(ctx.logical_device, ctx.swapchain, nil)
	delete(ctx.swapchain_images)
}

create_image_view :: proc(ctx: ^Context) {
	create_info := vk.ImageViewCreateInfo{
		sType = .IMAGE_VIEW_CREATE_INFO,
		viewType = .D2,
		format = ctx.swapchain_surf_format,
		components = vk.ComponentMapping{
			r = .IDENTITY,
			g = .IDENTITY,
			b = .IDENTITY,
			a = .IDENTITY,
		},
		subresourceRange = vk.ImageSubresourceRange{
			aspectMask = {.COLOR},
			levelCount = 1,
			layerCount = 1,
		},
	}

	ctx.swapchain_image_views = make([]vk.ImageView, len(ctx.swapchain_images))
	for i in 0..<len(ctx.swapchain_images) {
		create_info.image = ctx.swapchain_images[i]

		image_view: vk.ImageView
		vk.CreateImageView(ctx.logical_device, &create_info, nil, &image_view)
		ctx.swapchain_image_views[i] = image_view
	}
}

destory_image_views :: proc(ctx: ^Context) {
	for i in 0..<len(ctx.swapchain_image_views) {
		vk.DestroyImageView(ctx.logical_device, ctx.swapchain_image_views[i], nil)
	}
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
		device_extensions = REQUIRED_DEVICE_EXTENSIONS,
	}

	logical_device, queue, queue_family_idx := create_logical_device(device, device_create_info)
	defer destroy_logical_device(logical_device)

	ctx := Context{
		instance = instance.instance,
		window = instance.window,
		surface = instance.surface,
		physical_device = device,
		logical_device = logical_device,
		queue = queue,
		queue_family_idx = queue_family_idx,
	}

	read_png_file("/home/mark/Projects/solynchal/test_1.png")


}
