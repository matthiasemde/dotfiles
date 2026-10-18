{ lib, pkgs, ... }:

let
  pythonWithDeps = pkgs.python3.withPackages (
    ps: with ps; [
      paho-mqtt
      dbus-python
    ]
  );
in

pkgs.writeShellScriptBin "wireplumber-mqtt-volume" ''
    ${pythonWithDeps}/bin/python3 -c '
  import paho.mqtt.client as mqtt
  import subprocess
  import sys
  import os
  import time
  import logging

  # Set up logging
  logging.basicConfig(
      level=logging.INFO,
      format="%(asctime)s - %(levelname)s - %(message)s"
  )
  logger = logging.getLogger(__name__)

  # Configuration with defaults
  MQTT_BROKER = os.getenv("MQTT_BROKER", "localhost")
  MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
  MQTT_USER = os.getenv("MQTT_USER", "")
  MQTT_PASS_FILE = os.getenv("MQTT_PASS_FILE", "")
  MQTT_TOPIC = os.getenv("MQTT_TOPIC", "wireplumber/volume")
  SINK = os.getenv("SINK", "@DEFAULT_AUDIO_SINK@")

  # Read password from file if specified
  MQTT_PASS = ""
  if MQTT_PASS_FILE:
      try:
          with open(MQTT_PASS_FILE, "r") as f:
              MQTT_PASS = f.read().strip()
      except Exception as e:
          logger.error(f"Failed to read password file {MQTT_PASS_FILE}: {e}")

  def on_connect(client, userdata, flags, rc):
      if rc == 0:
          logger.info(f"Connected to MQTT broker at {MQTT_BROKER}:{MQTT_PORT}")
          client.subscribe(f"{MQTT_TOPIC}/#")
          logger.info(f"Subscribed to topic: {MQTT_TOPIC}/#")
      else:
          logger.error(f"Connection failed with result code {rc}")

  def on_message(client, userdata, msg):
      try:
          command = msg.topic.split("/")[-1]
          logger.info(f"Received command: {command} with payload: {msg.payload.decode()}")

          if command == "up":
              result = subprocess.run(["wpctl", "set-volume", SINK, "5%+"],
                                    capture_output=True, text=True)
              if result.returncode != 0:
                  logger.error(f"Volume up failed: {result.stderr}")
          elif command == "down":
              result = subprocess.run(["wpctl", "set-volume", SINK, "5%-"],
                                    capture_output=True, text=True)
              if result.returncode != 0:
                  logger.error(f"Volume down failed: {result.stderr}")
          elif command == "mute":
              result = subprocess.run(["wpctl", "set-mute", SINK, "toggle"],
                                    capture_output=True, text=True)
              if result.returncode != 0:
                  logger.error(f"Mute toggle failed: {result.stderr}")
          elif command == "set":
              try:
                  volume = float(msg.payload.decode())
                  if 0 <= volume <= 100:
                      result = subprocess.run(["wpctl", "set-volume", SINK, f"{volume}%"],
                                            capture_output=True, text=True)
                      if result.returncode != 0:
                          logger.error(f"Volume set failed: {result.stderr}")
                  else:
                      logger.error(f"Invalid volume value: {volume}")
              except ValueError:
                  logger.error(f"Invalid volume payload: {msg.payload.decode()}")
          elif command == "get":
              result = subprocess.run(["wpctl", "get-volume", SINK],
                                    capture_output=True, text=True)
              if result.returncode == 0:
                  client.publish(f"{MQTT_TOPIC}/volume", result.stdout.strip())
              else:
                  logger.error(f"Get volume failed: {result.stderr}")
      except Exception as e:
          logger.error(f"Error processing message: {e}", exc_info=True)

  def on_disconnect(client, userdata, rc):
      logger.warning(f"Disconnected from MQTT broker (rc: {rc})")
      # Try to reconnect
      time.sleep(5)
      try:
          client.reconnect()
      except Exception as e:
          logger.error(f"Reconnect failed: {e}")

  client = mqtt.Client()
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
  '
''
