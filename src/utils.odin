package main

concat :: proc(a, b: []$T, alloc := context.allocator) -> []T {
	result := make([]T, len(a) + len(b), alloc)

	copy(result[:len(a)], a)
	copy(result[len(a):], b)
	return result
}

byte_to_cstring :: proc(b: []byte) -> cstring {
	return cstring(raw_data(b))
}

byte_to_number :: proc(a: []byte) -> u32 {
	result: u32
	for i in 0..<len(a) {
		result = result * 256 + u32(a[i])
	}
	return result
}
