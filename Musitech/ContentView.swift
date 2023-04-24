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
    // .. extend with any custom here
}

extension Button {

    @ViewBuilder
    func myStyle(_ style: MyButtonStyle) -> some View {
        switch style {
            case .borderProminent:
                self.buttonStyle(BorderedProminentButtonStyle())
            case .bordered:
                self.buttonStyle(BorderedButtonStyle())
           // .. extend with any custom here
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
    @State var recArtists = [String]()
    @State var recSongs = [String]()
    @State var resp = ""
    @State var opacity = 0.6
    
//    private func reload(prompt: String, completion: @escaping (String) -> Void) {
//        self.sendQuestion = "Is the song " + title + " classical music? Give me a yes or no answer."
//        viewModel2.send(text: sendQuestion) { response in
//            self.resp = response
//        }
//    }
    
    var body: some View {
//        VStack(alignment: .leading) {
//            ForEach(models, id: \.self) { string in
//                Text(string)
//            }
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 10) {
//                Text(genre)
                Group {
                    HStack() {
                        Text(title)
                            .font(.title)
                            .fontWeight(.semibold)
                        Spacer()
                    }.frame(maxWidth: UIScreen.main.bounds.width - 60)
    //                Text(artist)
    //                Text(albumTitle)
                    HStack() {
                        Text(composer)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple.opacity(1))
                        Spacer()
                    }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                }
                Spacer()
                Group {
                    HStack() {
                        Text("About the Piece")
                            .font(.headline)
                        Spacer()
                        Button {
                            viewModel2.send(text: questionPieceDesc) { response in
                                self.pieceDescription = response
                            }
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
    //                            .resizable()
    //                            .frame(width: 30, height: 20)
                                .foregroundColor(.white)
                        }
                    }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                    HStack() {
                        Text(pieceDescription)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width - 60)
                            .background(Rectangle().fill(Color.purple.opacity(opacity)).shadow(radius: 3)
                                .cornerRadius(10))
                    }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                    
//                    Text(resp)
                    Spacer()
                    
                    if resp.lowercased().contains("yes") {
                        HStack() {
                            Text("Historical Context")
                                .font(.headline)
                            Spacer()
                            Button {
                                viewModel2.send(text: questionHist) { response in
                                    self.historicalContext = response
                                }
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
        //                            .resizable()
        //                            .frame(width: 30, height: 20)
                                    .foregroundColor(.white)
                            }
                        }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                        HStack() {
                            Text(historicalContext)
                                .multilineTextAlignment(.leading)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width - 60)
                                .background(Rectangle().fill(Color.purple.opacity(opacity)).shadow(radius: 3)
                                    .cornerRadius(10))
                        }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                        Spacer()
                    }
                    
                    HStack() {
                        Text("Sounds and Textures")
                        Spacer()
                        Button {
                            viewModel2.send(text: questionSound) { response in
                                self.sounds = response
                            }
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
    //                            .resizable()
    //                            .frame(width: 30, height: 20)
                                .foregroundColor(.white)
                        }
                    }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                    HStack() {
                        Text(sounds)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width - 60)
                            .background(Rectangle().fill(Color.purple.opacity(opacity)).shadow(radius: 3)
                                .cornerRadius(10))
                    }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                    Spacer()
                    
