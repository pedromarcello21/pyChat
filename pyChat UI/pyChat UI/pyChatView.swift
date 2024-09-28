//
//  pyChatView.swift
//  pyChat UI
//
//  Created by pedro on 9/23/24.
//
import SwiftUI

struct pyChat: View {
    ///set states
    @State private var textInput: String = ""
    @State private var responseMessage: String? = nil
    ///chat history captures message content and if it was sent my user or pychat
    @State private var chatHistory: [(message: String, isUser: Bool)] = []

    var body: some View {
        //start of VStack
            VStack {
            //title font
            Text("pyChat")
                .font(.title)
            //create scrolling window for chat history
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    //chat history can be captured in Vstack
                    VStack {
                        //ForEach loop through chat messages that are appended every post request
                        ForEach(chatHistory.indices, id: \.self) { index in
                            HStack {
                                if chatHistory[index].isUser {
                                    //push to right
                                    Spacer()
                                    Text(chatHistory[index].message)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                        .frame(alignment: .trailing)
                                        .padding(.trailing, 20)
                                } else {
                                    //HStack to capture copy button
                                    HStack{
                                        if chatHistory[index].message.hasPrefix("https://images"){
                                            //adjust accordingly when time to present
                                            AsyncImage(url: URL(string: chatHistory[index].message))
                                            { image in image
                                                    .resizable()
                                                    .scaledToFit()
                                            } placeholder:{
                                                ProgressView()
                                            }
                                            .frame(maxWidth:300, maxHeight:200, alignment:.leading)
                                            .cornerRadius(8)
                                            
                                        } else{
                                            Text(chatHistory[index].message)
                                                .padding()
                                                .background(Color(hue: 0.0, saturation: 0.0, brightness: 0.327))
                                                .cornerRadius(8)
                                                .frame(maxWidth: 300, alignment:.leading)
                                        }
                                        //syntax for copying
                                        Button(action: {
                                            let pasteboard = NSPasteboard.general
                                            pasteboard.clearContents()
                                            pasteboard.setString(chatHistory[index].message, forType: .string)
                                        }){
                                            //copy button is rendered as followinng icon
                                            Image(systemName: "doc.on.doc.fill")
                                            
                                        }
                                        //for no background colr/border
                                        .buttonStyle(PlainButtonStyle())
                                        //push to left
                                        //                                        .padding(.leading, 20)
                                        Spacer()
                                        
                                        
                                    }
                                }
                            }
                        }
                    }
                    //scroll to bottom when latest message is received or sent
                    .onChange(of: chatHistory.count) { _ in
                        withAnimation {
                            scrollViewProxy.scrollTo(chatHistory.count - 1, anchor: .bottom)
                        }
                    }
                }
                //set frame height of chat history
                .frame(maxHeight: 500)
            }
            
            Spacer()
            
            // Input Field
            HStack {
                TextField("Enter task...", text: $textInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width:350)
                //functionality to press enter instead of clicking
                    .onSubmit{
                        sendPrompt()
                        //reset field to blank
                        textInput = ""
                        
                    }
                Button(action: {
                    //call on function defined below
                    sendPrompt()
                    //reset field to blank
                    textInput = ""
                }) {
                    Image(systemName:"paperplane.fill")
                        .padding()
                        .imageScale(/*@START_MENU_TOKEN@*/.large/*@END_MENU_TOKEN@*/)
                }
                .background(Color.blue)
                .cornerRadius(8)
                
            }
            //            .padding()
        }
        .padding()
        .frame(width:700)
    }
    
    func sendPrompt() {
        //url of my api
        guard let url = URL(string: "http://127.0.0.1:5555/prompt") else {
            print("Invalid URL")
            return
        }
        
        //SWIFT UI for URL requesting
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["prompt": textInput]
        
        //convert to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            //add prompt to chat history
            chatHistory.append((message: textInput, isUser: true))
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        //make post request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            //looks for status code 200 for check
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Server returned error")
                return
            }
           
            //get return value from pychat
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                print("No data received or invalid format")
                return
            }
            
            //update state to UI
            DispatchQueue.main.async {
                responseMessage = responseString
                chatHistory.append((message: responseString, isUser: false))
            }
        }
        //calls the task defined above
        task.resume()
    }
}
