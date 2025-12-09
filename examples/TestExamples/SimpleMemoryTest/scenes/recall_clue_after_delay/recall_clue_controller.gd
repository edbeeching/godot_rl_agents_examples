extends AIController2D
class_name RecallClueAfterDelayController

## Episode length in action steps
## The agent has to give the correct answer only at the last step of the episode
@export var episode_length := 5

## The correct answer will be any number from 0 to size - 1
## this also affects the obs/action size.
@export var answer_size = 5

## After how many action steps to show the correct answer hint.
@export var hint_after_action_steps := 0

## What the correct answer is.
var correct_answer: int = 0

## Action steps elapsed during the current episode.
var action_steps: int = 0


func get_obs() -> Dictionary:
	var observations: Array[float]

	## At "hint_after_action_steps", the agent sees the correct answer
	## at other steps, it sees a random number in the same range instead
	if action_steps == hint_after_action_steps:
		var correct_answer_array := one_hot_encode_int(correct_answer, answer_size - 1)
		observations.append_array(correct_answer_array)
	else:
		var random_num := randi_range(0, answer_size - 1)
		var random_num_array := one_hot_encode_int(random_num, answer_size - 1)
		observations.append_array(random_num_array)
		
	## Tells the agent whether the current obs shows the true answer
	observations.append(float(action_steps == hint_after_action_steps))

	return {"obs": observations}


func one_hot_encode_int(value: int, max_value: int) -> Array[float]:
	assert(value >= 0, "value must be >= 0")
	assert(max_value >= value, "max_value must be >= value")
	var arr: Array[float]
	arr.resize(max_value + 1)
	arr.fill(0)
	arr[value] = 1
	return arr


## Overriden not to use reset_after
func _physics_process(_delta):
	#n_steps += 1
	#if n_steps > reset_after:
		#needs_reset = true
	return


func reset():
	action_steps = 0
	n_steps = 0
	needs_reset = false
	correct_answer = randi_range(0, answer_size - 1)


func get_reward() -> float:
	return reward


func get_action_space() -> Dictionary:
	return {
		"answer": {"size": answer_size, "action_type": "discrete"},
	}


func set_action(action) -> void:
	action_steps += 1
	if action_steps == episode_length:
		reward = -abs(action.answer - correct_answer)
		done = true
		reset()