                    HStack() {
                        Text("Recommended " + (resp.lowercased().contains("yes") ? "Composers" : "Artists"))
                        Spacer()
                    }.frame(maxWidth: UIScreen.main.bounds.width - 60)
                    HStack(spacing: 30) {
                        ForEach(0..<recArtists.count, id: \.self) { i in
                                         Text(recArtists[i])
                                .frame(width: 300, height: 100, alignment: .center)
                                             .cornerRadius(10)
                                             .background(Rectangle().fill(Color.purple.opacity(opacity)).shadow(radius: 3)
                                                 .cornerRadius(10))
                                    }
                        Spacer()
                    }.modifier(ScrollingHStackModifier(items: recArtists.count, itemWidth: 300, itemSpacing: 30))
                }
                
            }.frame(maxWidth: UIScreen.main.bounds.width)
        }
        .onAppear {
            viewModel2.setup()
            self.title = viewModel1.shazamMedia.title ?? "Title"
            self.artist = viewModel1.shazamMedia.artistName ?? "Artist"
            self.subtitle = viewModel1.shazamMedia.subtitle ?? "Subtitle"
            self.genre = viewModel1.shazamMedia.genres[0]
            self.artwork = viewModel1.shazamMedia.albumArtURL ?? URL(string: "https://www.apple.com")!
            
            
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
            
            self.questionRecArtist = "Give me only the first and last name of a lesser known " + genre + (resp.lowercased().contains("yes") ? "composer" : "artist") + " you recommend based on " + composer + " with no extra words or symbols"
            viewModel2.send(text: questionRecArtist) { response in
                self.recArtists.append(response)
            }
            viewModel2.send(text: questionRecArtist) { response in
                self.recArtists.append(response)
            }
            viewModel2.send(text: questionRecArtist) { response in
                self.recArtists.append(response)
                
                
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
//                self.models.append("ChatGPT: "+response)
//                self.title = viewModel1.shazamMedia.title ?? "Title"
//                self.questionRecArtist = "Write me a haiku about " + title
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel2 = ViewModel()
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationStack {
//            ScrollView(.vertical, showsIndicators: true) {
//                VStack(spacing: 20) {
//                    Text("FredeRik ChOpIn")
////                        .fixedSize(horizontal: false, vertical: false)
////                        .multilineTextAlignment(.center)
//                        .padding()
////                        .frame(width: UIScreen.main.bounds.width - 30)
//                        .background(Rectangle().fill(Color.purple.opacity(1)).shadow(radius: 3)
//                            .cornerRadius(10))
//
//                    Text("Nocturnee?")
////                        .fixedSize(horizontal: false, vertical: false)
//                        .multilineTextAlignment(.leading)
//                        .padding()
//                        .frame(width: 300)
//                        .background(Rectangle().fill(Color.purple.opacity(1)).shadow(radius: 3)
//                            .cornerRadius(10))
//                    Text("About the piece")
//                    Text("very cool piece well done")
////                        .fixedSize(horizontal: false, vertical: false)
//                        .multilineTextAlignment(.leading)
//                        .padding()
//                        .frame(width: 300)
//                        .background(Rectangle().fill(Color.purple.opacity(1)).shadow(radius: 3)
//                            .cornerRadius(10))
//                    Text("about composer")
//                    Text("chopin sad guy cry")
////                        .fixedSize(horizontal: false, vertical: false)
//                        .multilineTextAlignment(.leading)
//                        .padding()
//                        .frame(width: 300)
//                        .background(Rectangle().fill(Color.purple.opacity(1)).shadow(radius: 3)
//                            .cornerRadius(10))
//                    Text("fun poem guy")
//                    Text("chopin does cry, nobody love why? ok just die")
////                        .fixedSize(horizontal: false, vertical: false)
//                        .multilineTextAlignment(.leading)
//                        .padding()
//                        .frame(width: UIScreen.main.bounds.width - 30)
//                        .background(Rectangle().fill(Color.purple.opacity(1)).shadow(radius: 3)
//                            .cornerRadius(10))
//
////                    ScrollView(.horizontal, showsIndicators: true) {
//                    Text("Recommended Artists")
//                    HStack( spacing: 30) {
//                        ForEach(0..<artists.count, id: \.self) { i in
//                                         Text(artists[i])
//                                .frame(width: 250, height: 100, alignment: .center)
//                                             .cornerRadius(10)
//                                             .background(Rectangle().fill(Color.purple.opacity(1)).shadow(radius: 3)
//                                                 .cornerRadius(10))
//                                    }
//                    }.modifier(ScrollingHStackModifier(items: artists.count, itemWidth: 250, itemSpacing: 30))
//
//            }.frame(maxWidth: UIScreen.main.bounds.width)
//            ZStack {
//                AsyncImage(url: viewModel.shazamMedia.albumArtURL) { image in
//                    image
//                        .resizable()
//                        .scaledToFill()
//                        .blur(radius: 10, opaque: true)
//                        . opacity(0.5)
//                        .edgesIgnoringSafeArea(.all)
//                } placeholder: {
//                    EmptyView()
//                }
                


                    
//                    AsyncImage(url: viewModel.shazamMedia.albumArtURL) { image in
//                        image
//                            .resizable()
//                            .frame(width: 300, height: 300)
//                            .aspectRatio(contentMode: .fit)
//                            .cornerRadius(10)
//                    } placeholder: {
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(Color.purple.opacity(0.5))
//                            .frame(width: 300, height: 300)
//                            .cornerRadius(10)
//                            .redacted(reason:  .privacy)
//                    }
//                    VStack(alignment: .center) {
//                        Text(viewModel.shazamMedia.title ?? "Title")
//                            .font(.title)
//                            .fontWeight(.semibold)
//                            .multilineTextAlignment(.center)
//                        Text(viewModel.shazamMedia.artistName ?? "Artist Name")
//                            .font(.title2)
//                            .fontWeight(.medium)
//                            .multilineTextAlignment(.center)
//                    }.padding()
                    Spacer()
                    Button(action: {viewModel.startOrEndListening()}) {
                        Text(viewModel.isRecording ? "Listening..." : "Start Recording")
                            .frame(width: 200, height: 100)
                            .font(.title)
                            .fontWeight(.semibold)
                            .fontWidth(.condensed)
//                            .foregroundStyle(.blue.gradient)
                    }
                    .myStyle(viewModel.isRecording ? .bordered : .borderProminent)
                        .controlSize(.large)
                    //                    .controlProminence(.increased)
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
