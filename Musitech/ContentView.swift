//
//  ContentView.swift
//  Musitech
//
//  Created by Zhang, Alice on 3/6/23.
//

import OpenAISwift
import SwiftUI
import SnapToScroll

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

struct DetailView: View {
    @ObservedObject var viewModel2: ViewModel
    @ObservedObject var viewModel1: ContentViewModel
    @State var sendQuestion = "Write me a haiku about spring"
    @State var models = [String]()
    @State var title = "Title"
    @State var artist = "Artist"
    @State var composer = "Composer"
    @State var pieceDescription = ""
    @State var text = ""
    @State var recArtists = [String]()
    @State var recSongs = [String]()
    @State var resp = ""
    
    var body: some View {
//        VStack(alignment: .leading) {
//            ForEach(models, id: \.self) { string in
//                Text(string)
//            }
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 20) {
                Text(title)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Rectangle().fill(Color.purple.opacity(0.5)).shadow(radius: 3)
                        .cornerRadius(10))
                Text(artist)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Rectangle().fill(Color.purple.opacity(0.5)).shadow(radius: 3)
                        .cornerRadius(10))
                Text(composer)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Rectangle().fill(Color.purple.opacity(0.5)).shadow(radius: 3)
                        .cornerRadius(10))
                Text(pieceDescription)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Rectangle().fill(Color.purple.opacity(0.5)).shadow(radius: 3)
                        .cornerRadius(10))
                Text(resp)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(Rectangle().fill(Color.purple.opacity(0.5)).shadow(radius: 3)
                        .cornerRadius(10))
                Spacer()
                Text("Recommended Artists")
                HStack( spacing: 30) {
                    ForEach(0..<recArtists.count, id: \.self) { i in
                                     Text(recArtists[i])
                            .frame(width: 250, height: 100, alignment: .center)
                                         .cornerRadius(10)
                                         .background(Rectangle().fill(Color.purple.opacity(1)).shadow(radius: 3)
                                             .cornerRadius(10))
                                }
                }.modifier(ScrollingHStackModifier(items: recArtists.count, itemWidth: 250, itemSpacing: 30))
                Spacer()
            }.frame(maxWidth: UIScreen.main.bounds.width)
        }
        
//            HStack {
////                TextField("Type here...", text: $text)
//                Button("Send") {
//                    self.artist = viewModel1.shazamMedia.artistName ?? "Artist"
//                    self.sendQuestion = "Write me a haiku about " + artist
//                    send(text: sendQuestion)
////                    send(text: text)
////                }
//            }
//        }
        .onAppear {
            viewModel2.setup()
            self.title = viewModel1.shazamMedia.title ?? "Title"
            self.artist = viewModel1.shazamMedia.artistName ?? "Artist"
            self.sendQuestion = "Give me a brief description of the song " + title
            viewModel2.send(text: sendQuestion) { response in
                self.pieceDescription = response
            }
            self.sendQuestion = "Give me only the first and last name of the person who composed the song " + title + "with no extra words or letters."
            viewModel2.send(text: sendQuestion) { response in
                self.composer = response
            }
            self.sendQuestion = "Is the song " + title + " classical music? Give me a yes or no answer."
            viewModel2.send(text: sendQuestion) { response in
                self.resp = response
            }
            
            self.sendQuestion = "Give me only the first and last name of a non white male composer you recommend based on " + composer + "with no extra words or symbols"
            viewModel2.send(text: sendQuestion) { response in
                self.recArtists.append(response)
            }
            self.sendQuestion = "Give me only the first and last name of a non white male composer you recommend based on " + composer + "with no extra words or symbols"
            viewModel2.send(text: sendQuestion) { response in
                self.recArtists.append(response)
            }
            self.sendQuestion = "Give me only the first and last name of a non white male composer you recommend based on " + composer + "with no extra words or symbols"
            viewModel2.send(text: sendQuestion) { response in
                self.recArtists.append(response)
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
                self.models.append("ChatGPT: "+response)
                self.title = viewModel1.shazamMedia.title ?? "Title"
                self.sendQuestion = "Write me a haiku about " + title
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel2 = ViewModel()
    @StateObject private var viewModel = ContentViewModel()
    
    var artists: [String] = ["not white man 1", "v cool woman 2", "mozart"]

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
                            .frame(width: 300)
                    }.buttonStyle(.bordered)
                        .controlSize(.large)
                    //                    .controlProminence(.increased)
                        .shadow(radius: 4)
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
