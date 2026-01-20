# Simple Memory Test Env

A no graphics simple memory test environment.
Can be used for testing and comparing different memory approaches (e.g. RNNs, frame stacking, memory buffers controlled by the RL agent actions, etc.).

Currently with a single task only:

Recall answer after n steps. The answer is a single number, one hot encoded for obs.

Adjustments with exported variables:

- Episode length (only action at last step is considered for the answer/reward)
- Answer size (discrete action size is set based on this, as well as the one hot encoded integers array sizes)
- After how many action steps to show the hint/correct obs

Observations:

- One hot encoded: Correct answer or random number in the same range
- Correct answer shown flag

Actions:

- Single discrete action. At the last step of the episode, it should match the correct answer.

Reward:

Given at the last step: -abs(action.answer - correct_answer).
