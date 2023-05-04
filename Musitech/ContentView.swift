//
//  ContentView.swift
//  Musitech
//
//  Created by Zhang, Alice on 3/6/23.
//

import OpenAISwift
import SwiftUI
import SnapToScroll
import Foundation


struct ScrollingHStackModifier: ViewModifier {
    
    @State private var scrollOffset: CGFloat
    @State private var dragOffset: CGFloat
    
    var items: Int
    var itemWidth: CGFloat
    var itemSpacing: CGFloat
    
    init(items: Int, itemWidth: CGFloat, itemSpacing: CGFloat) {
        self.items = items
        self.itemWidth = itemWidth
        self.itemSpacing = itemSpacing
        
        // Calculate Total Content Width
        let contentWidth: CGFloat = CGFloat(items) * itemWidth + CGFloat(items - 1) * itemSpacing
        let screenWidth = UIScreen.main.bounds.width
        
        // Set Initial Offset to first Item
        let initialOffset = (contentWidth/2.0) - (screenWidth/2.0) + ((screenWidth - itemWidth) / 2.0)
        
        self._scrollOffset = State(initialValue: initialOffset)
        self._dragOffset = State(initialValue: 0)
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: scrollOffset + dragOffset, y: 0)
            .gesture(DragGesture()
                .onChanged({ event in
                    dragOffset = event.translation.width
                })
                .onEnded({ event in
                    // Scroll to where user dragged
                    scrollOffset += event.translation.width
                    dragOffset = 0
                    
                    // Now calculate which item to snap to
                    let contentWidth: CGFloat = CGFloat(items) * itemWidth + CGFloat(items - 1) * itemSpacing
                    let screenWidth = UIScreen.main.bounds.width
                    
                    // Center position of current offset
                    let center = scrollOffset + (screenWidth / 2.0) + (contentWidth / 2.0)
                    
                    // Calculate which item we are closest to using the defined size
                    var index = (center - (screenWidth / 2.0)) / (itemWidth + itemSpacing)
                    
                    // Should we stay at current index or are we closer to the next item...
                    if index.remainder(dividingBy: 1) > 0.5 {
                        index += 1
                    } else {
                        index = CGFloat(Int(index))
                    }
                    
                    // Protect from scrolling out of bounds
                    index = min(index, CGFloat(items) - 1)
                    index = max(index, 0)
                    
                    // Set final offset (snapping to item)
                    let newOffset = index * itemWidth + (index - 1) * itemSpacing - (contentWidth / 2.0) + (screenWidth / 2.0) - ((screenWidth - itemWidth) / 2.0) + itemSpacing
                    
                    // Animate snapping
                    withAnimation {
                        scrollOffset = newOffset
                    }
                    
                })
            )
    }
}

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: "")
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text,
                               maxTokens: 500,
                               completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices?.first?.text ?? ""
                completion(output.replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression))
            case .failure:
                print("gpt failed")
                break
            }
        })
    }
}

enum MyButtonStyle {
    case borderProminent
    case bordered
}

extension Button {

    @ViewBuilder
    func myStyle(_ style: MyButtonStyle) -> some View {
        switch style {
            case .borderProminent:
                self.buttonStyle(BorderedProminentButtonStyle())
            case .bordered:
                self.buttonStyle(BorderedButtonStyle())
        }
    }
}


