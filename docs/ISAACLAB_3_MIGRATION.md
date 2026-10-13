# Isaac Lab 3.0 Migration Notes

## Target Environment

| Component | Version |
|---|---|
| Operating system | Ubuntu 24.04.5 LTS |
| Isaac Sim | 6.1.0 |
| Isaac Lab | 3.0.0-EA |
| Python | 3.12 |
| GPU | NVIDIA RTX 5070 Ti Laptop GPU |

## Motivation

The original ORBIT-Surgical project targets an older Isaac Sim and Isaac Lab
stack. This work explores compatibility with Isaac Sim 6.1.0 and Isaac Lab
3.0.0-EA.

This is a community port, not an official upstream release.

## Main Compatibility Areas

### 1. Namespace Changes

Updated legacy Isaac Lab imports to the newer `isaaclab` and
`isaaclab_tasks` namespaces where required.

RSL-RL integration imports and related workflow scripts were also updated
for the newer package layout.

### 2. Application Launcher

Updated application startup to use the current `AppLauncher(args_cli)`
interface.

### 3. Quaternion Layout

Reviewed pose handling for the XYZW quaternion convention used by the
current pose APIs and the Warp transform interface.

Identity quaternion values must be initialized consistently with XYZW
ordering: `[0, 0, 0, 1]`.

Quaternion changes must be checked in context; blindly reordering every
quaternion can break pose commands.

### 4. Scene and Tensor APIs

Updated relevant scene access to use `env.unwrapped` and reviewed newer
pose/tensor accessors, including `.torch` and `root_link_pose_w`, where
needed.

### 5. Gymnasium Step Results

Updated affected scripts to handle Gymnasium termination and truncation
results separately:

- `terminated`
- `truncated`

Environment completion is handled using both flags where applicable.

### 6. State-Machine Scripts

The reach and lift state-machine scripts were updated for compatibility.
Task transitions, waits, offsets, and gripper behavior should remain
unchanged unless a separate, documented fix is intentionally introduced.

## Validation Policy

Passing a syntax check or successfully opening an environment does not
prove that the task performs correctly. Each task must be evaluated
separately for startup, robot motion, target tracking, and task completion.

## Known Limitations

- Not every task has been fully validated.
- Needle grasping behavior has shown inconsistent results and needs further testing.
- Large environment counts can exhaust available system resources.
- Exact reproduction of the original paper's numerical results has not been established.

## Upstream

Original repository:
https://github.com/orbit-surgical/orbit-surgical
