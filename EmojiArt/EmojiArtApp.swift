//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Tanner Quesenberry on 12/25/20.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: EmojiArtDocument())
        }
    }
}
