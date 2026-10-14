# Troubleshooting

## 1. SSH Access to GitHub

Check SSH authentication:

```bash
ssh -T git@github.com
```

Check configured remotes:

```bash
git remote -v
```

`origin` should point to your fork and `upstream` to the official repository.

## 2. Environment Does Not Launch

Start with one environment from the repository root:

```bash
"$ISAACLAB_PATH/isaaclab.sh" -p source/standalone/environments/state_machine/lift_block_sm.py --num_envs 1
"$ISAACLAB_PATH/isaaclab.sh" -p source/standalone/environments/state_machine/lift_block_sm.py --headless --num_envs 1
```

Review the first fatal error in the terminal log. Warnings about deprecated APIs do not necessarily mean that the application has failed.

## 3. Process Is Killed at Large Environment Counts

Check available system memory:

```bash
free -h
nvidia-smi
```

Check kernel logs for an out-of-memory kill:

```bash
journalctl -k -b --no-pager | grep -Ei 'out of memory|oom-kill|killed process' | tail -30
```

Start with a small environment count and increase it gradually. GUI rendering also consumes system resources.

## 4. Robot Moves but Does Not Reach the Target

Check the coordinate frame, desired pose, end-effector pose, quaternion layout, and target-position/orientation error.

Visible movement alone is not sufficient to establish task success.

## 5. Needle Does Not Get Picked Reliably

Inspect the needle reset pose, tool-to-needle alignment, gripper contact geometry, and state-machine action sequence.

Do not change state-machine timing or offsets without recording and testing the effect of the change.

## 6. Validate Before Reporting Results

Record the software versions, task ID, exact launch command, environment count, observed result, and known limitations for each run.
