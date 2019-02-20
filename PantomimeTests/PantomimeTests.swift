//
//  PantomimeTests.swift
//  PantomimeTests
//
//  Created by Thomas Christensen on 24/08/16.
//  Copyright © 2016 Nordija A/S. All rights reserved.
//

import XCTest
@testable import Pantomime

class PantomimeTests: XCTestCase {

    func testFullParse() {
        let builder = ManifestBuilder()
        if let url = URL(string: "https://willzhanmswest.streaming.mediaservices.windows.net/e7c76dbb-8e38-44b3-be8c-5c78890c4bb4/MicrosoftElite01.ism/manifest(format=m3u8-aapl,audio-only=false)") {

            let manifest = builder.parse(url)
            print(manifest.getKeys())
            XCTAssertEqual(1, manifest.keys.count, "Number of keys in content does not match")
        }
        
        if let url = URL(string: "https://cd-stream-live.telenorcdn.net/cdgo/cd_tsat_viasport1_hd_live/cd_tsat_viasport1_hd_live.isml/playlist.m3u8") {
            
            let manifest = builder.parse(url)
            print(manifest.getKeys())
            XCTAssertEqual(1, manifest.keys.count, "Number of keys in content does not match")
        }
        
    }

    
}
