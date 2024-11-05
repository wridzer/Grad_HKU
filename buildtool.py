import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import subprocess
import shutil
import os
from threading import Thread

class GodotBuildApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Godot Build GUI")

        # Define paths based on your folder structure
        self.engine_path = os.path.abspath("godot-4.4-dev3")  # Engine source path
        self.project_path = os.path.abspath("game")           # Path to the Godot project
        self.custom_templates_path = os.path.join(self.project_path, "custom_templates")

        # Platform Selection
        ttk.Label(root, text="Platform:").grid(row=0, column=0, padx=10, pady=5, sticky="w")
        self.platform_var = tk.StringVar(value="windows")
        platforms = ["windows", "linux", "macos", "android", "ios"]
        self.platform_menu = ttk.Combobox(root, textvariable=self.platform_var, values=platforms, state="readonly")
        self.platform_menu.grid(row=0, column=1, padx=10, pady=5)

        # Tools (true/false)
        ttk.Label(root, text="Tools:").grid(row=1, column=0, padx=10, pady=5, sticky="w")
        self.tools_var = tk.BooleanVar(value=False)
        tools_checkbox = ttk.Checkbutton(root, variable=self.tools_var, text="Enable Tools")
        tools_checkbox.grid(row=1, column=1, padx=10, pady=5, sticky="w")

        # Target
        ttk.Label(root, text="Target:").grid(row=2, column=0, padx=10, pady=5, sticky="w")
        self.target_var = tk.StringVar(value="editor")
        targets = ["editor", "template_debug", "template_release"]
        self.target_menu = ttk.Combobox(root, textvariable=self.target_var, values=targets, state="readonly")
        self.target_menu.grid(row=2, column=1, padx=10, pady=5)

        # Bits (32/64)
        ttk.Label(root, text="Bits:").grid(row=3, column=0, padx=10, pady=5, sticky="w")
        self.bits_var = tk.StringVar(value="64")
        bits = ["64", "32"]
        self.bits_menu = ttk.Combobox(root, textvariable=self.bits_var, values=bits, state="readonly")
        self.bits_menu.grid(row=3, column=1, padx=10, pady=5)

        # Number of Cores
        ttk.Label(root, text="Cores:").grid(row=4, column=0, padx=10, pady=5, sticky="w")
        self.cores_var = tk.StringVar(value="4")  # Default to 4 cores
        self.cores_entry = ttk.Entry(root, textvariable=self.cores_var, width=10)
        self.cores_entry.grid(row=4, column=1, padx=10, pady=5)

        # Build Button
        self.build_button = ttk.Button(root, text="Build", command=self.run_build_thread)
        self.build_button.grid(row=5, column=0, columnspan=2, padx=10, pady=10)

        # Output Display: Last line and full output toggle
        self.output_label = ttk.Label(root, text="", font=("Arial", 10))
        self.output_label.grid(row=6, column=0, columnspan=2, padx=10, pady=5, sticky="w")

        # Toggle button for full output
        self.show_output = False
        self.toggle_output_button = ttk.Button(root, text="Show Full Output", command=self.toggle_output)
        self.toggle_output_button.grid(row=7, column=0, columnspan=2, padx=10, pady=5)

        # Full output display (hidden by default)
        self.output_box = scrolledtext.ScrolledText(root, height=10, width=50, state="disabled")
        self.output_box.grid(row=8, column=0, columnspan=2, padx=10, pady=5)
        self.output_box.grid_remove()  # Hide initially

        # Shortcuts to Open Engine and Project
        ttk.Button(root, text="Open Engine", command=self.open_engine).grid(row=9, column=0, padx=10, pady=5)
        ttk.Button(root, text="Open Project", command=self.open_project).grid(row=9, column=1, padx=10, pady=5)

    def toggle_output(self):
        # Toggle the visibility of the full output box
        if self.show_output:
            self.output_box.grid_remove()
            self.toggle_output_button.config(text="Show Full Output")
        else:
            self.output_box.grid()
            self.toggle_output_button.config(text="Hide Full Output")
        self.show_output = not self.show_output

    def run_build_thread(self):
        # Run build in a separate thread to keep UI responsive
        thread = Thread(target=self.build_project)
        thread.start()

    def build_project(self):
        platform = self.platform_var.get()
        tools = "yes" if self.tools_var.get() else "no"
        target = self.target_var.get()
        bits = self.bits_var.get()
        cores = self.cores_var.get()

        # Construct the build command
        command = f"scons platform={platform} tools={tools} target={target} bits={bits} -j{cores}"
        
        # Verify engine path
        engine_path = os.path.abspath(self.engine_path)
        if not os.path.isdir(engine_path):
            messagebox.showerror("Error", f"Engine path is invalid: {engine_path}")
            return

        try:
            # Capture the output line-by-line
            process = subprocess.Popen(command, shell=True, cwd=engine_path, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            
            # Clear previous output
            self.output_box.config(state="normal")
            self.output_box.delete(1.0, tk.END)
            self.output_box.config(state="disabled")

            # Update UI with output
            for line in iter(process.stdout.readline, ""):
                # Show the last line in output label
                self.output_label.config(text=f"{line.strip()}")

                # Append line to output box
                self.output_box.config(state="normal")
                self.output_box.insert(tk.END, line)
                self.output_box.config(state="disabled")
                self.output_box.see(tk.END)  # Auto-scroll to the latest line
            
            process.stdout.close()
            process.wait()  # Wait for process to complete

            if process.returncode == 0:
                messagebox.showinfo("Success", "Build completed successfully!")
            else:
                error_output = process.stderr.read()
                messagebox.showerror("Build Failed", f"An error occurred during the build process:\n{error_output}")

        except subprocess.CalledProcessError as e:
            messagebox.showerror("Build Error", f"Error: {str(e)}")

    def open_engine(self):
        platform = self.platform_var.get()
        bits = self.bits_var.get()

        # Select executable based on platform and bits
        if platform == "windows":
            arch_bits = f"x86_{bits}"  # For Windows, use x86_64 or x86_32
            engine_exe = f"godot.windows.editor.dev.{arch_bits}.exe"
        elif platform == "macos":
            engine_exe = "godot.osx.editor.dev.universal"
        elif platform == "linux":
            engine_exe = f"godot.x11.editor.dev.{bits}"
        else:
            messagebox.showerror("Unsupported Platform", f"Engine not available for {platform}")
            return

        engine_exe_path = os.path.join(self.engine_path, "bin", engine_exe)

        try:
            subprocess.Popen(engine_exe_path)
        except Exception as e:
            messagebox.showerror("Error", f"Could not open the engine: {e}")

    def open_project(self):
        platform = self.platform_var.get()
        bits = self.bits_var.get()

        # Select executable based on platform and bits
        if platform == "windows":
            arch_bits = f"x86_{bits}"  # For Windows, use x86_64 or x86_32
            engine_exe = f"godot.windows.editor.dev.{arch_bits}.exe"
        elif platform == "macos":
            engine_exe = "godot.osx.editor.dev.universal"
        elif platform == "linux":
            engine_exe = f"godot.x11.editor.dev.{bits}"
        else:
            messagebox.showerror("Unsupported Platform", f"Engine not available for {platform}")
            return

        engine_exe_path = os.path.join(self.engine_path, "bin", engine_exe)
        project_file = os.path.join(self.project_path, "project.godot")

        try:
            subprocess.Popen([engine_exe_path, project_file])
        except Exception as e:
            messagebox.showerror("Error", f"Could not open the project: {e}")

if __name__ == "__main__":
    root = tk.Tk()
    app = GodotBuildApp(root)
    root.mainloop()
