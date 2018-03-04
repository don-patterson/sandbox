#!/usr/bin/env python

'''
This simple HTTP server listens for incoming POST requests with a particular path/key combination
and if they match, it runs either a shutdown or wake-on-lan command, depending on the input.

I set this up using IFTTT and ngrok, to respond to voice commands from Google Assistant.
The IFTTT recipe gets triggered from GA and makes a web request to ngrok, with matching path/key
params. ngrok forwards this to a local raspberry pi running this server process, which can
call the shutdown or wake-on-lan.

Not recommended as a public web server -- you should hide behind something like ngrok, or else
re-implement this using wsgi/nginx or something.
'''

from http.server import BaseHTTPRequestHandler, HTTPServer
from wakeonlan import send_magic_packet
import json
import subprocess

SERVER_PORT = 8002
PATH = '/SOME_SECRET_PATH'  # just to obfuscate things a bit
KEY = 'SOME_SECRET_KEY'     # for "security"
HOST = 'HOSTNAME'           # the host to run commands on (should set up ssh keys)
MAC = 'FF:FF:FF:FF:FF:FF'   # mac address of host for WoL

class handler(BaseHTTPRequestHandler):
    def _send(self, code):
        self.send_response(code)
        self.end_headers()

    @property
    def content(self):
        length = int(self.headers.get('Content-Length') or 0)
        return self.rfile.read(length).decode()

    def do_POST(self):
        if self.path != PATH:
            return self._send(404)

        if self.headers.get('Content-Type') != 'application/json':
            return self._send(400)

        try:
            data = json.loads(self.content)
        except json.decoder.JSONDecodeError:
            return self._send(400)

        if data.get('key') != KEY:
            return self._send(400)

        state = data.get('state') or ''
        if 'off' in state:
            print('turning off computer')
            subprocess.call(['ssh', HOST, 'sudo', 'shutdown', '-h', 'now'])
            return self._send(200)

        if 'on' in state:
            print('turning on computer')
            send_magic_packet(MAC)
            return self._send(200)

        return self._send(400)


if __name__ == '__main__':
    httpd = HTTPServer(('', SERVER_PORT), handler)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()

