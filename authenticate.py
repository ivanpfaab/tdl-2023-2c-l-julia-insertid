import webbrowser
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse
import os
from dotenv import load_dotenv
import time
import sys
from threading import Timer
from spotipy.oauth2 import SpotifyOAuth

load_dotenv()  # Loading .env file

callback_uri = os.getenv("TDL_CALLBACK_URI")
client_id = os.getenv("TDL_SPOTIFY_CLIENT_ID")
client_secret = os.getenv("TDL_SPOTIFY_CLIENT_SECRET")

def get_auth_url():
    scopes = "user-read-recently-played user-top-read playlist-modify-public"
    sp_oauth = SpotifyOAuth(client_id, client_secret, callback_uri, scope=scopes, state="h1h2h3h4h5")
    return sp_oauth.get_authorize_url()

server = None

def save_auth_code(code):
    with open('.env', 'r') as file:
        lines = file.readlines()

    with open('.env', 'w') as file:
        for line in lines:
            if line.startswith("AUTH_CODE") or line == "\n":
                pass
            else:
                file.write(line)

        file.write(f"\nAUTH_CODE=\"{code}\"\n")

def process_query_params(query_params):
    if "code" in query_params and query_params["state"][0] == "h1h2h3h4h5":
        auth_code = query_params["code"][0]
        response = "<h1>Authorization successful</h1>"

    else:
        auth_code = "INVALID"
        response = "<h1>Authentication failed</h1>"
    
    save_auth_code(auth_code)
    return response.encode()

def start_server():
    global server
    class RequestHandler(BaseHTTPRequestHandler):
        def do_GET(self):
            query_components = parse_qs(urlparse(self.path).query)
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(process_query_params(query_components))
    server = HTTPServer(('127.0.0.1', 8888), RequestHandler)
    
    timeout_seconds = 5
    timer = Timer(timeout_seconds, server.shutdown)
    try:
        timer.start()
        server.serve_forever()
    finally:
        timer.cancel()

def authenticate():
    auth_url = get_auth_url()
    server_thread = threading.Thread(target=start_server)
    server_thread.start()
    if sys.platform in ["darwin", "linux", "win32"]:
        webbrowser.open(auth_url)
    else:
        print("No se pudo detectar el sistema operativo compatible.")
    server_thread.join()

authenticate()