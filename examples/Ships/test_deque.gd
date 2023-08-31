extends Node

func _ready():
	test_max_size()
	test_push_and_pop()
	test_iteration()

func test_max_size():
	print("Testing max_size...")
	var d = Deque.new()
	d.max_size = 3

	d.push_back(1)
	d.push_back(2)
	d.push_back(3)
	d.push_back(4)
	assert(d.size() == 3)
	assert(d.front() == 2)
	assert(d.back() == 4)
	print("Max size test passed!")

func test_push_and_pop():
	print("Testing push and pop...")
	var d = Deque.new()

	d.push_back(1)
	d.push_back(2)
	d.push_front(0)
	assert(d.pop_back() == 2)
	assert(d.pop_front() == 0)
	assert(d.front() == 1)
	assert(d.back() == 1)
	print("Push and pop test passed!")

func test_iteration():
	print("Testing iteration...")
	var d = Deque.new()
	d.max_size = 3
	d.push_back(1)
	d.push_back(2)
	d.push_back(3)
	d.push_back(4)

	var sum = 0
	for item in d:
		sum += item
	assert(sum == 9)
	print("Iteration test passed!")
