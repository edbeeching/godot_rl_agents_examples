using Godot;
using System.Collections.Generic;

public partial class AreaPositionRandomizer : Node3D
{
    private Area3D area;
    private readonly List<MeshInstance3D> areaSpawnPoints = new();

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        foreach (Node node in GetChildren())
        {
            if (node is Area3D areaNode)
            {
                area = areaNode;
            }
            else if (node is MeshInstance3D mesh)
            {
                areaSpawnPoints.Add(mesh);
                mesh.Visible = false;
            }
        }
    }

    public void Reset()
    {
        Vector3 newAreaPosition = areaSpawnPoints[GD.RandRange(0, areaSpawnPoints.Count - 1)].GlobalPosition;
        area.GlobalPosition = newAreaPosition;
    }
}
