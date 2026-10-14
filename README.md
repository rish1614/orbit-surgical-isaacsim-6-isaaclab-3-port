![ORBIT-Surgical](media/teaser.png)

# ORBIT-Surgical — Isaac Sim 6.1 / Isaac Lab 3.0 Port

[![Isaac Sim](https://img.shields.io/badge/Isaac%20Sim-6.1.0-silver.svg)](https://docs.isaacsim.omniverse.nvidia.com/6.1.0/installation/index.html)
[![Isaac Lab](https://img.shields.io/badge/Isaac%20Lab-3.0.0--EA-silver.svg)](https://isaac-sim.github.io/IsaacLab/v3.0.0-EA/source/setup/installation/index.html)
[![Python](https://img.shields.io/badge/Python-3.12-blue.svg)](https://www.python.org/downloads/release/python-3120/)
[![Platform](https://img.shields.io/badge/platform-Ubuntu%2024.04-orange.svg)](https://releases.ubuntu.com/24.04/)

This repository is a community compatibility port of [ORBIT-Surgical](https://github.com/orbit-surgical/orbit-surgical) for a newer NVIDIA simulation stack. It keeps the original surgical robotics framework and adapts affected APIs for **Isaac Sim 6.1.0**, **Isaac Lab 3.0.0-EA**, and **Python 3.12**.

> **Port status:** This is an independent community effort, not an official ORBIT-Surgical release. Some tasks launch and show robot motion, but not every task has been fully validated. See [tested-task status](docs/TESTED_TASKS.md) before interpreting results.

## 1. Original project and this port

The original ORBIT-Surgical setup was documented for an older stack, including Isaac Sim 4.1, Isaac Lab 1.0, and Python 3.10. Those instructions should not be used as the setup guide for this branch.

| Component | Original README | This port |
|---|---|---|
| Isaac Sim | 4.1.0 | 6.1.0 |
| Isaac Lab | 1.0.0 | 3.0.0-EA |
| Python | 3.10 | 3.12 |
| Operating system used for port testing | Ubuntu 20.04 badge in original README | Ubuntu 24.04.5 LTS |

The port updates relevant namespaces and APIs, application startup, scene/tensor access, quaternion handling, and Gymnasium termination results. The intent is to preserve task and state-machine logic wherever possible. These changes do not establish exact reproduction of the paper's numerical results.

## 2. Requirements

- A 64-bit Linux workstation. The port was developed and tested on Ubuntu 24.04.5 LTS.
- An NVIDIA GPU and a compatible NVIDIA driver.
- Git, `unzip`, CMake, and a C/C++ build toolchain.
- Isaac Sim 6.1.0 standalone Linux package.
- Isaac Lab source checkout at tag `v3.0.0-EA`.
- Python 3.12, provided through the Isaac Sim/Isaac Lab installation route below.
- Sufficient disk space for the downloaded and extracted simulator. Check the official [Isaac Sim system requirements](https://docs.isaacsim.omniverse.nvidia.com/6.1.0/installation/index.html) before installing. NVIDIA's current guidance recommends at least 32 GB of system RAM and 16 GB of GPU VRAM for full Isaac Sim workflows.

The test environment is documented in [migration notes](docs/ISAACLAB_3_MIGRATION.md). A machine with less memory may launch some scenes but can run out of resources; large environment counts have not been benchmarked systematically.

## 3. Install Isaac Sim 6.1.0

Follow NVIDIA's [Isaac Sim 6.1 installation guide](https://docs.isaacsim.omniverse.nvidia.com/6.1.0/installation/index.html). The commands below assume the Linux x86-64 standalone archive is in `~/Downloads` and is extracted to `~/isaacsim`. Adjust the archive path if needed.

```bash
sudo apt update
sudo apt install -y unzip cmake build-essential

mkdir -p "$HOME/isaacsim"
unzip "$HOME/Downloads/isaac-sim-standalone-6.1.0-linux-x86_64.zip" -d "$HOME/isaacsim"

export ISAACSIM_PATH="$HOME/isaacsim"
export ISAACSIM_PYTHON_EXE="$ISAACSIM_PATH/python.sh"

cd "$ISAACSIM_PATH"
./post_install.sh
./isaac-sim.sh
```

Wait for the application to finish its first launch, then close it. The first run may take several minutes while shader and extension caches are prepared. Verify the bundled Python interpreter:

```bash
"$ISAACSIM_PYTHON_EXE" -c "print('Isaac Sim Python is working')"
```

This guide uses the **downloaded standalone Isaac Sim package**. Follow the matching binary-install instructions from Isaac Lab; do not activate a separate Conda, `uv`, or `venv` environment for this installation route. If you prefer a Python-managed Isaac Sim installation, use the corresponding official Isaac Lab installation guide instead of mixing the two methods.

## 4. Install Isaac Lab 3.0.0-EA

Clone the matching Isaac Lab tag. The `_isaac_sim` symbolic link connects the Isaac Lab checkout to the standalone Isaac Sim installation.

```bash
cd "$HOME"
git clone --branch v3.0.0-EA https://github.com/isaac-sim/IsaacLab.git

export ISAACLAB_PATH="$HOME/IsaacLab"
export ISAACSIM_PATH="$HOME/isaacsim"

ln -s "$ISAACSIM_PATH" "$ISAACLAB_PATH/_isaac_sim"

cd "$ISAACLAB_PATH"
./isaaclab.sh -i
```

Verify that Isaac Lab can start Isaac Sim:

```bash
./isaaclab.sh -p scripts/tutorials/00_sim/create_empty.py --viz kit
```

A Kit/Isaac Sim viewport should open. Close it before moving to the next step. If `_isaac_sim` already exists, inspect it with `ls -ld "$ISAACLAB_PATH/_isaac_sim"` and confirm that it points to the intended Isaac Sim directory instead of creating a second link.

The commands above assume the standard locations `~/isaacsim` and `~/IsaacLab`. If you installed either package elsewhere, set `ISAACSIM_PATH` and `ISAACLAB_PATH` to those locations. To keep the variables across terminals, add the corresponding `export` lines to your shell profile, such as `~/.bashrc`.

## 5. Clone this port

Clone the port branch from this fork, not the original upstream repository. The original upstream repository remains linked for project history and attribution.

```bash
cd "$HOME"
git clone --branch isaacsim-6-isaaclab-3-port \
  https://github.com/rish1614/orbit-surgical-isaacsim-6-isaaclab-3-port.git

cd orbit-surgical-isaacsim-6-isaaclab-3-port
```

Confirm that the environment variables from the previous steps are set in the current terminal:

```bash
printf 'ISAACSIM_PATH=%s\n' "$ISAACSIM_PATH"
printf 'ISAACLAB_PATH=%s\n' "$ISAACLAB_PATH"
test -x "$ISAACLAB_PATH/isaaclab.sh" && echo "Isaac Lab script found"
test -e "$ISAACLAB_PATH/_isaac_sim" && echo "Isaac Sim link found"
```

## 6. Install ORBIT-Surgical extensions

From the root of the cloned ORBIT-Surgical repository, run:

```bash
bash orbitsurgical.sh
```

The script installs the `orbit.surgical.ext`, `orbit.surgical.assets`, and `orbit.surgical.tasks` extensions in editable mode using the Isaac Lab installation selected by `ISAACLAB_PATH`. If installation fails, check the first error in the terminal and confirm that `ISAACLAB_PATH` points to the matching Isaac Lab checkout.

## 7. Run a first simulation

Start with one environment and the Lift Block state-machine example. Run the command from the **ORBIT-Surgical repository root**:

```bash
"$ISAACLAB_PATH/isaaclab.sh" -p \
  source/standalone/environments/state_machine/lift_block_sm.py \
  --num_envs 1
```

For a headless launch, use:

```bash
"$ISAACLAB_PATH/isaaclab.sh" -p \
  source/standalone/environments/state_machine/lift_block_sm.py \
  --headless --num_envs 1
```

Use a low environment count for initial checks. A successful launch or visible movement is only a smoke test; it does not prove that the target pose is reached or that the complete task succeeds.

## 8. Available state-machine examples

The repository includes the following state-machine scripts under `source/standalone/environments/state_machine/`:

| Script | Current validation summary |
|---|---|
| `lift_block_sm.py` | Launch and visible motion tested; repeatable successful lifts and task metrics remain to be validated. |
| `lift_needle_sm.py` | Launch tested; needle pickup behavior is inconsistent. |
| `reach_psm_sm.py` | Launch and robot motion observed; quantitative target tracking remains to be validated. |
| `reach_dual_psm_sm.py` | Launch and arm motion observed; both end-effectors' target accuracy remains to be validated. |
| `reach_star_sm.py` | Ported script available; testing status not fully recorded. |
| `reach_dual_star_sm.py` | Ported script available; testing status not fully recorded. |

See [TESTED_TASKS.md](docs/TESTED_TASKS.md) for validation criteria, remaining checks, and resource-scaling notes. Do not report an environment as fully validated based only on startup or motion.

## 9. Learning and training workflows

The original project also documents keyboard teleoperation, demonstration collection with Robomimic, and reinforcement learning with RSL-RL. Those workflows depend on Isaac Lab script paths, task registration, and package APIs that differ across releases. The original README's commands are therefore not presented here as verified commands for this port. Check the installed scripts and the migration notes, and treat a workflow as unverified until it has been tested on this branch.

## 10. Troubleshooting

### Check system resources

```bash
free -h
nvidia-smi
```

To check whether the operating system recorded an out-of-memory kill:

```bash
journalctl -k -b --no-pager | grep -Ei 'out of memory|oom-kill|killed process' | tail -30
```

If a process is killed during startup, retry with one environment and increase the count gradually after the basic launch succeeds.

### Check paths and repository installation

```bash
printf 'ISAACLAB_PATH=%s\n' "$ISAACLAB_PATH"
printf 'ISAACSIM_PATH=%s\n' "$ISAACSIM_PATH"
ls -ld "$ISAACLAB_PATH/_isaac_sim"
```

Run `bash orbitsurgical.sh` again from the repository root after confirming the paths. Review the first fatal error in the full terminal output rather than relying only on the last line.

### Robot moves but does not reach its target

Check the target pose, coordinate frame, end-effector pose, quaternion layout, and position/orientation error. Do not change state-machine waits, offsets, gripper actions, or quaternion ordering without measuring the effect of the change.

For additional help, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) and [ISAACLAB_3_MIGRATION.md](docs/ISAACLAB_3_MIGRATION.md).

## 11. Development notes

- Keep Isaac Sim 6.1.0 and Isaac Lab `v3.0.0-EA` paired when reproducing the setup documented here.
- Preserve original task and state-machine logic unless a change is required for compatibility or is separately justified and tested.
- Record the task, exact command, environment count, observed result, and remaining limitation when validating a change.
- Run basic checks before committing:

  ```bash
  git diff --check
  ```

This fork is maintained as a compatibility effort. The migration and testing documents describe observed results; they do not claim complete validation of every task or reproduction of published results.

## 12. Acknowledgements and license

ORBIT-Surgical builds on NVIDIA Isaac Sim and Isaac Lab. Please review the applicable [NVIDIA Isaac Sim license](https://docs.omniverse.nvidia.com/), the [Isaac Lab BSD-3-Clause license](https://github.com/isaac-sim/IsaacLab/blob/main/LICENSE), and the original project's [license file](https://github.com/orbit-surgical/orbit-surgical/blob/main/LICENCE) before use or redistribution. This port is independent and is not an official NVIDIA or upstream ORBIT-Surgical release.

## 13. Citation

If you use the original ORBIT-Surgical framework in academic work, cite the paper:

```bibtex
@article{yu2024orbit,
  title   = {ORBIT-Surgical: An Open-Simulation Framework for Learning Surgical Augmented Dexterity},
  author  = {Yu, Qinxi and Moghani, Masoud and Dharmarajan, Karthik and Schorp, Vincent and Panitch, William Chung-Ho and Liu, Jingzhou and Hari, Kush and Huang, Huang and Mittal, Mayank and Goldberg, Ken and others},
  journal = {arXiv preprint arXiv:2404.16027},
  year    = {2024}
}
```

Paper: [arXiv:2404.16027](https://arxiv.org/abs/2404.16027)

Original repository: [orbit-surgical/orbit-surgical](https://github.com/orbit-surgical/orbit-surgical)