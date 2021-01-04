//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Tanner Quesenberry on 12/25/20.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @State private var chosenPalette: String = ""
    
    init(document: EmojiArtDocument) {
        self.document = document
        _chosenPalette = State(wrappedValue: self.document.defaultPalette)
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                                    // \ means Keypath to specify var on another object
                        ForEach(chosenPalette.map { String($0)}, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: self.defaultEmojiSize))
                                .onDrag { return NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
            }
        }

        .padding(.horizontal)
        
        GeometryReader { geometry in
            ZStack {
                //Using overlay instead of ZStack has to do with sizing behaviour of Rectangle and images
                Color.white.overlay(
                    OptionalImage(uiImage: self.document.backgroundImage)
                        .scaleEffect(self.zoomScale)
                        .offset(self.panOffset)
                )
                .gesture(self.doubleTapToZoom(in: geometry.size))
                if self.isLoading {
                    Image(systemName: "timer").imageScale(.large)
                } else {
                    ForEach(self.document.emojis) { emoji in
                        Text(emoji.text)
                            .font(animatableWithSize: emoji.fontSize * self.zoomScale)
                            .position(self.position(for: emoji, in: geometry.size))
                    }
                }
            }
            .clipped()
            .gesture(self.panGesture())
            .gesture(self.zoomGesture())
            .edgesIgnoringSafeArea([.horizontal, .bottom])
            .onReceive(self.document.$backgroundImage) { image in
                self.zoomToFit(image, in: geometry.size)
            }
            .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                var location = geometry.convert(location, from: .global)
                location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                return self.drop(providers: providers, at: location)
            }
            
        }
    }
    
    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    //MARK: - Gestures
    
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            // $ creates a binding
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { (finalGestureScale) in
                self.steadyStateZoomScale = finalGestureScale
            }
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGesture, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGesture.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2).onEnded {
            withAnimation {
                self.zoomToFit(self.document.backgroundImage, in: size)
            }
        }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.steadyStatePanOffset = .zero
            self.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { (url) in
            self.document.backgroundURL = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
