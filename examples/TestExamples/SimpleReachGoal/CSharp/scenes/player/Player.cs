using Godot;

public partial class Player : CharacterBody3D
{
    [Export]
    public GameSceneManager GameSceneManager { get; set; }
    [Export]
    public Area3D Goal { get; set; }
    [Export]
    public Area3D Obstacle { get; set; }
    [Export]
    public Node3D AIController { get; set; }
    [Export]
    public float Speed { get => speed; set => speed = value; }
    public Vector2 RequestedMovement { get; set; }

    private float speed = 5f;
    private Transform3D initialTransform;

    public override void _Ready()
    {
        initialTransform = Transform;
    }

    public override void _PhysicsProcess(double delta)
    {
        if (!IsOnFloor())
        {
            Velocity += GetGravity() * (float)delta;
        }

        // If controlled by human, takes the keyboard arrows as input
        // otherwise, requested_movement will be set by the AIController based on RL agent's output actions
        if ((string)AIController.Get("heuristic") == "human")
        {
            RequestedMovement = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
        }

        RequestedMovement = RequestedMovement.LimitLength(1f) * Speed;

        Velocity = new(RequestedMovement.X, Velocity.Y, RequestedMovement.Y);

        // We only move when the episode is not marked as done
        // to prevent repeating a possibly wrong action from the previous episode.
        // This is related to the sync node Action Repeat functionality,
        // we don't get a new action for every physics step. This check may
        // not be required for every env, and is not used in all examples.
        if (!(bool)AIController.Get("done"))
        {
            MoveAndSlide();
        }

        ResetOnPlayerFalling();

    }

    // Resets the game if the player has fallen down
    private void ResetOnPlayerFalling()
    {
        if (GlobalPosition.Y < -1.0)
        {
            GameOver(-1.0);
        }
    }

    // Ends the game, setting an optional reward
    private void GameOver(double reward)
    {
        double currentReward = (double)AIController.Get("reward");
        AIController.Set("reward", currentReward + reward);
        GameSceneManager.Reset();
    }

    // Resets the player and AIController
    public void Reset()
    {
        AIController.Call("end_episode");
        Transform = initialTransform;
    }

    // When the goal is entered, we restart the game with a positive reward
    public void OnGoalBodyEntered(Node3D body)
    {
        GameOver(1.0);
    }

    // When the obstacle is entered, we restart the game with a negative reward
    public void OnObstacleBodyEntered(Node3D body)
    {
        GameOver(-1.0);
    }
}
