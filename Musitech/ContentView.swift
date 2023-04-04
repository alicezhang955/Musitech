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
                break
            }
        })
    }
}

struct DetailView: View {
    @ObservedObject var viewModel1: ContentViewModel
    @ObservedObject var viewModel2 = ViewModel()
    @State var text = ""
    @State var models = [String]()
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(models, id: \.self) { string in
                Text(string)
            }
            Spacer()
            
            HStack {
                TextField("Type here...", text: $text)
                Button("Send") {
                    send()
                }
            }
        }
        .onAppear {
            viewModel2.setup()
        }
        .padding()
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
    
    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        models.append("Me: \(text)")
        viewModel2.send(text: text) { response in
            DispatchQueue.main.async {
                self.models.append("ChatGPT: "+response)
                self.text = ""
            }
        }
    }
}

struct ContentView: View {
//    @StateObject private var viewModel = ContentViewModel()
//
//    var body: some View {
//        NavigationStack {
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
//
//                VStack(alignment: .center) {
//                    Button(action: {viewModel.startOrEndListening()}) {
//                        Text(viewModel.isRecording ? "Listening..." : "Start Shazaming")
//                            .frame(width: 300)
//                    }.buttonStyle(.bordered)
//                        .controlSize(.large)
//                    //                    .controlProminence(.increased)
//                        .shadow(radius: 4)
//                    Spacer()
////                    VStack {
////                        NavigationLink("Show Detail View") {
////                            DetailView()
////                        }
////                    }
////                    .navigationTitle("Navigation")
////                    NavigationLink(destination:x
////                       DetailView(),
////                       isActive: $viewModel.endListening) {
////                         EmptyView()
////                    }.hidden()
//                        .navigationDestination(
//                             isPresented: $viewModel.endListening) {
//                                  DetailView(viewModel1: viewModel)
//                                 EmptyView()
//                             }
//                }
            
//            }
//        }
    @ObservedObject var viewModel2 = ViewModel()
    @State var text = "Write me a haiku about spring"
    @State var models = [String]()
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(models, id: \.self) { string in
                Text(string)
            }
            Spacer()
            
            HStack {
                Button("Send") {
                    send()
                }
            }
        }
        .onAppear {
            viewModel2.setup()
        }
        .padding()
    }

func send() {
    guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
        return
    }
    
    models.append("Me: \(text)")
    viewModel2.send(text: text) { response in
        DispatchQueue.main.async {
            self.models.append("ChatGPT: "+response)
            self.text = "Write me a haiku about winter"
        }
    }
}
    
    
    
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
}
