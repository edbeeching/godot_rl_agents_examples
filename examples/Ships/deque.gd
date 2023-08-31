class_name Deque

var _data : Array = []
var _current_index : int = 0
var max_size : int = -1:
	set(value):
		# Sets the maximum size and ensures the deque conforms to this size.
		max_size = value
		_current_index = 0
		while _data.size() > max_size:
			_data.pop_back()

# Appends an element to the end of the deque.
func push_back(value) -> void:
	if max_size > -1 and _data.size() >= max_size:
		_data.pop_front()
	_data.append(value)

# Adds an element to the beginning of the deque.
func push_front(value) -> void:
	if max_size > -1 and _data.size() >= max_size:
		_data.pop_back()
	_data.insert(0, value)

# Removes and returns the last element of the deque.
func pop_back() -> Variant:
	if _data.size() == 0:
		return null
	return _data.pop_back()

# Removes and returns the first element of the deque.
func pop_front() -> Variant:
	if _data.size() == 0:
		return null
	return _data.pop_front()

# Returns the last element of the deque without removing it.
func back() -> Variant:
	if _data.size() == 0:
		return null
	return _data[_data.size() - 1]

# Returns the first element of the deque without removing it.
func front() -> Variant:
	if _data.size() == 0:
		return null
	return _data[0]

# Returns the number of elements in the deque.
func size() -> int:
	return _data.size()

# Checks if the deque is empty.
func is_empty() -> bool:
	return _data.size() == 0

# Clears the deque.
func clear() -> void:
	_data.clear()

# Start of iteration. Resets the current index.
func _iter_init(arg) -> bool:
	_current_index = 0
	return _current_index < _data.size()

# Moves to the next item in the sequence.
func _iter_next(arg) -> bool:
	_current_index += 1
	return _current_index < _data.size()

# Returns the current item in the sequence.
func _iter_get(arg) -> Variant:
	if _current_index < _data.size():
		return _data[_current_index]
	return null

# Reset current index when setting max size
func set_max_size(value: int) -> void:
	max_size = value
	_current_index = 0
	while _data.size() > max_size:
		_data.pop_back()


