using Godot;

public partial class GameSceneManager : Node3D
{
    [Export]
    public AreaPositionRandomizer GoalManager { get; set; }
    [Export]
    public AreaPositionRandomizer ObstacleManager { get; set; }
    [Export]
    public Player Player { get; set; }

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        Reset();
    }

    public void Reset()
    {
        GoalManager.Reset();
        ObstacleManager.Reset();
        Player.Reset();
    }
}
