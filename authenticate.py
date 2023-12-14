from threading import Thread
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse
import os
from dotenv import load_dotenv
import sys
from spotipy.oauth2 import SpotifyOAuth

load_dotenv()  # Loading .env file

callback_uri = os.getenv("TDL_CALLBACK_URI")
client_id = os.getenv("TDL_SPOTIFY_CLIENT_ID")
client_secret = os.getenv("TDL_SPOTIFY_CLIENT_SECRET")
stop_server = False

class RequestHandler(BaseHTTPRequestHandler):
        def do_GET(self):
            query_components = parse_qs(urlparse(self.path).query)
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(process_query_params(query_components))

def get_auth_url():
    scopes = "user-read-recently-played user-top-read playlist-modify-public"
    sp_oauth = SpotifyOAuth(client_id, client_secret, callback_uri, scope=scopes, show_dialog=True)
    return sp_oauth.get_authorize_url()

def save_auth_code(code):
    with open('.env', 'r') as file:
        lines = file.readlines()

    with open('.env', 'w') as file:
        for line in lines:
            if line.startswith("AUTH_CODE") or line == "\n":
                pass
            else:
                file.write(line)

        file.write(f"AUTH_CODE=\"{code}\"\n")

def process_query_params(query_params):
    if "code" in query_params:
        save_auth_code(query_params["code"][0])
        response = "<h1>Authorization successful</h1>"

    else:
        save_auth_code("INVALID")
        response = "<h1>Authentication failed</h1>"
    
    global stop_server
    stop_server = True
    
    return response.encode()

def start_server(server):
    server.serve_forever()

def authenticate():
    auth_url = get_auth_url()
    if sys.platform in ["darwin", "linux", "win32"]:
        webbrowser.open(auth_url)
    else:
        print(f"Authenticate URL:\n{auth_url}")
    
    server = HTTPServer(('127.0.0.1', 8888), RequestHandler)
    server_thread = Thread(target= lambda:start_server(server))
    server_thread.start()
    
    global stop_server
    while not stop_server:
        pass

    server.shutdown()

authenticate()