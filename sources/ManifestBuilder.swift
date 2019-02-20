//
// Created by Thomas Christensen on 25/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

/**
* Parses HTTP Live Streaming manifest files
* Use a BufferedReader to let the parser read from various sources.
*/
open class ManifestBuilder {

    public init() {}

    /**
    * Parses Master playlist manifests
    */
    fileprivate func parseMasterPlaylist(_ lines: [String], onMediaPlaylist:
            ((_ playlist: MediaPlaylist) -> Void)?) -> MasterPlaylist {
        let masterPlaylist = MasterPlaylist()
        var currentMediaPlaylist: MediaPlaylist?

        lines.forEach { line in
            if line.isEmpty {
                // Skip empty lines

            } else if line.hasPrefix("#EXT") {

                // Tags
                if line.hasPrefix("#EXTM3U") {
                    // Ok Do nothing

                } else if line.hasPrefix("#EXT-X-STREAM-INF") {
                    // #EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=200000
                    currentMediaPlaylist = MediaPlaylist()
                    do {
                        let programIdString = try line.replace("(.*)=(\\d+),(.*)", replacement: "$2")
                        let bandwidthString = try line.replace("(.*),(.*)=(\\d+)(.*)", replacement: "$3")
                        if let currentMediaPlaylistExist = currentMediaPlaylist {
                            currentMediaPlaylistExist.programId = Int(programIdString)!
                            currentMediaPlaylistExist.bandwidth = Int(bandwidthString)!
                        }
                    } catch {
                        print("Failed to parse program-id and bandwidth on master playlist. Line = \(line)")
                    }

                }
            } else if line.hasPrefix("#") {
                // Comments are ignored

            } else {
                // URI - must be
                if let currentMediaPlaylistExist = currentMediaPlaylist {
                    currentMediaPlaylistExist.path = line
                    currentMediaPlaylistExist.masterPlaylist = masterPlaylist
                    masterPlaylist.addPlaylist(currentMediaPlaylistExist)
                    if let callableOnMediaPlaylist = onMediaPlaylist {
                        callableOnMediaPlaylist(currentMediaPlaylistExist)
                    }
                }
            }
        }

        return masterPlaylist
    }

    /**
    * Parses Media Playlist manifests
    */
    fileprivate func parseMediaPlaylist(_ lines: [String],
                                        mediaPlaylist: MediaPlaylist = MediaPlaylist()) -> MediaPlaylist {
        
        lines.forEach { line in
            if line.hasPrefix("#EXT-X-KEY") {
                do {
                    let keyUrl = try line.replace("(.*)URI=[\"](.*?)[\"]+(.*)", replacement: "$2")
                    mediaPlaylist.getMaster()?.addKey(keyUrl)
                } catch {
                    print("Failed to parse the version of media playlist. Line = \(line)")
                }
            }
        }

        return mediaPlaylist
    }

   

    /**
    * Parses the master playlist manifest requested synchronous from a URL
    *
    * Convenience method that uses a URLBufferedReader as source for the manifest.
    */
    open func parseMasterPlaylistFromURL(_ url: URL, onMediaPlaylist:
                ((_ playlist: MediaPlaylist) -> Void)? = nil) -> MasterPlaylist {
        let masterManifestAsString = try! String(contentsOf: url)
        return parseMasterPlaylist(masterManifestAsString.components(separatedBy: .newlines), onMediaPlaylist: onMediaPlaylist)
    }

    

    /**
    * Parses the media playlist manifest requested synchronous from a URL
    *
    * Convenience method that uses a URLBufferedReader as source for the manifest.
    */
    @discardableResult
    open func parseMediaPlaylistFromURL(_ url: URL,
                                        mediaPlaylist: MediaPlaylist = MediaPlaylist()) -> MediaPlaylist {
        let mediaManifestAsString = try! String(contentsOf: url)
        
        return parseMediaPlaylist(mediaManifestAsString.components(separatedBy: .newlines),
                mediaPlaylist: mediaPlaylist)
    }

    /**
    * Parses the master manifest found at the URL and all the referenced media playlist manifests recursively.
    */
    open func parse(_ url: URL,
                    onMediaPlaylist: ((_ playlist: MediaPlaylist) -> Void)? = nil) -> MasterPlaylist {
        // Parse master
        let master = parseMasterPlaylistFromURL(url, onMediaPlaylist: onMediaPlaylist)
        for playlist in master.playlists {
            if let path = playlist.path {

                // Detect if manifests are referred to with protocol
                if path.hasPrefix("http") || path.hasPrefix("file") || path.hasPrefix("https") {
                    // Full path used
                    if let mediaURL = URL(string: path) {
                        parseMediaPlaylistFromURL(mediaURL,
                                mediaPlaylist: playlist)
                    }
                } else {
                    // Relative path used
                    if let mediaURL = url.URLByReplacingLastPathComponent(path) {
                        parseMediaPlaylistFromURL(mediaURL,
                                mediaPlaylist: playlist)
                    }
                }
            }
        }
        return master
    }
}
