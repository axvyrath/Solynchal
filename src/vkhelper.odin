package main

import vk "vendor:vulkan"

Vulkan11Features :: distinct bit_set[Vulkan11Feature; u32]
Vulkan11Feature :: enum {
	storageBuffer16BitAccess,
	uniformAndStorageBuffer16BitAccess,
	storagePushConstant16,
	storageInputOutput16,
	multiview,
	multiviewGeometryShader,
	multiviewTessellationShader,
	variablePointersStorageBuffer,
	variablePointers,
	protectedMemory,
	samplerYcbcrConversion,
	shaderDrawParameters,
}

Vulkan12Features :: distinct bit_set[Vulkan12Feature; u64]
Vulkan12Feature :: enum {
	samplerMirrorClampToEdge,
	drawIndirectCount,
	storageBuffer8BitAccess,
	uniformAndStorageBuffer8BitAccess,
	storagePushConstant8,
	shaderBufferInt64Atomics,
	shaderSharedInt64Atomics,
	shaderFloat16,
	shaderInt8,
	descriptorIndexing,
	shaderInputAttachmentArrayDynamicIndexing,
	shaderUniformTexelBufferArrayDynamicIndexing,
	shaderStorageTexelBufferArrayDynamicIndexing,
	shaderUniformBufferArrayNonUniformIndexing,
	shaderSampledImageArrayNonUniformIndexing,
	shaderStorageBufferArrayNonUniformIndexing,
	shaderStorageImageArrayNonUniformIndexing,
	shaderInputAttachmentArrayNonUniformIndexing,
	shaderUniformTexelBufferArrayNonUniformIndexing,
	shaderStorageTexelBufferArrayNonUniformIndexing,
	descriptorBindingUniformBufferUpdateAfterBind,
	descriptorBindingSampledImageUpdateAfterBind,
	descriptorBindingStorageImageUpdateAfterBind,
	descriptorBindingStorageBufferUpdateAfterBind,
	descriptorBindingUniformTexelBufferUpdateAfterBind,
	descriptorBindingStorageTexelBufferUpdateAfterBind,
	descriptorBindingUpdateUnusedWhilePending,
	descriptorBindingPartiallyBound,
	descriptorBindingVariableDescriptorCount,
	runtimeDescriptorArray,
	samplerFilterMinmax,
	scalarBlockLayout,
	imagelessFramebuffer,
	uniformBufferStandardLayout,
	shaderSubgroupExtendedTypes,
	separateDepthStencilLayouts,
	hostQueryReset,
	timelineSemaphore,
	bufferDeviceAddress,
	bufferDeviceAddressCaptureReplay,
	bufferDeviceAddressMultiDevice,
	vulkanMemoryModel,
	vulkanMemoryModelDeviceScope,
	vulkanMemoryModelAvailabilityVisibilityChains,
	shaderOutputViewportIndex,
	shaderOutputLayer,
	subgroupBroadcastDynamicId,
}

Vulkan13Features :: distinct bit_set[Vulkan13Feature; u32]
Vulkan13Feature :: enum {
	robustImageAccess,
	inlineUniformBlock,
	descriptorBindingInlineUniformBlockUpdateAfterBind,
	pipelineCreationCacheControl,
	privateData,
	shaderDemoteToHelperInvocation,
	shaderTerminateInvocation,
	subgroupSizeControl,
	computeFullSubgroups,
	synchronization2,
	textureCompressionASTC_HDR,
	shaderZeroInitializeWorkgroupMemory,
	dynamicRendering,
	shaderIntegerDotProduct,
	maintenance4,
}

