import os
import sys
import subprocess
import time
import argparse

def install_missing_packages():
    """Automatic environment setup."""
    required_packages = {"pygetwindow": "pygetwindow", "PIL": "pillow"}
    for module_name, package_name in required_packages.items():
        try:
            __import__(module_name)
        except ImportError:
            print(f"[*] Installing missing package: {package_name}...")
            subprocess.check_call([sys.executable, "-m", "pip", "install", package_name], 
                                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

install_missing_packages()

import pygetwindow as gw
from PIL import ImageGrab

def run_process_and_capture(script_path, arguments, output_filename):
    """
    Executes the script. Waits for PowerShell to change the window title indicating
    it has finished, takes a screenshot, and closes the window.
    """
    initial_title = "AutomationCaptureWindow"
    ready_title = "AutomationCaptureWindow-DONE"
    
    print(f"[*] Executing: {os.path.basename(script_path)} {arguments if arguments else ''}")
    
    # CORE LOGIC: 
    # After script execution, change the window title to 'ready_title', then call Read-Host (pause)
    
    if script_path.lower().endswith('.py'):
        ps_command = f"& '{sys.executable}' '{script_path}' {arguments}; [System.Console]::Title = '{ready_title}'; Read-Host 'Script finished execution. Press Enter...'"
    else:
        ps_command = f"& '{script_path}' {arguments}; [System.Console]::Title = '{ready_title}'; Read-Host 'Script finished execution. Press Enter...'"
        
    cmd_command = f'cmd.exe /c start /MAX "{initial_title}" powershell.exe -NoExit -Command "{ps_command}"'
    
    process = subprocess.Popen(cmd_command, shell=True)
    
    # Monitoring loop: Wait until the window title changes to "-DONE"
    # Give a maximum of 60 seconds (600 tries every 0.1s) for your script to finish
    win = None
    print("[*] Waiting for the script to finish execution in PowerShell...")
    for _ in range(600):
        time.sleep(0.1)
        windows = gw.getWindowsWithTitle(ready_title)
        if windows:
            win = windows[0]
            break
            
    if not win:
        print(f"[!] Error: The script did not finish within the designated time (60s timeout).")
        return

    try:
        # Script reported readiness! Activating window
        if win.isMinimized:
            win.restore()
        win.maximize()
        win.activate()
        
        # Short 0.4s pause to ensure Windows rendered the last lines of text
        time.sleep(0.4)
        
        # Capture window image
        bbox = (win.left, win.top, win.right, win.bottom)
        screenshot = ImageGrab.grab(bbox)
        screenshot.save(output_filename, "JPEG")
        print(f"[+] 'Pause' status detected. Screenshot saved: {os.path.basename(output_filename)}")
        
        # Safely close the console window
        win.close()
    except Exception as e:
        print(f"[!] Error during window handling: {e}")
        try:
            process.terminate()
        except:
            pass

def main():
    parser = argparse.ArgumentParser(description="Professional README screenshot generator.")
    parser.add_argument("-s", "--script", type=str, required=True, help="Path to the .ps1, .exe or .py file")
    parser.add_argument("-args", "--arguments", type=str, default="", help="Standard execution arguments")
    parsed_args = parser.parse_args()

    script_path = os.path.abspath(parsed_args.script)
    if not os.path.exists(script_path):
        print(f"[!] The specified file does not exist: {script_path}")
        return

    # Dynamically build paths in the script's directory
    script_dir = os.path.dirname(script_path)
    assets_dir = os.path.join(script_dir, "assets")
    readme_path = os.path.join(script_dir, "readme.md")
    
    os.makedirs(assets_dir, exist_ok=True)
    
    img_standard = os.path.join(assets_dir, "screenshot-standard-run.jpg")
    img_help = os.path.join(assets_dir, "screenshot-help.jpg")

    # Step 1: Standard run
    run_process_and_capture(script_path, parsed_args.arguments, img_standard)
    time.sleep(1) # Short system rest between windows
    
    # Step 2: Run with the help flag
    run_process_and_capture(script_path, "-Help", img_help)

    # Step 3: Add an entry to the README.md file (if the entry exists, do not duplicate it)
    markdown_content = (
        f"\n\n## Execution View\n\n"
        f"### Standard Run\n"
        f"![Standard Run](assets/screenshot-standard-run.jpg)\n\n"
        f"### Help Output (-Help)\n"
        f"![Help Output](assets/screenshot-help.jpg)\n"
    )
    
    readme_mode = "r+" if os.path.exists(readme_path) else "w+"
    with open(readme_path, readme_mode, encoding="utf-8") as f:
        content = f.read() if readme_mode == "r+" else ""
        if "## Execution View" not in content:
            f.write(markdown_content)
            print("[+] The graphic section has been added to the README.md file.")
        else:
            print("[*] The graphic section already exists in README.md. The JPG files have been replaced with new ones.")

    print("\n[+] The entire process completed successfully!")

if __name__ == "__main__":
    main()