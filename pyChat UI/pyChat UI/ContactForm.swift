//
//  ContactForm.swift
//  pyChat UI
//
//  Created by pedro on 9/26/24.
//

import SwiftUI

struct ContactForm: View {
    @Environment(\.presentationMode) private var
    presentationMode: Binding<PresentationMode>
    
    @State private var nameForm: String = ""
    @State private var emailForm: String = ""
    @State private var numberForm: String = ""
    
    let company_id : Int
    
    var body: some View {
        
        LabeledContent{
            TextField("", text: $nameForm)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width:350)
        } label: {Text("Name")}
        LabeledContent{
            TextField("", text: $emailForm)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width:350)
        } label: {Text("Email")}
        LabeledContent{
            TextField("", text: $numberForm)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width:350)
        } label: {Text("Number")}
        Button(action:{
            print("contact added")
            //                       print(company_id!)
            addContact()
        })
        {
            Image(systemName:"plus")
                .padding()
                .imageScale(.medium)
        }
        .background(Color.blue)
        .toolbar(content: {
            ToolbarItem (placement: .automatic){
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Back")
                }
                )
            }
        })
    }
    func addContact() {
        //url of my api
        guard let url = URL(string: "http://127.0.0.1:5555/contacts") else {
            print("Invalid URL")
            return
        }
        
        //SWIFT UI for URL requesting
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["company_id":company_id,"name": nameForm, "email":emailForm, "number":numberForm]
        
        //convert to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            //add prompt to chat history
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
            //        DispatchQueue.main.async {
            //            responseMessage = responseString
            //
            //        }
        }
        //calls the task defined above
        task.resume()
    }
}
