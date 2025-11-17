//
//  ContactForm.swift
//  pyChat UI
//
//  Created by pedro on 9/26/24.
//

import SwiftUI

struct ContactForm: View {
    //    @Environment(\.presentationMode) private var
    //    presentationMode: Binding<PresentationMode>
    
    @State private var nameForm: String = ""
    @State private var emailForm: String = ""
    @State private var numberForm: String = ""
    
    @ObservedObject var contactModel: ContactModel
    
    
    let company_id : Int
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        ZStack(alignment: .topLeading) { // ⬅️ alignment goes here
            
            Form {
                Section {
                    TextField("Name", text: $nameForm, prompt: Text("Required"))
                    TextField("Email", text: $emailForm)
                    TextField("Number", text: $numberForm)
                }
                if !nameForm.isEmpty { Section {
                    Button(action: {
                        addContact()
                        dismiss()
                    }) {
                        Image(systemName: ("plus.circle.fill"))
                    }
                }
            }
            }
            .frame(width: 400, height: 200)
            .padding()
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .font(.headline)
            }
        }
        .padding()
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
            guard let data = data else {
                print("No data received or invalid format")
                return
            }
            do {
                // decode the new contact returned from Flask
                let newContact = try JSONDecoder().decode(Contact.self, from: data)
                
                // update the UI immediately
                DispatchQueue.main.async {
                    contactModel.contacts.append(newContact)
                }
            }
            catch {
                    print("Decoding error: \(error)")
                }
            
        }
        //calls the task defined above
        task.resume()
    }
}

struct Contact_Preview: PreviewProvider {
    static var previews: some View {
        NavigationManagerView()
    }
}
