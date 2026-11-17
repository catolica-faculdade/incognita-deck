extends RefCounted

const VERSION := 1

static func write(path: String, snapshot: Dictionary) -> bool:
	var temp := path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		return false
	file.store_var(snapshot)
	file.flush()
	var error := file.get_error()
	file.close()
	if error == OK:
		error = DirAccess.rename_absolute(temp, path)
	if error != OK:
		DirAccess.remove_absolute(temp)
	return error == OK

static func read(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() < 4 or file.get_length() > 1048576:
		return {}
	var snapshot = file.get_var(false)
	if file.get_error() != OK or not snapshot is Dictionary or snapshot.get("version") != VERSION:
		return {}
	return snapshot
