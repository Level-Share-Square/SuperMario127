class_name image_util


const WEBP_HEADER: PoolByteArray = PoolByteArray([
	0x52, 0x49, 0x46, 0x46
])
const PNG_HEADER: PoolByteArray = PoolByteArray([
	0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A
])


static func is_webp(buffer: PoolByteArray) -> bool:
	if buffer.size() < 4:
		return false
	
	for i in range(4):
		if buffer[i] != WEBP_HEADER[i]:
			return false
	return true

static func is_png(buffer: PoolByteArray) -> bool:
	if buffer.size() < 8:
		return false
	
	for i in range(8):
		if buffer[i] != PNG_HEADER[i]:
			return false
	return true
