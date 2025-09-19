import spotipy
from spotipy.oauth2 import SpotifyClientCredentials

# Replace with your Spotify API credentials
CLIENT_ID = "YOUR_CLIENT_ID"
CLIENT_SECRET = "YOUR_CLIENT_SECRET"

# Authenticate with Spotify (Client Credentials flow)
auth_manager = SpotifyClientCredentials(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
sp = spotipy.Spotify(auth_manager=auth_manager)

def track_name_to_uri(track_name: str):
    results = sp.search(q=track_name, type="track", limit=1)
    tracks = results.get("tracks", {}).get("items", [])
    
    if tracks:
        track = tracks[0]
        return track["uri"], track["name"], track["artists"][0]["name"]
    else:
        return None

# Example usage
uri_info = track_name_to_uri("Blinding Lights The Weeknd")
if uri_info:
    uri, name, artist = uri_info
    print(f"Track: {name} by {artist}")
    print(f"URI: {uri}")
else:
    print("Track not found.")
