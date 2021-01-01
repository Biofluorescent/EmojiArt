//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Tanner Quesenberry on 12/31/20.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        //Group returns a view, does not otherwise modify view
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
