import webbrowser
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse
import os
from dotenv import load_dotenv
import time
import sys
import spotipy
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
auth_code = None

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
    global auth_code
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
    server.serve_forever()

def auth_code_undefined():
    global auth_code
    if auth_code == "INVALID" or auth_code is None:
        return True
    else:
        return False

def wait_for_authorization_code_to_change():
    global server
    while auth_code_undefined():
        time.sleep(1)
    server.shutdown()

def authenticate():
    if auth_code_undefined():
        auth_url = get_auth_url()
        server_thread = threading.Thread(target=start_server)
        auth_code_thread = threading.Thread(target=wait_for_authorization_code_to_change)
        server_thread.start()
        auth_code_thread.start()
        if sys.platform in ["darwin", "linux", "win32"]:
            webbrowser.open(auth_url)
        else:
            print("No se pudo detectar el sistema operativo compatible.")
        auth_code_thread.join()
        server_thread.join()


authenticate()