import json
import spotipy
from spotipy.oauth2 import SpotifyOAuth

# Replace with your Spotify API credentials
# Replace with your Spotify API credentials
CLIENT_ID = "28cb945996d04097b8b516575cc6322a"
CLIENT_SECRET = "210fcc76945a427982a0e08a0deacff0"
REDIRECT_URI = "http://localhost:8888/callback"

# Define required scope for reading playlists
SCOPE = "playlist-read-private playlist-read-collaborative"

# Authenticate using OAuth (user login)
sp = spotipy.Spotify(auth_manager=SpotifyOAuth(
    client_id=CLIENT_ID,
    client_secret=CLIENT_SECRET,
    redirect_uri=REDIRECT_URI,
    scope=SCOPE
))

def export_playlist_to_json(playlist_url: str, output_file: str):
    """Fetch playlist tracks and export as JSON with title + interpret"""
    # Extract playlist ID from URL
    playlist_id = playlist_url.split("/")[-1].split("?")[0]

    results = sp.playlist_items(playlist_id, additional_types=["track"])
    songs = []

    while results:
        for item in results["items"]:
            track = item.get("track")
            if track:  # sometimes playlists can contain empty items
                title = track["name"]
                artists = ", ".join([artist["name"] for artist in track["artists"]])
                songs.append({"title": title, "interpret": artists})

        # Pagination (fetch next page if available)
        if results["next"]:
            results = sp.next(results)
        else:
            results = None

    # Save to JSON
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(songs, f, indent=2, ensure_ascii=False)

    print(f"✅ Exported {len(songs)} songs to {output_file}")


# Example usage
if __name__ == "__main__":
    playlist_link = "https://open.spotify.com/playlist/1y8GwyganCtgF0XqsCHkaw"
    export_playlist_to_json(playlist_link, "songs.json")
