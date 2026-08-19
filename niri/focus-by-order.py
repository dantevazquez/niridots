#!/usr/bin/env python3
import json
import subprocess
import sys

def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    try:
        target_index = int(sys.argv[1]) - 1  # Convert 1-based keybind to 0-based index
    except ValueError:
        sys.exit(1)

    # 1. Fetch workspaces
    ws_res = subprocess.run(["niri", "msg", "-j", "workspaces"], capture_output=True, text=True)
    if ws_res.returncode != 0:
        sys.exit(1)
    workspaces = json.loads(ws_res.stdout)
    ws_map = {ws["id"]: ws for ws in workspaces}

    # 2. Fetch active windows
    win_res = subprocess.run(["niri", "msg", "-j", "windows"], capture_output=True, text=True)
    if win_res.returncode != 0:
        sys.exit(1)
    windows = json.loads(win_res.stdout)

    # Sort key: order by Workspace Index -> Column -> Row -> Window ID
    def get_sort_key(w):
        ws_info = ws_map.get(w.get("workspace_id"), {})
        ws_idx = ws_info.get("idx", 9999)
        layout = w.get("layout") or {}
        pos = layout.get("pos_in_scrolling_layout")
        if pos and isinstance(pos, list) and len(pos) >= 2:
            return (ws_idx, pos[0], pos[1], w.get("id", 0))
        return (ws_idx, float("inf"), float("inf"), w.get("id", 0))

    sorted_windows = sorted(windows, key=get_sort_key)

    if 0 <= target_index < len(sorted_windows):
        target_win = sorted_windows[target_index]
        target_id = target_win["id"]
        ws_info = ws_map.get(target_win.get("workspace_id"))
        
        # Switch workspace if necessary
        if ws_info and "idx" in ws_info:
            subprocess.run(["niri", "msg", "action", "focus-workspace", str(ws_info["idx"])])
            
        subprocess.run(["niri", "msg", "action", "focus-window", "--id", str(target_id)])

if __name__ == "__main__":
    main()

