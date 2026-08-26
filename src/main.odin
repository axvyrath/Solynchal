package main

import "core:c"
import "core:fmt"
import "core:dynlib"
import vk "vendor:vulkan"
import "vendor:glfw"

APPLICATION_NAME 					: cstring				: "Solynchal"
REQUIRED_EXTENSIONS					: []cstring				: {}
REQUIRED_LAYERS						: []cstring				: {"VK_LAYER_KHRONOS_validation"}
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

app_info := vk.ApplicationInfo{
	sType = .APPLICATION_INFO,
	pApplicationName = APPLICATION_NAME,
	applicationVersion = vk.MAKE_VERSION(1, 0, 0),
	pEngineName = "Optato",
	engineVersion = vk.MAKE_VERSION(1, 0, 0),
	apiVersion = vk.API_VERSION_1_3,
}

main :: proc() {
	ctx: Context

	init_vulkan(&ctx.library, REQUIRED_EXTENSIONS, REQUIRED_LAYERS, &app_info, &ctx.instance)
	defer deinit_vulkan(ctx.library, ctx.instance)

	create_window(ctx.instance, &ctx.window, DEFAULT_WINDOW_WIDTH, DEFAULT_WINDOW_HEIGHT, APPLICATION_NAME, &ctx, &ctx.surface)
	defer destory_window(ctx.instance, ctx.window, ctx.surface)
}
