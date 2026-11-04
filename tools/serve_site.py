"""Serves the website locally. Usage: python tools/serve_site.py 4180 ."""
import functools
import http.server
import mimetypes
import sys
from urllib.parse import unquote, urlsplit

mimetypes.add_type("image/webp", ".webp")


class Handler(http.server.SimpleHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    extensions_map = {**http.server.SimpleHTTPRequestHandler.extensions_map, ".webp": "image/webp"}

    def send_head(self):
        # Never serve hidden files such as the .git folder.
        path = unquote(urlsplit(self.path).path).replace("\\", "/")
        if any(part.startswith(".") for part in path.split("/")):
            self.send_error(404)
            return None
        return super().send_head()

    def end_headers(self):
        self.send_header("Cache-Control", "public, max-age=300")
        super().end_headers()


class Server(http.server.ThreadingHTTPServer):
    request_queue_size = 256
    daemon_threads = True


port, root = int(sys.argv[1]), sys.argv[2]
Server(("127.0.0.1", port), functools.partial(Handler, directory=root)).serve_forever()
