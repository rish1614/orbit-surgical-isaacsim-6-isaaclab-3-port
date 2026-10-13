# Tested Tasks and Validation Status

This document records observed behavior in the Isaac Sim 6.1.0 /
Isaac Lab 3.0.0-EA development environment.

Status is preliminary and will be updated as testing continues.

| Task | Observed status | Remaining validation |
|---|---|---|
| Lift Block, PSM | Environment launches; visible motion tested | Repeatable successful lift and task metrics |
| Lift Needle, PSM | Environment launches; pickup behavior is inconsistent | Reliable grasp and lift across repeated resets |
| Reach, PSM | Environment launches and robot motion observed | Quantitative target-position and orientation error |
| Reach, Dual PSM | Environment launches and arm motion observed | Verify both end-effectors reach their commanded targets |
| Reach, STAR | Ported script available; status not fully recorded | Run and evaluate in the target stack |
| Reach, Dual STAR | Ported script available; status not fully recorded | Run and evaluate in the target stack |

## Resource Scaling

A run with 1,500 environments was killed by the operating system during
startup in the tested configuration. The precise cause has not yet been
confirmed using system OOM logs.

Use small environment counts for initial GUI validation. Large-scale
performance and memory limits have not been systematically benchmarked.

## What Counts as Success?

- Launch verified: the environment starts without a fatal error.
- Motion observed: the robot moves in the simulation.
- Target tracking verified: measured end-effector pose errors approach and
  remain near the target.
- Task completion verified: the required task outcome is repeatedly achieved.

A task should only be marked fully validated after its success criterion
has been tested.
