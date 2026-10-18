#!/usr/bin/env python3
"""MQTT Media Remote - Control volume, playback, and audio sinks via MQTT."""

import paho.mqtt.client as mqtt
import subprocess
import sys
import os
import time
import logging
import json
import re

# Set up logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Configuration with defaults
MQTT_BROKER = os.getenv("MQTT_BROKER", "localhost")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_USER = os.getenv("MQTT_USER", "")
MQTT_PASS_FILE = os.getenv("MQTT_PASS_FILE", "")
MQTT_TOPIC = os.getenv("MQTT_TOPIC", "media-remote")
SINK = os.getenv("SINK", "@DEFAULT_AUDIO_SINK@")
SKIP_INTRO_CLICK_X = int(os.getenv("SKIP_INTRO_CLICK_X", "1750"))
SKIP_INTRO_CLICK_Y = int(os.getenv("SKIP_INTRO_CLICK_Y", "980"))
PLAYER = os.getenv("PLAYER", "")

# Read password from file if specified
MQTT_PASS = ""
if MQTT_PASS_FILE:
    try:
        with open(MQTT_PASS_FILE, "r") as f:
            MQTT_PASS = f.read().strip()
    except Exception as e:
        logger.error(f"Failed to read password file {MQTT_PASS_FILE}: {e}")


def run_playerctl(args):
    cmd = ["playerctl"]
    if PLAYER:
        cmd.extend(["--player", PLAYER])
    cmd.extend(args)
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        logger.error(f"playerctl {args} failed: {result.stderr}")
    return result


def click_at(x, y):
    """Click at absolute screen coordinates."""
    is_wayland = bool(os.getenv("WAYLAND_DISPLAY"))
    logger.info(f"Clicking at ({x}, {y}) on {'Wayland' if is_wayland else 'X11'}")
    logger.info(
        f"Environment: WAYLAND_DISPLAY={os.getenv('WAYLAND_DISPLAY')}, XDG_RUNTIME_DIR={os.getenv('XDG_RUNTIME_DIR')}, YDOTOOL_SOCKET={os.getenv('YDOTOOL_SOCKET')}"
    )
    if is_wayland:
        # Check if ydotoold is running
        try:
            r = subprocess.run(
                ["pgrep", "-x", "ydotoold"], capture_output=True, text=True
            )
            logger.info(
                f"ydotoold process check: rc={r.returncode}, output={r.stdout.strip()}"
            )
        except FileNotFoundError:
            logger.warning("pgrep not found, skipping ydotoold process check")
        # Check common socket paths
        uid = os.getenv("UID", "1000")
        socket_paths = [
            f"/run/user/{uid}/ydotoold/socket",
            "/run/ydotoold/socket",
            f"/run/user/{uid}/ydotool/socket",
        ]
        for path in socket_paths:
            exists = os.path.exists(path)
            logger.info(f"Socket {path}: {'exists' if exists else 'missing'}")
        # Run ydotool with debug
        cmd = ["ydotool", "mousemove", "-a", str(x), str(y)]
        logger.info(f"Running: {' '.join(cmd)}")
        r = subprocess.run(cmd, capture_output=True, text=True)
        logger.info(
            f"ydotool mousemove: rc={r.returncode}, stdout={r.stdout.strip()!r}, stderr={r.stderr.strip()!r}"
        )
        if r.returncode != 0:
            logger.error(f"ydotool mousemove failed: {r.stderr.strip()}")
            logger.error(
                "Hint: In systemd user service, you may need to set YDOTOOL_SOCKET env var"
            )
            logger.error(
                "Try adding to service: Environment=YDOTOOL_SOCKET=/run/user/%U/ydotoold/socket"
            )
            return False
        time.sleep(0.1)
        cmd = ["ydotool", "click", "0x40", "0x80"] # 0x00 - LEFT
        logger.info(f"Running: {' '.join(cmd)}")
        r = subprocess.run(cmd, capture_output=True, text=True)
        logger.info(
            f"ydotool click: rc={r.returncode}, stdout={r.stdout.strip()!r}, stderr={r.stderr.strip()!r}"
        )
        if r.returncode != 0:
            logger.error(f"ydotool click failed: {r.stderr.strip()}")
            return False
    else:
        cmd = ["xdotool", "mousemove", str(x), str(y), "click", "1"]
        logger.info(f"Running: {' '.join(cmd)}")
        r = subprocess.run(cmd, capture_output=True, text=True)
        logger.info(
            f"xdotool: rc={r.returncode}, stdout={r.stdout.strip()!r}, stderr={r.stderr.strip()!r}"
        )
        if r.returncode != 0:
            logger.error(f"xdotool failed: {r.stderr.strip()}")
            return False
    logger.info("Click successful")
    return True