Vulkan14Features :: distinct bit_set[Vulkan14Feature; u32]
Vulkan14Feature :: enum {
	globalPriorityQuery,
	shaderSubgroupRotate,
	shaderSubgroupRotateClustered,
	shaderFloatControls2,
	shaderExpectAssume,
	rectangularLines,
	bresenhamLines,
	smoothLines,
	stippledRectangularLines,
	stippledBresenhamLines,
	stippledSmoothLines,
	vertexAttributeInstanceRateDivisor,
	vertexAttributeInstanceRateZeroDivisor,
	indexTypeUint8,
	dynamicRenderingLocalRead,
	maintenance5,
	maintenance6,
	pipelineProtectedAccess,
	pipelineRobustness,
	hostImageCopy,
	pushDescriptor,
}

@(private)
validate_vk_features :: proc(require_vk_features: $T, avail_vk_features: $U) -> bool {
	when T == Vulkan11Features {
		for feature in require_vk_features {
			switch feature {
			case .storageBuffer16BitAccess:
				if !avail_vk_features.storageBuffer16BitAccess do return false
			case .uniformAndStorageBuffer16BitAccess:
				if !avail_vk_features.uniformAndStorageBuffer16BitAccess do return false
			case .storagePushConstant16:
				if !avail_vk_features.storagePushConstant16 do return false
			case .storageInputOutput16:
				if !avail_vk_features.storageInputOutput16 do return false
			case .multiview:
				if !avail_vk_features.multiview do return false
			case .multiviewGeometryShader:
				if !avail_vk_features.multiviewGeometryShader do return false
			case .multiviewTessellationShader:
				if !avail_vk_features.multiviewTessellationShader do return false
			case .variablePointersStorageBuffer:
				if !avail_vk_features.variablePointersStorageBuffer do return false
			case .variablePointers:
				if !avail_vk_features.variablePointers do return false
			case .protectedMemory:
				if !avail_vk_features.protectedMemory do return false
			case .samplerYcbcrConversion:
				if !avail_vk_features.samplerYcbcrConversion do return false
			case .shaderDrawParameters:
				if !avail_vk_features.shaderDrawParameters do return false
			}
		}
	}
	when T == Vulkan12Features {
		for feature in require_vk_features {
			switch feature {
			case .samplerMirrorClampToEdge:
				if !avail_vk_features.samplerMirrorClampToEdge do return false
			case .drawIndirectCount:
				if !avail_vk_features.drawIndirectCount do return false
			case .storageBuffer8BitAccess:
				if !avail_vk_features.storageBuffer8BitAccess do return false
			case .uniformAndStorageBuffer8BitAccess:
				if !avail_vk_features.uniformAndStorageBuffer8BitAccess do return false
			case .storagePushConstant8:
				if !avail_vk_features.storagePushConstant8 do return false
			case .shaderBufferInt64Atomics:
				if !avail_vk_features.shaderBufferInt64Atomics do return false
			case .shaderSharedInt64Atomics:
				if !avail_vk_features.shaderSharedInt64Atomics do return false
			case .shaderFloat16:
				if !avail_vk_features.shaderFloat16 do return false
			case .shaderInt8:
				if !avail_vk_features.shaderInt8 do return false
			case .descriptorIndexing:
				if !avail_vk_features.descriptorIndexing do return false
			case .shaderInputAttachmentArrayDynamicIndexing:
				if !avail_vk_features.shaderInputAttachmentArrayDynamicIndexing do return false
			case .shaderUniformTexelBufferArrayDynamicIndexing:
				if !avail_vk_features.shaderUniformTexelBufferArrayDynamicIndexing do return false
			case .shaderStorageTexelBufferArrayDynamicIndexing:
				if !avail_vk_features.shaderStorageTexelBufferArrayDynamicIndexing do return false
			case .shaderUniformBufferArrayNonUniformIndexing:
				if !avail_vk_features.shaderUniformBufferArrayNonUniformIndexing do return false
			case .shaderSampledImageArrayNonUniformIndexing:
				if !avail_vk_features.shaderSampledImageArrayNonUniformIndexing do return false
			case .shaderStorageBufferArrayNonUniformIndexing:
				if !avail_vk_features.shaderStorageBufferArrayNonUniformIndexing do return false
			case .shaderStorageImageArrayNonUniformIndexing:
				if !avail_vk_features.shaderStorageImageArrayNonUniformIndexing do return false
			case .shaderInputAttachmentArrayNonUniformIndexing:
				if !avail_vk_features.shaderInputAttachmentArrayNonUniformIndexing do return false
			case .shaderUniformTexelBufferArrayNonUniformIndexing:
				if !avail_vk_features.shaderUniformTexelBufferArrayNonUniformIndexing do return false
			case .shaderStorageTexelBufferArrayNonUniformIndexing:
				if !avail_vk_features.shaderStorageTexelBufferArrayNonUniformIndexing do return false
			case .descriptorBindingUniformBufferUpdateAfterBind:
				if !avail_vk_features.descriptorBindingUniformBufferUpdateAfterBind do return false
			case .descriptorBindingSampledImageUpdateAfterBind:
				if !avail_vk_features.descriptorBindingSampledImageUpdateAfterBind do return false
			case .descriptorBindingStorageImageUpdateAfterBind:
				if !avail_vk_features.descriptorBindingStorageImageUpdateAfterBind do return false
			case .descriptorBindingStorageBufferUpdateAfterBind:
				if !avail_vk_features.descriptorBindingStorageBufferUpdateAfterBind do return false
			case .descriptorBindingUniformTexelBufferUpdateAfterBind:
				if !avail_vk_features.descriptorBindingUniformTexelBufferUpdateAfterBind do return false
			case .descriptorBindingStorageTexelBufferUpdateAfterBind:
				if !avail_vk_features.descriptorBindingStorageTexelBufferUpdateAfterBind do return false
			case .descriptorBindingUpdateUnusedWhilePending:
				if !avail_vk_features.descriptorBindingUpdateUnusedWhilePending do return false
			case .descriptorBindingPartiallyBound:
				if !avail_vk_features.descriptorBindingPartiallyBound do return false
			case .descriptorBindingVariableDescriptorCount:
				if !avail_vk_features.descriptorBindingVariableDescriptorCount do return false
			case .runtimeDescriptorArray:
				if !avail_vk_features.runtimeDescriptorArray do return false
			case .samplerFilterMinmax:
				if !avail_vk_features.samplerFilterMinmax do return false
			case .scalarBlockLayout:
				if !avail_vk_features.scalarBlockLayout do return false
			case .imagelessFramebuffer:
				if !avail_vk_features.imagelessFramebuffer do return false
			case .uniformBufferStandardLayout:
				if !avail_vk_features.uniformBufferStandardLayout do return false
			case .shaderSubgroupExtendedTypes:
				if !avail_vk_features.shaderSubgroupExtendedTypes do return false
			case .separateDepthStencilLayouts:
				if !avail_vk_features.separateDepthStencilLayouts do return false
			case .hostQueryReset:
				if !avail_vk_features.hostQueryReset do return false
			case .timelineSemaphore:
				if !avail_vk_features.timelineSemaphore do return false
			case .bufferDeviceAddress:
				if !avail_vk_features.bufferDeviceAddress do return false
			case .bufferDeviceAddressCaptureReplay:
				if !avail_vk_features.bufferDeviceAddressCaptureReplay do return false
			case .bufferDeviceAddressMultiDevice:
				if !avail_vk_features.bufferDeviceAddressMultiDevice do return false
			case .vulkanMemoryModel:
				if !avail_vk_features.vulkanMemoryModel do return false
			case .vulkanMemoryModelDeviceScope:
				if !avail_vk_features.vulkanMemoryModelDeviceScope do return false
			case .vulkanMemoryModelAvailabilityVisibilityChains:
				if !avail_vk_features.vulkanMemoryModelAvailabilityVisibilityChains do return false
			case .shaderOutputViewportIndex:
				if !avail_vk_features.shaderOutputViewportIndex do return false
			case .shaderOutputLayer:
				if !avail_vk_features.shaderOutputLayer do return false
			case .subgroupBroadcastDynamicId:
				if !avail_vk_features.subgroupBroadcastDynamicId do return false
			}
		}
	}
	when T == Vulkan13Features {
		for feature in require_vk_features {
			switch feature {
			case .robustImageAccess:
				if !avail_vk_features.robustImageAccess do return false
			case .inlineUniformBlock:
				if !avail_vk_features.inlineUniformBlock do return false
			case .descriptorBindingInlineUniformBlockUpdateAfterBind:
				if !avail_vk_features.descriptorBindingInlineUniformBlockUpdateAfterBind do return false
			case .pipelineCreationCacheControl:
				if !avail_vk_features.pipelineCreationCacheControl do return false
			case .privateData:
				if !avail_vk_features.privateData do return false
			case .shaderDemoteToHelperInvocation:
				if !avail_vk_features.shaderDemoteToHelperInvocation do return false
			case .shaderTerminateInvocation:
				if !avail_vk_features.shaderTerminateInvocation do return false
			case .subgroupSizeControl:
				if !avail_vk_features.subgroupSizeControl do return false
			case .computeFullSubgroups:
				if !avail_vk_features.computeFullSubgroups do return false
			case .synchronization2:
				if !avail_vk_features.synchronization2 do return false
			case .textureCompressionASTC_HDR:
				if !avail_vk_features.textureCompressionASTC_HDR do return false
			case .shaderZeroInitializeWorkgroupMemory:
				if !avail_vk_features.shaderZeroInitializeWorkgroupMemory do return false
			case .dynamicRendering:
				if !avail_vk_features.dynamicRendering do return false
			case .shaderIntegerDotProduct:
				if !avail_vk_features.shaderIntegerDotProduct do return false
			case .maintenance4:
				if !avail_vk_features.maintenance4 do return false
			}
		}
	}
	when T == Vulkan14Features {
		for feature in require_vk_features {
			switch feature {
			case .globalPriorityQuery:
				if !avail_vk_features.globalPriorityQuery do return false
			case .shaderSubgroupRotate:
				if !avail_vk_features.shaderSubgroupRotate do return false
			case .shaderSubgroupRotateClustered:
				if !avail_vk_features.shaderSubgroupRotateClustered do return false
			case .shaderFloatControls2:
				if !avail_vk_features.shaderFloatControls2 do return false
			case .shaderExpectAssume:
				if !avail_vk_features.shaderExpectAssume do return false
			case .rectangularLines:
				if !avail_vk_features.rectangularLines do return false
			case .bresenhamLines:
				if !avail_vk_features.bresenhamLines do return false
			case .smoothLines:
				if !avail_vk_features.smoothLines do return false
			case .stippledRectangularLines:
				if !avail_vk_features.stippledRectangularLines do return false
			case .stippledBresenhamLines:
				if !avail_vk_features.stippledBresenhamLines do return false
			case .stippledSmoothLines:
				if !avail_vk_features.stippledSmoothLines do return false
			case .vertexAttributeInstanceRateDivisor:
				if !avail_vk_features.vertexAttributeInstanceRateDivisor do return false
			case .vertexAttributeInstanceRateZeroDivisor:
				if !avail_vk_features.vertexAttributeInstanceRateZeroDivisor do return false
			case .indexTypeUint8:
				if !avail_vk_features.indexTypeUint8 do return false
			case .dynamicRenderingLocalRead:
				if !avail_vk_features.dynamicRenderingLocalRead do return false
			case .maintenance5:
				if !avail_vk_features.maintenance5 do return false
			case .maintenance6:
				if !avail_vk_features.maintenance6 do return false
			case .pipelineProtectedAccess:
				if !avail_vk_features.pipelineProtectedAccess do return false
			case .pipelineRobustness:
				if !avail_vk_features.pipelineRobustness do return false
			case .hostImageCopy:
				if !avail_vk_features.hostImageCopy do return false
			case .pushDescriptor:
				if !avail_vk_features.pushDescriptor do return false
			}
		}
	}
	return true
}
