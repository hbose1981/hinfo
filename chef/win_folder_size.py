##########################################
####SCAN WINDOWS FOLDER TILL DEPTH = 4####
###### FINDS THE SIZE OF THE FOLDER ######
##########################################
import os
import tkinter as tk
from tkinter import filedialog, ttk
import humanizer
import threading

MAX_DEPTH = 4
TOP_N = 10

def get_size(path):
    total = 0
    for dirpath, _, filenames in os.walk(path):
        for f in filenames:
            try:
                fp = os.path.join(dirpath, f)
                if os.path.isfile(fp):
                    total += os.path.getsize(fp)
            except Exception:
                pass
    return total

def get_depth(path, root):
    return len(os.path.relpath(path, root).split(os.sep))

def scan_folders(root_path, tree, progress_label):
    folder_sizes = []
    for dirpath, dirnames, _ in os.walk(root_path):
        if get_depth(dirpath, root_path) > MAX_DEPTH:
            dirnames[:] = []
            continue
        size = get_size(dirpath)
        folder_sizes.append((dirpath, size))
        progress_label.config(text=f"Scanning: {dirpath}")

    sorted_folders = sorted(folder_sizes, key=lambda x: x[1], reverse=True)
    update_table(tree, sorted_folders[:TOP_N])
    progress_label.config(text="Done.")

def update_table(tree, data):
    for row in tree.get_children():
        tree.delete(row)
    for path, size in data:
        tree.insert('', 'end', values=(humanize.naturalsize(size), path))

def browse_and_scan(tree, label):
    path = filedialog.askdirectory(title="Select Folder")
    if not path:
        return
    label.config(text=f"Scanning: {path}")
    threading.Thread(target=scan_folders, args=(path, tree, label), daemon=True).start()

# --- GUI Setup ---
root = tk.Tk()
root.title("Folder Size Analyzer (Top 10)")
root.geometry("700x400")

frame = ttk.Frame(root, padding=10)
frame.pack(fill="both", expand=True)

columns = ("Size", "Path")
tree = ttk.Treeview(frame, columns=columns, show='headings')
tree.heading("Size", text="Size")
tree.heading("Path", text="Folder Path")
tree.column("Size", width=100)
tree.column("Path", width=500)
tree.pack(fill="both", expand=True)

status_label = ttk.Label(frame, text="Idle.", anchor="w")
status_label.pack(fill="x")

btn = ttk.Button(frame, text="Select Folder", command=lambda: browse_and_scan(tree, status_label))
btn.pack(pady=5)

root.mainloop()
	
