//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

open class MediaPlaylist {
    var masterPlaylist: MasterPlaylist?

    open var programId: Int = 0
    open var bandwidth: Int = 0
    open var path: String?
    open var version: Int?
    open var keyUrl: String?
    open var targetDuration: Int?
    open var mediaSequence: Int?
    
    public init() {

    }

    open func getMaster() -> MasterPlaylist? {
        return self.masterPlaylist
    }
}
