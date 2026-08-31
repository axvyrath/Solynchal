package main

import "core:fmt"
concat :: proc(a, b: []$T, alloc := context.allocator) -> []T {
	result := make([]T, len(a) + len(b), alloc)

	copy(result[:len(a)], a)
	copy(result[len(a):], b)
	return result
}

byte_to_cstring :: proc(b: []byte) -> cstring {
	return cstring(raw_data(b))
}

four_byte_to_number :: proc(array: []byte) -> u32 {
	assert(len(array) <= 4)

	combined := (
		u32(array[3]) |
		u32(array[2]) << 8 |
		u32(array[1]) << 16 |
		u32(array[0]) << 24
	)

	return combined
}

eight_byte_to_number :: proc(array: []byte) -> u64 {
	assert(len(array) <= 8)

	combined := (
		u64(array[7]) |
		u64(array[6]) << 8 |
		u64(array[5]) << 16 |
		u64(array[4]) << 24 |
		u64(array[3]) << 32 |
		u64(array[2]) << 40 |
		u64(array[1]) << 48 |
		u64(array[0]) << 56
	)

	return combined
}