def debug_ydotool():
    """Run diagnostics for ydotool setup."""
    logger.info("=== ydotool diagnostics ===")
    logger.info(f"WAYLAND_DISPLAY={os.getenv('WAYLAND_DISPLAY')}")
    logger.info(f"XDG_RUNTIME_DIR={os.getenv('XDG_RUNTIME_DIR')}")
    logger.info(f"YDOTOOL_SOCKET={os.getenv('YDOTOOL_SOCKET')}")
    logger.info(f"DISPLAY={os.getenv('DISPLAY')}")
    logger.info(f"USER={os.getenv('USER')}")
    logger.info(f"UID={os.getenv('UID')}")
    # Check ydotoold process
    try:
        r = subprocess.run(["pgrep", "-ax", "ydotoold"], capture_output=True, text=True)
        logger.info(f"ydotoold process: rc={r.returncode}, output={r.stdout.strip()!r}")
    except FileNotFoundError:
        logger.warning("pgrep not found")
    # Check which ydotool
    try:
        r = subprocess.run(["which", "ydotool"], capture_output=True, text=True)
        logger.info(f"ydotool path: {r.stdout.strip()!r}")
    except FileNotFoundError:
        logger.warning("which not found")
    # Try running ydotool --help
    r = subprocess.run(["ydotool", "--help"], capture_output=True, text=True)
    logger.info(f"ydotool --help: rc={r.returncode}")
    # Check socket paths
    uid = os.getenv("UID", str(os.getuid()))
    socket_paths = [
        f"/run/user/{uid}/ydotoold/socket",
        "/run/ydotoold/socket",
        f"/run/user/{uid}/ydotool/socket",
        "/tmp/ydotoold/socket",
    ]
    for path in socket_paths:
        exists = os.path.exists(path)
        logger.info(f"Socket {path}: {'EXISTS' if exists else 'missing'}")
    # Check group membership
    try:
        import grp

        gids = os.getgroups()
        group_names = [grp.getgrgid(gid).gr_name for gid in gids]
        logger.info(f"Groups: {', '.join(group_names)}")
    except Exception as e:
        logger.warning(f"Could not get groups: {e}")
    logger.info("=== end diagnostics ===")


def list_sinks():
    """List available audio sinks from wpctl status."""
    result = subprocess.run(["wpctl", "status"], capture_output=True, text=True)
    if result.returncode != 0:
        logger.error(f"wpctl status failed: {result.stderr}")
        return []

    sinks = []
    in_sinks_section = False
    for line in result.stdout.split("\n"):
        if "Sinks:" in line:
            in_sinks_section = True
            continue
        if in_sinks_section:
            if "Sources:" in line or "Devices:" in line:
                break
            cleaned = line.replace("│", "").replace("├", "").replace("└", "").strip()
            if not cleaned or (
                not cleaned[0].isdigit() and not cleaned.startswith("*")
            ):
                continue
            is_default = cleaned.startswith("*")
            if is_default:
                cleaned = cleaned[1:].strip()
            match = re.match(r"(\d+)\.\s+(.+?)\s+\[vol:\s*([\d.]+)\]", cleaned)
            if match:
                sinks.append(
                    {
                        "id": int(match.group(1)),
                        "name": match.group(2).strip(),
                        "volume": float(match.group(3)),
                        "default": is_default,
                    }
                )
    return sinks


