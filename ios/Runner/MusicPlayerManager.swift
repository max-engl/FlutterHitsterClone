import Foundation
import MusicKit

@MainActor
final class MusicPlayerManager: ObservableObject {

    static let shared = MusicPlayerManager()

    private let player = ApplicationMusicPlayer.shared

    @Published var nowPlayingSong: Song?
    @Published var playbackStatus: MusicPlayer.PlaybackStatus = .stopped

    private init() {
        pollPlayerState()
    }

    // MARK: - Authorization
    func requestAuthorization() async throws {
        let status = await MusicAuthorization.request()
        guard status == .authorized else {
            throw NSError(domain: "MusicAuth", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "User denied Apple Music access"])
        }
    }

    // MARK: - Resolve playable Apple Music Catalog Song
    private func getPlayableSongByISRC(_ isrc: String) async throws -> Song? {
        let req = MusicCatalogResourceRequest<Song>(matching: \.isrc, equalTo: isrc)
        let res = try await req.response()
        return res.items.first
    }

    private func getPlayableSongBySearch(title: String, artist: String) async throws -> Song? {
        let query = "\(title) \(artist)"
        let req = MusicCatalogSearchRequest(term: query, types: [Song.self])
        let res = try await req.response()
        return res.songs.first
    }

    func getPlayableId(title: String, artist: String) async throws -> String? {
        if let s = try await getPlayableSongBySearch(title: title, artist: artist) {
            return s.id.rawValue
        }
        return nil
    }
func playSong(withID id: MusicItemID) async throws {

    var song: Song?

    let raw = id.rawValue

    // 0. Detect ISRC (12 chars, letters+numbers)
    let isISRC = raw.count == 12 && raw.range(of: #"^[A-Z0-9]{12}$"#, options: .regularExpression) != nil

    if isISRC {
        // lookup by ISRC
        if let s = try await getPlayableSongByISRC(raw) {
            song = s
        }
    }

    // 1. Catalog ID (starts with "s." or number-based IDs)
    if song == nil && !raw.starts(with: "i.") && !isISRC {
        let req = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: id)
        let res = try await req.response()
        song = res.items.first
    }

    // 2. Library ID fallback
    if song == nil && raw.starts(with: "i.") {
        var libReq = MusicLibraryRequest<Song>()
        libReq.limit = 5000
        let libRes = try await libReq.response()

        if let librarySong = libRes.items.first(where: { $0.id == id }) {

            // If library has ISRC
            if let isrc = librarySong.isrc, !isrc.isEmpty,
                let s = try await getPlayableSongByISRC(isrc) {
                song = s
            }

            // Fallback search
            if song == nil {
                song = try await getPlayableSongBySearch(
                    title: librarySong.title,
                    artist: librarySong.artistName
                )
            }
        }
    }

    guard let song else {
        throw NSError(
            domain: "MusicPlayer",
            code: 2,
            userInfo: [NSLocalizedDescriptionKey: "Song not found (catalog/library/isrc)"]
        )
    }

    try await player.queue = [song]
    try await player.play()

    nowPlayingSong = song
    updateNowPlayingInfo()
}


    // MARK: - Playback (Metadata)
    func playSongByMetadata(title: String, artist: String) async throws {
        guard let song = try await getPlayableSongBySearch(title: title, artist: artist) else {
            throw NSError(domain: "MusicPlayer", code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Song not found in Apple Music"])
        }

        try await player.queue = [song]
        try await player.play()
        nowPlayingSong = song
    }

    // MARK: - Controls
    func pause() async {
        player.pause()
        updateNowPlayingInfo()
    }

    func resume() async {
        try? await player.play()
        updateNowPlayingInfo()
    }

    func skipToNext() async {
        try? await player.skipToNextEntry()
        updateNowPlayingInfo()
    }

    func skipToPrevious() async {
        try? await player.skipToPreviousEntry()
        updateNowPlayingInfo()
    }

    // MARK: - Fetch Playlists
    func getUserPlaylists() async throws -> [[String: Any]] {
        let req = MusicLibraryRequest<Playlist>()
        let res = try await req.response()
        return res.items.map { p in
            [
                "id": p.id.rawValue,
                "name": p.name,
                "description": p.description ?? ""
            ]
        }
    }

    // MARK: - Fetch Songs
    func getUserSongs() async throws -> [[String: Any]] {
        let req = MusicLibraryRequest<Song>()
        let res = try await req.response()
        return res.items.map { s in
            [
                "id": s.id.rawValue,
                "title": s.title,
                "artist": s.artistName,
                "album": s.albumTitle ?? "",
                "imageUrl": s.artwork?.url(width: 200, height: 200)?.absoluteString ?? "",
                "isrc": s.isrc ?? ""
            ]
        }
    }

    // MARK: - Fetch Playlist Songs
    func getPlaylistSongs(id: String) async throws -> [[String: Any]] {
        let playlistID = MusicItemID(rawValue: id)

        // Library playlist
        var libReq = MusicLibraryRequest<Playlist>()
        libReq.filter(matching: \.id, equalTo: playlistID)
        let libRes = try await libReq.response()

        if let pl = libRes.items.first {
            let detailed = try await pl.with([.tracks])
            let tracks = detailed.tracks ?? []
            return tracks.compactMap { t in
                if case let .song(s) = t {
                    return [
                        "id": s.id.rawValue,
                        "title": s.title,
                        "artist": s.artistName,
                        "album": s.albumTitle ?? "",
                        "imageUrl": s.artwork?.url(width: 200, height: 200)?.absoluteString ?? "",
                        "isrc": s.isrc ?? ""
                    ]
                }
                return nil
            }
        }

        // Catalog playlist
        var catReq = MusicCatalogResourceRequest<Playlist>(matching: \.id, equalTo: playlistID)
        catReq.properties = [.tracks]
        let catRes = try await catReq.response()

        guard let pl = catRes.items.first else { return [] }

        return (pl.tracks ?? []).compactMap { t in
            if case let .song(s) = t {
                return [
                    "id": s.id.rawValue,
                    "title": s.title,
                    "artist": s.artistName,
                    "album": s.albumTitle ?? "",
                    "imageUrl": s.artwork?.url(width: 200, height: 200)?.absoluteString ?? "",
                    "isrc": s.isrc ?? ""
                ]
            }
            return nil
        }
    }

    // MARK: - Search Catalog Playlists  (FIX added back!)
    func searchCatalogPlaylists(term: String) async throws -> [[String: Any]] {
        let req = MusicCatalogSearchRequest(term: term, types: [Playlist.self])
        let res = try await req.response()

        return res.playlists.map { p in
            [
                "id": p.id.rawValue,
                "name": p.name,
                "imageUrl": p.artwork?.url(width: 200, height: 200)?.absoluteString ?? ""
            ]
        }
    }

    // MARK: - Polling
    private func pollPlayerState() {
        Task.detached { [weak self] in
            guard let self else { return }
            while true {
                await MainActor.run {
                    let state = self.player.state.playbackStatus
                    if state != self.playbackStatus {
                        self.playbackStatus = state
                        self.updateNowPlayingInfo()
                    }
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    private func updateNowPlayingInfo() {
        if let s = player.queue.currentEntry?.item as? Song {
            nowPlayingSong = s
            print("Now playing: \(s.title) – \(s.artistName)")
        } else {
            nowPlayingSong = nil
        }
    }
}
