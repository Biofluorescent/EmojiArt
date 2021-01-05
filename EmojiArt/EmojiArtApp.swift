//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Tanner Quesenberry on 12/25/20.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let store = EmojiArtDocumentStore(named: "Emoji Art")
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentChooser().environmentObject(store)
        }
    }
}
