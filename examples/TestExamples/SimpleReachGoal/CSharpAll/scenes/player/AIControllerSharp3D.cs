using System;
using Godot;
using Dictionary = Godot.Collections.Dictionary;
using Array = Godot.Collections.Array;

[GlobalClass]
public abstract partial class AIControllerSharp3D : Node3D {
    public enum ControlModes { INHERIT_FROM_SYNC, HUMAN, TRAINING, ONNX_INFERENCE, RECORD_EXPERT_DEMOS }
    [Export] public ControlModes control_mode = ControlModes.INHERIT_FROM_SYNC;
    [Export] public string onnx_model_path  = "";
    [Export] public int reset_after = 1000;

    [ExportGroup("Record expert demos mode options")]
    // Path where the demos will be saved. The file can later be used for imitation learning.
    [Export] public String expert_demo_save_path;
    // The action that erases the last recorded episode from the currently recorded data.
    [Export] public InputEvent remove_last_episode_key;
    // Action will be repeated for n frames. Will introduce control lag if larger than 1.
    // Can be used to ensure that action_repeat on inference && training matches
    // the recorded demonstrations.
    [Export] public int action_repeat = 1;

    [ExportGroup("Debug")]
    [Export] protected bool DebugOn;

    // ONNXModel GDScript object
    public Resource onnx_model;
    public string heuristic  = "human";
    public bool done;
    public float reward;
    public int n_steps;
    public bool needs_reset;

    public Node2D _player;

    public override void _Ready() {
        base._Ready();
        AddToGroup("AGENT");
    }

    public virtual void init(Node2D player) {  
        if (DebugOn) GD.Print("Initializing AIController...");
        _player = player;
    }
	
    public virtual float get_reward() {
        return reward;
    }
	
    //-- Methods that need implementing using the "extend script" option in Godot --#

    public abstract Dictionary get_obs();
	

    public abstract Dictionary get_action_space();

    public abstract void set_action(Dictionary action);

    //-----------------------------------------------------------------------------#


    //-- Methods that sometimes need implementing using the "extend script" option in Godot --#
    // Only needed if you are recording expert demos with this AIController
    public virtual Array get_action() {
        throw new NotImplementedException();
    }
	
    // -----------------------------------------------------------------------------#

    public override void _PhysicsProcess(double delta) {
        base._PhysicsProcess(delta);
        n_steps += 1;
        if(n_steps > reset_after) {
            if (DebugOn) GD.Print("Timeout reached. Setting 'needs_reset' to true.");
            needs_reset = true;
        }
    }
	
    public virtual Dictionary get_obs_space() {
        // may need overriding if the obs space is complex
        Dictionary obs = get_obs();
        Array size = new Array
        {
            ((Array)obs["obs"]).Count
        };
        return new Dictionary()
        {
            {
                "obs", new Dictionary()
                {
                    { "size", size },
                    { "space", "box" }
                }
            }
        };
    }
	
    public void reset() {  
        if (DebugOn) GD.Print("Resetting AIController...");
        n_steps = 0;
        needs_reset = false;
    }
	
    public void reset_if_done() {  
        if (DebugOn) GD.Print("Resetting if done...");
        if(done) {
            reset();
        }
    }
	
    public void set_heuristic(String h) {  
        if (DebugOn) GD.Print("Setting heuristic...");
        // sets the heuristic from "human" || "model" nothing to change here
        heuristic = h;
    }
	
    public bool get_done() {  
        return done;
    }
	
    public void set_done_false() {  
        done = false;
    }
	
    public void zero_reward() {  
        reward = 0.0f;
    }
}