struct DetailView: View {
    @ObservedObject var viewModel2: ViewModel
    @ObservedObject var viewModel1: ContentViewModel
    @State var questionComposer = ""
    @State var questionPieceDesc = ""
    @State var questionSound = ""
    @State var questionRecArtist = ""
    @State var questionRecDesc1 = ""
    @State var questionRecDesc2 = ""
    @State var questionRecDesc3 = ""
    @State var questionResp = ""
    @State var questionAlbum = ""
    @State var questionHist = ""
    @State var models = [String]()
    @State var title = "Title"
    @State var artist = "Artist"
    @State var composer = ""
    @State var subtitle = "Subtitle"
    @State var genre = "Genre"
    @State var sounds = ""
    @State var historicalContext = ""
    @State var artwork = URL(string: "https://www.apple.com")
    @State var albumTitle = "Album"
    @State var pieceDescription = ""
    @State var text = ""
    @State var resp = ""
    @State var opacity = 0.6
    @State var artist1 = ""
    @State var artist2 = ""
    @State var artist3 = ""
    @State var desc1 = ""
    @State var desc2 = ""
    @State var desc3 = ""

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 10) {
                Group {
                    Text(title)
                        .font(.title)
                        .fontWeight(.semibold)
                        .frame(width: UIScreen.main.bounds.width - 60, alignment: .leading)
                    Spacer()
                        Text(composer)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple.opacity(1))
                            .frame(width: UIScreen.main.bounds.width - 60, alignment: .leading)
                        Spacer()
                }
                Spacer()
                Group {
                    HStack() {
                        Text("About the Piece")
                            .font(.headline)
                        Spacer()
                        Button {
                            sleep(2)
                            viewModel2.send(text: questionPieceDesc) { response in
                                self.pieceDescription = response
                            }
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.white)
                        }
                    }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                    Text(pieceDescription)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width - 60, alignment: .leading)
                        .background(Rectangle().fill(Color.purple.opacity(opacity)).shadow(radius: 3)
                            .cornerRadius(10))
                    Spacer()

                    HStack() {
                        Text("Sounds and Textures")
                            .font(.headline)
                        Spacer()
                        Button {
                            viewModel2.send(text: questionSound) { response in
                                self.sounds = response
                            }
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.white)
                        }
                    }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                    Text(sounds)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width - 60, alignment: .leading)
                        .background(Rectangle().fill(Color.purple.opacity(opacity)).shadow(radius: 3)
                            .cornerRadius(10))
                    Spacer()

                    if resp.lowercased().contains("yes") {
                        HStack() {
                            Text("Historical Context")
                                .font(.headline)
                            Spacer()
                            Button {
                                sleep(2)
                                viewModel2.send(text: questionHist) { response in
                                    self.historicalContext = response
                                }
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(.white)
                            }
                        }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                        Text(historicalContext)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width - 60, alignment: .leading)
                            .background(Rectangle().fill(Color.purple.opacity(opacity)).shadow(radius: 3)
                                .cornerRadius(10))
                        Spacer()
                    }

                    HStack() {
                        Text("Recommended " + (resp.lowercased().contains("yes") ? "Composers" : "Artists"))
                            .font(.headline)
                        Spacer()
                    }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                    HStack(spacing: 30) {
                        VStack(spacing: 10) {
                            Text(artist1)
                                .padding()
                                .frame(width: 300, height: 40, alignment: .center)
                                .background(Rectangle().fill(Color.purple.opacity(opacity)).shadow(radius: 3)
                                    .cornerRadius(10))
                            Text(desc1)
                                .padding()
                                .frame(width: 300, height: 250)
                                             .cornerRadius(10)
                                             .background(Rectangle().fill(Color.purple.opacity(opacity - 0.3)).shadow(radius: 3)
                                                .cornerRadius(10))
                        }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                        VStack(spacing: 10) {
                            Text(artist2)
                                .padding()
                                .frame(width: 300, height: 40, alignment: .center)
                                .background(Rectangle().fill(Color.purple.opacity(opacity)).shadow(radius: 3)
                                    .cornerRadius(10))
                            Text(desc2)
                                .padding()
                                .frame(width: 300, height: 250)
                                             .cornerRadius(10)
                                             .background(Rectangle().fill(Color.purple.opacity(opacity - 0.3)).shadow(radius: 3)
                                                 .cornerRadius(10))
                        }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                        VStack(spacing: 10) {
                            Text(artist3)
                                .padding()
                                .frame(width: 300, height: 40, alignment: .center)
                                .cornerRadius(10)
                                .background(Rectangle().fill(Color.purple.opacity(opacity)).shadow(radius: 3)
                                    .cornerRadius(10))
                            Text(desc3)
                                .padding()
                                .frame(width: 300, height: 250)
                                 .cornerRadius(10)
                                 .background(Rectangle().fill(Color.purple.opacity(opacity - 0.3)).shadow(radius: 3)
                                     .cornerRadius(10))
                        }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                    }.modifier(ScrollingHStackModifier(items: 3, itemWidth: 300, itemSpacing: 30))
                }

            }.frame(maxWidth: UIScreen.main.bounds.width)
        }
        .onAppear {
            viewModel2.setup()
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1

            queue.addOperation {
                self.title = viewModel1.shazamMedia.title ?? "Title"
                self.artist = viewModel1.shazamMedia.artistName ?? "Artist"
                self.subtitle = viewModel1.shazamMedia.subtitle ?? "Subtitle"
                self.genre = viewModel1.shazamMedia.genres[0]
                self.artwork = viewModel1.shazamMedia.albumArtURL ?? URL(string: "https://www.apple.com")!
            }

            queue.addOperation {
                self.questionResp = "Is the song " + title + " classical music? Give me a yes or no answer."
                viewModel2.send(text: questionResp) { response in
                    self.resp = response
                }
                self.questionAlbum = "What is the album title that contains the song " + title + " by " + artist + "and has album art url " + (artwork?.absoluteString ?? "google.com") + "? Return me the name of the album title only with no extra words or symbols"
                viewModel2.send(text: questionAlbum) { response in
                    self.albumTitle = response
                }
                self.questionComposer = "give me the composer of the piece " + title + ", played by " + artist + ". give me the name only with no extra words or symbols"
                viewModel2.send(text: questionComposer) { response in
                    self.composer = (resp.lowercased().contains("yes") ? response : artist)
                }
            }

            queue.addOperation {
                while composer == "" {}
                self.questionRecArtist = "Give me only the name of a lesser known " + genre + " music " + (resp.lowercased().contains("yes") ? "historical composer" : "artist") + " you recommend based on " + composer + ". This person must be a music artist. Do not write any extra words, symbols, or lines"

                viewModel2.send(text: questionRecArtist) { response in
                    self.artist1 = response
                }
                viewModel2.send(text: questionRecArtist) { response in
                    self.artist2 = response
                }
                viewModel2.send(text: questionRecArtist) { response in
                    self.artist3 = response
                }
            }

            queue.addOperation {
                while artist1 == "" || artist2 == "" || artist3 == ""  {}
                self.questionRecDesc1 = "Give me a two sentence description of the musical artist " + artist1 + " with no extra lines or symbols"
                self.questionRecDesc2 = "Give me a two sentence description of the musical artist " + artist2 + " with no extra lines or symbols"
                self.questionRecDesc3 = "Give me a two sentence description of the musical artist " + artist3 + " with no extra lines or symbols"

                viewModel2.send(text: questionRecDesc1) { response in
                    self.desc1 = response
                }
                viewModel2.send(text: questionRecDesc2) { response in
                    self.desc2 = response
                }
                viewModel2.send(text: questionRecDesc3) { response in
                    self.desc3 = response
                }
            }


            queue.addOperation {
                while composer == "" {}
                self.questionPieceDesc = "Give me a single paragraph brief description of the song " + title + " by " + composer + " with no extra lines"
                viewModel2.send(text: questionPieceDesc) { response in
                    self.pieceDescription = response
                    }

                self.questionHist = "Tell me about the historical context of the song " + title + " by " + composer + ". Focus on historical context. Do not describe the piece or the composer. Do not include the title of the piece in your description. Do this in one paragraph with no new lines"
                viewModel2.send(text: questionHist) { response in
                    self.historicalContext = response
                    }

                self.questionSound = "Describe the sounds and textures you can hear in " + title + " by " + composer + ". Write a single snippet with no extra lines. Do not include the title or name of the composer."
                viewModel2.send(text: questionSound) { response in
                    self.sounds = response
                    }
            }

            queue.waitUntilAllOperationsAreFinished()

        }
        .padding()
    }

    func send(text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        models.append("Me: \(text)")
        viewModel2.send(text: text) { response in
            DispatchQueue.main.async {
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel2 = ViewModel()
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationStack {
                    Spacer()
                    Button(action: {viewModel.startOrEndListening()}) {
                        Text(viewModel.isRecording ? "Listening..." : "Start Recording")
                            .frame(width: 200, height: 100)
                            .font(.title)
                            .fontWeight(.semibold)
                            .fontWidth(.condensed)
                    }
                    .myStyle(viewModel.isRecording ? .bordered : .borderProminent)
                        .controlSize(.large)
                        .shadow(radius: 4)
                        .buttonBorderShape(.capsule)
                        .tint(.purple.opacity(0.7))
                    Spacer()
                        .navigationDestination(
                             isPresented: $viewModel.endListening) {
                                 DetailView(viewModel2: viewModel2, viewModel1: viewModel)
                                 EmptyView()
                             }
        }

}
    
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
}
