import UIKit
import Flutter
import MusicKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    var flutterChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any ]?
    ) -> Bool {

        let controller = window?.rootViewController as! FlutterViewController
        flutterChannel = FlutterMethodChannel(
            name: "music_kit_channel",
            binaryMessenger: controller.binaryMessenger
        )

        flutterChannel?.setMethodCallHandler { call, result in
            Task {
                do {
                    switch call.method {

                    case "authorize":
                        try await MusicPlayerManager.shared.requestAuthorization()
                        result("authorized")

                    case "playSong":
                        guard let args = call.arguments as? [String: Any],
                              let id = args["id"] as? String else {
                            result(FlutterError(code: "BAD_ARGS", message: "Missing ID", details: nil))
                            return
                        }
                        try await MusicPlayerManager.shared.playSong(
                            withID: MusicItemID(rawValue: id)
                        )
                        result("playing")

                    case "playSongByMetadata":
                        guard let args = call.arguments as? [String: Any],
                              let title = args["title"] as? String,
                              let artist = args["artist"] as? String else {
                            result(FlutterError(code: "BAD_ARGS", message: "Missing metadata", details: nil))
                            return
                        }
                        try await MusicPlayerManager.shared.playSongByMetadata(title: title, artist: artist)
                        result("playing")

                    case "getPlayableId":
                        guard let args = call.arguments as? [String: Any],
                              let title = args["title"] as? String,
                              let artist = args["artist"] as? String else {
                            result(FlutterError(code: "BAD_ARGS", message: "Missing metadata", details: nil))
                            return
                        }
                        let id = try await MusicPlayerManager.shared.getPlayableId(title: title, artist: artist)
                        result(id)

                    case "pause":
                        await MusicPlayerManager.shared.pause()
                        result("paused")

                    case "resume":
                        await MusicPlayerManager.shared.resume()
                        result("resumed")

                    case "next":
                        await MusicPlayerManager.shared.skipToNext()
                        result("next")

                    case "previous":
                        await MusicPlayerManager.shared.skipToPrevious()
                        result("previous")

                    case "getUserPlaylists":
                        result(try await MusicPlayerManager.shared.getUserPlaylists())

                    case "getUserSongs":
                        result(try await MusicPlayerManager.shared.getUserSongs())

                    case "getPlaylistSongs":
                        guard let args = call.arguments as? [String: Any],
                              let playlistID = args["id"] as? String else {
                            result(FlutterError(code: "BAD_ARGS", message: "Missing playlist ID", details: nil))
                            return
                        }
                        result(
                            try await MusicPlayerManager.shared.getPlaylistSongs(id: playlistID)
                        )

                    case "searchCatalogPlaylists":
                        guard let args = call.arguments as? [String: Any],
                              let term = args["term"] as? String else {
                            result(FlutterError(code: "BAD_ARGS", message: "Missing term", details: nil))
                            return
                        }
                        result(
                            try await MusicPlayerManager.shared.searchCatalogPlaylists(term: term)
                        )

                    default:
                        result(FlutterMethodNotImplemented)
                    }

                } catch {
                    result(FlutterError(code: "MUSICKIT_ERROR",
                                        message: error.localizedDescription,
                                        details: nil))
                }
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
