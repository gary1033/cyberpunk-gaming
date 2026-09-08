extends RefCounted
## Shared texture loading for imported games and freshly copied PNG sources.

static func load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	# Imported resources can exist in a PCK without their original PNG file.
	if ResourceLoader.exists(path, "Texture2D"):
		return ResourceLoader.load(path, "Texture2D") as Texture2D
	if path.get_extension().to_lower() == "png" and FileAccess.file_exists(path):
		var image := Image.new()
		if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK:
			return ImageTexture.create_from_image(image)
	return null
