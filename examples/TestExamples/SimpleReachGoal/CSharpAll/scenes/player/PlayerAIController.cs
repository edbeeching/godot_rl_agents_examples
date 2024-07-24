using Godot;
using Godot.Collections;
using System;
using Array = Godot.Collections.Array;
using Dictionary = Godot.Collections.Dictionary;

public partial class PlayerAIController : AIControllerSharp3D
{
    [Export]
    public Player Player;
    
    [Export]
    public Array<Node> RayCastSensors;

    public override void _PhysicsProcess(double delta) {
        // Intentionally not calling base._PhysicsProcess(delta)
        n_steps += 1;
        
        if(n_steps > reset_after) {
            if (DebugOn) GD.Print("Timeout reached. Setting 'needs_reset' to true.");
            Player.GameSceneManager.Reset();
        }
    }

    public void EndEpisode() {
        done = true;
        reset();
    }

    public override Dictionary get_obs() {
        var obs = new Array<float>();
        foreach (var sensor in RayCastSensors) {
            var sensorObs = (Array<float>)sensor.Call("get_observation");
            obs += sensorObs;
        }

        float levelSize = 10;
        Vector3 relativeGoalPosition = Player.ToLocal(Player.Goal.GlobalPosition);
        Vector3 relativeObstaclePosition = Player.ToLocal(Player.Obstacle.GlobalPosition);

        obs += new Array<float> {
            relativeGoalPosition.X / levelSize,
            relativeGoalPosition.Z / levelSize,
            relativeObstaclePosition.X / levelSize,
            relativeObstaclePosition.Z / levelSize
        };
        
        return new Dictionary {
            { "obs", obs }
        };
    }
    
    public override Dictionary get_action_space() {
        return new Dictionary {
            {"move_action", new Dictionary {
                {"size", 2}, {"action_type", "continuous"}
            }}
        };
    }
    
    public override void set_action(Dictionary action) {
        float x = (float)((Array) action["move_action"])[0];
        float y = (float)((Array) action["move_action"])[1];
        Player.RequestedMovement = new Vector2(x, y);
    }
}