def next_sink():
    """Switch to the next available audio sink."""
    sinks = list_sinks()
    if not sinks:
        logger.error("No sinks found")
        return False
    current_id = None
    for sink in sinks:
        if sink["default"]:
            current_id = sink["id"]
            break
    if current_id is None:
        next_id = sinks[0]["id"]
    else:
        current_index = next(
            (i for i, s in enumerate(sinks) if s["id"] == current_id), -1
        )
        next_id = sinks[(current_index + 1) % len(sinks)]["id"]
    logger.info(f"Switching to sink {next_id}")
    result = subprocess.run(
        ["wpctl", "set-default", str(next_id)], capture_output=True, text=True
    )
    if result.returncode != 0:
        logger.error(f"Failed to set default sink: {result.stderr}")
        return False
    return True


def get_category_action(topic):
    """Extract category and action from topic, ignoring the base prefix."""
    parts = topic.split("/")
    prefix_parts = MQTT_TOPIC.split("/")
    relative = parts[len(prefix_parts) :]
    category = relative[0] if len(relative) > 0 else ""
    action = relative[1] if len(relative) > 1 else ""
    return category, action


def on_connect(client, userdata, flags, reason_code, properties):
    if reason_code == 0:
        logger.info(f"Connected to MQTT broker at {MQTT_BROKER}:{MQTT_PORT}")
        client.subscribe(f"{MQTT_TOPIC}/volume/#")
        client.subscribe(f"{MQTT_TOPIC}/playback/#")
        client.subscribe(f"{MQTT_TOPIC}/sink/#")
        client.subscribe(f"{MQTT_TOPIC}/system/#")
        logger.info(
            f"Subscribed to: {MQTT_TOPIC}/volume/#, {MQTT_TOPIC}/playback/#, {MQTT_TOPIC}/sink/#, {MQTT_TOPIC}/system/#"
        )
    else:
        logger.error(f"Connection failed with reason code {reason_code}")


