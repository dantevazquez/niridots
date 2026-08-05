#!/usr/bin/env python3
import json
import subprocess
import sys

def get_workspace_1_id():
    try:
        result = subprocess.run(["niri", "msg", "-j", "workspaces"], capture_output=True, text=True)
        if result.returncode == 0:
            workspaces = json.loads(result.stdout)
            for ws in workspaces:
                if ws.get("idx") == 1:
                    return ws.get("id")
    except Exception:
        pass
    return 1

def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    try:
        target_index = int(sys.argv[1]) - 1  # Convert 1-based keybind to 0-based index
    except ValueError:
        sys.exit(1)

    # Fetch active windows from niri IPC
    result = subprocess.run(["niri", "msg", "-j", "windows"], capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(1)

    windows = json.loads(result.stdout)

    ws1_id = get_workspace_1_id()

    # Filter windows in workspace 1
    ws1_windows = [w for w in windows if w.get("workspace_id") == ws1_id]

    # Sort windows by left-to-right order (pos_in_scrolling_layout [column, row])
    def get_sort_key(w):
        layout = w.get("layout") or {}
        pos = layout.get("pos_in_scrolling_layout")
        if pos and isinstance(pos, list) and len(pos) >= 2:
            return (pos[0], pos[1], w.get("id", 0))
        return (float('inf'), float('inf'), w.get("id", 0))

    sorted_windows = sorted(ws1_windows, key=get_sort_key)

    if 0 <= target_index < len(sorted_windows):
        target_id = sorted_windows[target_index]["id"]
        subprocess.run(["niri", "msg", "action", "focus-window", "--id", str(target_id)])

if __name__ == "__main__":
    main()

