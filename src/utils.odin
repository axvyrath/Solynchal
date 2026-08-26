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
