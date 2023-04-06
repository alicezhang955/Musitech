//
//  ContentView.swift
//  Musitech
//
//  Created by Zhang, Alice on 3/6/23.
//

import OpenAISwift
import SwiftUI

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: "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")
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text,
                               maxTokens: 500,
                               completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices?.first?.text ?? ""
                completion(output)
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
    
    var body: some View {
        VStack(alignment: .leading) {
//            ForEach(models, id: \.self) { string in
//                Text(string)
//            }
            Text(title)
            Text(artist)
            Text(composer)
            Text(pieceDescription)
            Spacer()
            
            HStack {
                Button("Send") {
                    self.artist = viewModel1.shazamMedia.artistName ?? "Artist"
                    self.sendQuestion = "Write me a haiku about " + artist
                    send(text: sendQuestion)
                }
            }
        }
        .onAppear {
            viewModel2.setup()
            self.title = viewModel1.shazamMedia.title ?? "Title"
            self.artist = viewModel1.shazamMedia.artistName ?? "Artist"
//            self.sendQuestion = "Write me a haiku about " + title
//            send(text: sendQuestion)
//            self.sendQuestion = "Give me the name of the person who composed " + title
//            send(text: sendQuestion)
//            self.sendQuestion = "Give me a brief description of " + title
//            send(text: sendQuestion)
            self.sendQuestion = "Give me a brief description of " + title
            viewModel2.send(text: sendQuestion) { response in
                self.pieceDescription = response
            }
            self.sendQuestion = "Give me the name of the person who composed " + title
            viewModel2.send(text: sendQuestion) { response in
                self.composer = response
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
    
//    func storeResponse(text: String, completion: @escaping (String) -> Void) {
//        viewModel2.send(text: text) { response in
//            DispatchQueue.main.async {
//                return response
//            }
//        }
//    }
        
//    @ObservedObject var viewModel1: ContentViewModel
//    @ObservedObject var viewModel2 = ViewModel()
//    @State var text = ""
//    @State var models = [String]()
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            ForEach(models, id: \.self) { string in
//                Text(string)
//            }
//            Spacer()
//
//            HStack {
//                TextField("Type here...", text: $text)
//                Button("Send") {
//                    send()
//                }
//            }
//        }
//        .onAppear {
//            viewModel2.setup()
//        }
//        .padding()
//        Text("This is the detail view")
//        Spacer()
        
//        AsyncImage(url: viewModel.shazamMedia.albumArtURL) { image in
//            image
//                .resizable()
//                .frame(width: 300, height: 300)
//                .aspectRatio(contentMode: .fit)
//                .cornerRadius(10)
//        } placeholder: {
//            RoundedRectangle(cornerRadius: 10)
//                .fill(Color.purple.opacity(0.5))
//                .frame(width: 300, height: 300)
//                .cornerRadius(10)
//                .redacted(reason:  .privacy)
//        }
//        VStack(alignment: .center) {
//            Text(viewModel.shazamMedia.title ?? "Title")
//                .font(.title)
//                .fontWeight(.semibold)
//                .multilineTextAlignment(.center)
//            Text(viewModel.shazamMedia.artistName ?? "Artist Name")
//                .font(.title2)
//                .fontWeight(.medium)
//                .multilineTextAlignment(.center)
//        }.padding()
//        Spacer()

}

struct ContentView: View {
    @ObservedObject var viewModel2 = ViewModel()
//    @ObservedObject var viewModel1 = ContentViewModel()
//    @State var sendQuestion = "Write me a haiku about spring"
//    @State var models = [String]()
//    @State var title = "Title"
//    @State var artist = "Artist"
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            ForEach(models, id: \.self) { string in
//                Text(string)
//            }
//            Spacer()
//
//            HStack {
//                Button("Send") {
//                    self.artist = viewModel1.shazamMedia.artistName ?? "Artist"
//                    self.sendQuestion = "Write me a haiku about " + artist
//                    send(text: sendQuestion)
//                }
//            }
//        }
//        .onAppear {
//            viewModel2.setup()
//            self.title = viewModel1.shazamMedia.title ?? "Title"
//            self.sendQuestion = "Write me a haiku about " + title
//            send(text: sendQuestion)
//        }
//        .padding()
//    }
//
//    func send(text: String) {
//    guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
//        return
//    }
//
//    models.append("Me: \(text)")
//    viewModel2.send(text: text) { response in
//        DispatchQueue.main.async {
//            self.models.append("ChatGPT: "+response)
//            self.title = viewModel1.shazamMedia.title ?? "Title"
//            self.sendQuestion = "Write me a haiku about " + title
//        }
//    }
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AsyncImage(url: viewModel.shazamMedia.albumArtURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 10, opaque: true)
                        . opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                } placeholder: {
                    EmptyView()
                }

                VStack(alignment: .center) {
                    Button(action: {viewModel.startOrEndListening()}) {
                        Text(viewModel.isRecording ? "Listening..." : "Start Shazaming")
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
        }

}
    
    
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
}
