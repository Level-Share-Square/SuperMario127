class_name image_util


const PNG_HEADER: PoolByteArray = PoolByteArray([
	0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A
])


static func is_png(buffer: PoolByteArray) -> bool:
	for i in range(8):
		if buffer[i] != PNG_HEADER[i]:
			return false
	return true
