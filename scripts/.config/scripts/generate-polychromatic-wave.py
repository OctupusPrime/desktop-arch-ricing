import os
import json

# Animation parameters
colors = [
  "#142015", "#103814", "#056a1e", "#086f19", "#249134", "#40a943",
  "#7ed787", "#b7efc5", "#80d983", "#7ed787", "#40a943", "#249134",
  "#086f19", "#056a1e", "#103814", "#142015"
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

dotfiles_dir = os.path.join(os.path.expanduser("~"), "dotfiles")
effect_path = os.path.join(dotfiles_dir, 'openrazer', '.config', 'polychromatic', 'effects', 'Wave.json')
effect_path = os.path.abspath(effect_path)

with open(effect_path, "w") as f:
  json.dump(output, f, indent=2)

print("Wave.json was generated successfully at:", effect_path)
