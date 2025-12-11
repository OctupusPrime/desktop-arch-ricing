# Generate a seamless diagonal wave animation for Polychromatic
# Run this script to create the Wave.json effect file
# For effect to work properly, ensure the keyboard layout matches the specified map_cols and map_rows
# To apply the effect go to Polychromatic > Effects > Wave and select play

import os
import json

# Animation parameters
colors = [
    "#141E20", "#103438", "#05616A", "#086C6F", "#248D91", "#40A8A9",
    "#7ED7D3", "#99DBDA", "#99DBDA", "#7ED7D3", "#40A8A9", "#248D91",
    "#086C6F", "#05616A", "#103438", "#141E20"
]
map_cols = 18
map_rows = 6
num_frames = len(colors)

frames = []
for frame_idx in range(num_frames):
    frame = {}
    for col in range(map_cols):
      frame[str(col)] = {}
      for row in range(map_rows):
        # Reverse direction: bottom right to top left
        color_idx = (int((map_cols - 1 - col) + 1.5 * (map_rows - 1 - row)) + frame_idx) % len(colors)
        frame[str(col)][str(row)] = colors[color_idx]
    frames.append(frame)

output = {
  "name": "Wave",
  "type": 3,
  "author": "OctupusPrime",
  "icon": "img/options/wave.svg",
  "summary": "",
  "map_device": "Razer Huntsman Tournament Edition",
  "map_device_icon": "keyboard",
  "map_graphic": "huntsman_te_en_US.svg",
  "map_cols": map_cols,
  "map_rows": map_rows,
  "save_format": 8,
  "revision": 1,
  "fps": 15,
  "loop": True,
  "frames": frames
}

effect_path = os.path.join(os.path.dirname(__file__), '..', 'effects', 'Wave.json')
effect_path = os.path.abspath(effect_path)
with open(effect_path, "w") as f:
    json.dump(output, f, indent=2)

print("Wave.json was generated successfully at:", effect_path)