def on_message(client, userdata, msg):
    try:
        payload = msg.payload.decode()
        category, action = get_category_action(msg.topic)
        logger.info(f"Received: {category}/{action} with payload: {payload}")

        # Volume commands
        if category == "volume":
            if action == "up":
                result = subprocess.run(
                    ["wpctl", "set-volume", SINK, "5%+"], capture_output=True, text=True
                )
                if result.returncode != 0:
                    logger.error(f"Volume up failed: {result.stderr}")
            elif action == "down":
                result = subprocess.run(
                    ["wpctl", "set-volume", SINK, "5%-"], capture_output=True, text=True
                )
                if result.returncode != 0:
                    logger.error(f"Volume down failed: {result.stderr}")
            elif action == "mute":
                result = subprocess.run(
                    ["wpctl", "set-mute", SINK, "toggle"],
                    capture_output=True,
                    text=True,
                )
                if result.returncode != 0:
                    logger.error(f"Mute toggle failed: {result.stderr}")
            elif action == "set":
                try:
                    volume = float(payload)
                    if 0 <= volume <= 100:
                        result = subprocess.run(
                            ["wpctl", "set-volume", SINK, f"{volume}%"],
                            capture_output=True,
                            text=True,
                        )
                        if result.returncode != 0:
                            logger.error(f"Volume set failed: {result.stderr}")
                    else:
                        logger.error(f"Invalid volume value: {volume}")
                except ValueError:
                    logger.error(f"Invalid volume payload: {payload}")
            elif action == "get":
                result = subprocess.run(
                    ["wpctl", "get-volume", SINK], capture_output=True, text=True
                )
                if result.returncode == 0:
                    client.publish(f"{MQTT_TOPIC}/state/volume", result.stdout.strip())
                else:
                    logger.error(f"Get volume failed: {result.stderr}")

        # Playback commands
        elif category == "playback":
            if action == "play":
                run_playerctl(["play"])
            elif action == "pause":
                run_playerctl(["pause"])
            elif action == "play-pause":
                run_playerctl(["play-pause"])
            elif action == "stop":
                run_playerctl(["stop"])
            elif action == "next":
                run_playerctl(["next"])
            elif action in ("prev", "previous"):
                run_playerctl(["previous"])
            elif action == "skip-intro":
                click_at(SKIP_INTRO_CLICK_X, SKIP_INTRO_CLICK_Y)
            elif action == "seek":
                try:
                    offset = int(payload)
                    run_playerctl(["position", f"{offset:+d}"])
                except ValueError:
                    logger.error(f"Invalid seek payload: {payload}")
            elif action == "status":
                result = run_playerctl(["status"])
                if result.returncode == 0:
                    client.publish(
                        f"{MQTT_TOPIC}/state/playback/status", result.stdout.strip()
                    )
            elif action == "position":
                result = run_playerctl(["position"])
                if result.returncode == 0:
                    client.publish(
                        f"{MQTT_TOPIC}/state/playback/position", result.stdout.strip()
                    )

        # Sink commands
        elif category == "sink":
            if action == "list":
                sinks = list_sinks()
                client.publish(f"{MQTT_TOPIC}/state/sink/list", json.dumps(sinks))
                logger.info(f"Published {len(sinks)} sinks")
            elif action == "set":
                try:
                    sink_id = int(payload)
                    result = subprocess.run(
                        ["wpctl", "set-default", str(sink_id)],
                        capture_output=True,
                        text=True,
                    )
                    if result.returncode != 0:
                        logger.error(f"Set sink failed: {result.stderr}")
                    else:
                        logger.info(f"Switched to sink {sink_id}")
                except ValueError:
                    logger.error(f"Invalid sink ID: {payload}")
            elif action == "next":
                next_sink()
            elif action == "get":
                sinks = list_sinks()
                current = next((s for s in sinks if s["default"]), None)
                if current:
                    client.publish(
                        f"{MQTT_TOPIC}/state/sink/current", json.dumps(current)
                    )
                    logger.info(
                        f"Current sink: {current['name']} (id: {current['id']})"
                    )
                else:
                    logger.warning("No default sink found")

        # System commands
        elif category == "system":
            if action == "debug-ydotool":
                debug_ydotool()
            elif action == "debug-env":
                logger.info(f"MQTT_BROKER={MQTT_BROKER}")
                logger.info(f"MQTT_PORT={MQTT_PORT}")
                logger.info(f"MQTT_TOPIC={MQTT_TOPIC}")
                logger.info(f"SINK={SINK}")
                logger.info(f"SKIP_INTRO_CLICK_X={SKIP_INTRO_CLICK_X}")
                logger.info(f"SKIP_INTRO_CLICK_Y={SKIP_INTRO_CLICK_Y}")
                logger.info(f"PLAYER={PLAYER}")

    except Exception as e:
        logger.error(f"Error processing message: {e}", exc_info=True)


def on_disconnect(client, userdata, disconnect_flags, reason_code, properties):
    logger.warning(f"Disconnected from MQTT broker (reason: {reason_code})")
    # Try to reconnect
    time.sleep(5)
    try:
        client.reconnect()
    except Exception as e:
        logger.error(f"Reconnect failed: {e}")


def main():
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_connect = on_connect
    client.on_message = on_message
    client.on_disconnect = on_disconnect

    if MQTT_USER and MQTT_PASS:
        client.username_pw_set(MQTT_USER, MQTT_PASS)
        logger.info(f"Using MQTT authentication for user: {MQTT_USER}")

    logger.info(f"Connecting to MQTT broker at {MQTT_BROKER}:{MQTT_PORT}...")
    try:
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        client.loop_forever()
    except Exception as e:
        logger.error(f"Failed to connect to MQTT broker: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
