# Based on https://stackoverflow.com/a/58528177/160386
from pathlib import Path
import os
import socket
import time

xdg_runtime_dir = Path(os.environ.get('XDG_RUNTIME_DIR'))
# sock_path = xdg_runtime_dir / 'keyring/control'
sock_path = xdg_runtime_dir / 'keyring/foo'

with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
    client.connect(str(sock_path))

    while True:
        client.send(b"Client 1: hi\n")
        time.sleep(1)

    client.close()
