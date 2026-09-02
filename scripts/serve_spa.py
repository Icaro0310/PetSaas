#!/usr/bin/env python3
"""Servidor local para SPA Flutter com fallbacks para /p/<uuid>."""
import os
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler

ROOT = os.path.join(os.path.dirname(__file__), '..', 'build', 'web')
INDEX = os.path.join(ROOT, 'index.html')

class SpaHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def do_GET(self):
        # Tenta ficheiro concreto primeiro
        path = self.translate_path(self.path)
        if os.path.exists(path) and os.path.isfile(path):
            super().do_GET()
            return
        # Fallback: /p/<uuid> e outras rotas devolvem index.html
        self.send_response(200)
        self.send_header('Content-Type', 'text/html')
        self.end_headers()
        with open(INDEX, 'rb') as f:
            self.wfile.write(f.read())

    def log_message(self, fmt, *args):
        print(fmt % args)

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    print(f'Serving Flutter SPA from {ROOT} on http://127.0.0.1:{port}')
    HTTPServer(('127.0.0.1', port), SpaHandler).serve_forever()
