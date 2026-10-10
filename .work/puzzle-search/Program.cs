using System;
using System.Collections.Generic;
using System.Linq;

const int W = 7, H = 5, Pocket = 0;
var dirs = new (int dx, int dz, string name)[]
{
    (-1,0,"←"),(1,0,"→"),(0,-1,"↓"),(0,1,"↑"),(-1,-1,"↙"),(1,-1,"↘"),(-1,1,"↖"),(1,1,"↗")
};

var rng = new Random(20261010);
for (int trial = 0; trial < 100000; trial++)
{
    int main = rng.Next(1, 6) + W * rng.Next(1, 4);
    var targets = new HashSet<int>();
    while (targets.Count < 3)
    {
        int candidate = rng.Next(1, 6) + W * rng.Next(1, 4);
        if (candidate != main) targets.Add(candidate);
    }
    var walls = new HashSet<int>();
    var start = MakeState(main, targets.ToArray());
    var result = FindShortest(start, 6, walls);
    if (result is { Count: >= 5 and <= 6 })
    {
        Console.WriteLine($"START M={Pos(start.Main)} targets={string.Join(", ", start.Targets.Where(p => p >= 0).Select(Pos))}");
        Console.WriteLine("Solution (every action hits and moves at least one target):");
        var state = start;
        for (int i = 0; i < result.Count; i++)
        {
            var step = result[i];
            state = Simulate(state, step.dx, step.dz, step.power, walls)!.Value;
            Console.WriteLine($"{i + 1}. {step.name} power {step.power} -> M={Pos(state.Main)} targets={string.Join(", ", state.Targets.Where(p => p >= 0).Select(Pos))}");
        }
        return;
    }
}
Console.WriteLine("No five-move candidate found in the sampled states.");

List<(int dx, int dz, string name, int power)>? FindShortest(State start, int maxDepth, HashSet<int> walls)
{
    var seen = new HashSet<State> { start };
    var queue = new Queue<(State state, List<(int dx, int dz, string name, int power)> path)>();
    queue.Enqueue((start, new()));
    while (queue.Count > 0)
    {
        var (state, path) = queue.Dequeue();
        if (state.Targets.All(p => p < 0)) return path;
        if (path.Count == maxDepth) continue;
        foreach (var dir in dirs)
        for (int power = 1; power <= 3; power++)
        {
            var next = Simulate(state, dir.dx, dir.dz, power, walls);
            if (next is null || !seen.Add(next.Value)) continue;
            var nextPath = new List<(int, int, string, int)>(path) { (dir.dx, dir.dz, dir.name, power) };
            queue.Enqueue((next.Value, nextPath));
        }
    }
    return null;
}

static State? Simulate(State state, int initialDx, int initialDz, int power, HashSet<int> walls)
{
    var positions = state.Targets.ToArray();
    int main = state.Main, dx = initialDx, dz = initialDz, energy = power, bounces = 0;
    while (energy > 0)
    {
        int next = Step(main, dx, dz);
        if (next < 0)
        {
            if (++bounces > 8) return null;
            dx = -dx; dz = -dz;
            continue;
        }
        if (walls.Contains(next))
        {
            if (++bounces > 8) return null;
            dx = -dx; dz = -dz;
            continue;
        }
        if (next == Pocket) return null;
        int target = Array.IndexOf(positions, next);
        if (target >= 0)
        {
            main = next;
            if (!MoveTarget(positions, target, dx, dz, energy + 1, walls)) return null;
            State result = MakeState(main, positions);
            return state.Targets.SequenceEqual(result.Targets) ? null : result;
        }
        main = next;
        energy--;
    }
    return null; // A cue-ball-only move is rejected by design.
}

static bool MoveTarget(int[] positions, int mover, int dx, int dz, int energy, HashSet<int> walls)
{
    int bounces = 0, safety = 0;
    while (energy > 0 && safety++ < 50)
    {
        int next = Step(positions[mover], dx, dz);
        if (next < 0)
        {
            if (++bounces > 8) return false;
            dx = -dx; dz = -dz;
            continue;
        }
        if (walls.Contains(next))
        {
            if (++bounces > 8) return false;
            dx = -dx; dz = -dz;
            continue;
        }
        if (next == Pocket)
        {
            positions[mover] = -1;
            return true;
        }
        int other = Array.FindIndex(positions, p => p == next);
        if (other >= 0 && other != mover)
        {
            positions[mover] = next;
            mover = other;
            continue; // Target-to-target transfer keeps the remaining momentum.
        }
        positions[mover] = next;
        energy--;
        bounces = 0;
    }
    return true;
}

static int Step(int cell, int dx, int dz)
{
    if (cell < 0) return -1;
    int x = cell % W + dx, z = cell / W + dz;
    return x < 0 || x >= W || z < 0 || z >= H ? -1 : z * W + x;
}

static State MakeState(int main, params int[] targets)
{
    var sorted = targets.OrderBy(p => p).ToArray();
    return new State(main, sorted[0], sorted[1], sorted[2]);
}
static string Pos(int cell) => cell < 0 ? "pocketed" : $"({cell % W},{cell / W})";
readonly record struct State(int Main, int A, int B, int C)
{
    public int[] Targets => new[] { A, B, C };
}
