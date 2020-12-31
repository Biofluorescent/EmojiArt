//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Tanner Quesenberry on 12/25/20.
//

import SwiftUI

//View Model
class EmojiArtDocument: ObservableObject {
    
    //To be shared by all documents, eventually array of palettes
    static let palette: String = "🎃🕵️‍♂️🧚‍♀️👑🎒🐒🐠🌻🔥🍔🍙🏀🏈🚗🛻🚒🚲"
    
    @Published private var emojiArt: EmojiArt = EmojiArt()
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    //MARK: - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageDate = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        //Protect against case where making multiple requests and last request is replaced by early request
                        if url == self.emojiArt.backgroundURL {
                            self.backgroundImage = UIImage(data: imageDate)
                        }
                    }
                }
            }
        }
    }
    
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y))}
}
