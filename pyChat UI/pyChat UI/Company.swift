//
//  Company.swift
//  pyChat UI
//
//  Created by pedro on 9/23/24.
//

import SwiftUI

struct Contact: Hashable, Codable, Identifiable{
    let id: Int
    let company: Int
    let name: String
    let email: String
    let number: String
}

class ContactModel: ObservableObject{

    @Published var contacts: [Contact] = []
    
    func fetch(company_id: Int){
        guard let url = URL(string: "http://127.0.0.1:5555/contacts/\(company_id)") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data,
            _, error in
            guard let data = data, error == nil else {
                return
            }
            //convert JSON
            do{
                let contacts = try JSONDecoder().decode([Contact].self, from: data)
                DispatchQueue.main.async {
                    self?.contacts = contacts

//                    print("fetched contacts:\(contacts)")
                }
            }
            catch{
                print(error)
                
            }
        }
        task.resume()
    }
}

struct Company: View{
    
    @Environment(\.presentationMode) private var
    presentationMode: Binding<PresentationMode>
    
    let company_id: Int?
    let company: String?
    let alumniPassed: Bool?
    let postingsPassed: Bool?
    @ObservedObject private var contactModel = ContactModel()
    
    @State private var companyName: String = ""
    @State private var alumni: Bool? = nil
    @State private var postings: Bool? = nil
    
    var body: some View{
        VStack{
            if let company_id = company_id{
                Text(company!)
                    .onAppear{
                        contactModel.fetch(company_id: company_id)
                        alumni = alumniPassed // Initialize here if you are passing values
                        postings = postingsPassed
                    }
                
                Picker(selection: $alumni, label: Text("Alumni")) {
                    Text("Yes").tag(true)
                    Text("No").tag(false)
                }
                .pickerStyle(.radioGroup)
                .horizontalRadioGroupLayout()
                
                Picker(selection: $postings, label: Text("Postings")) {
                    Text("Yes").tag(true)
                    Text("No").tag(false)
                }
                .pickerStyle(.radioGroup)
                .horizontalRadioGroupLayout()
                
                Button(action: { updateLead(company_id) }) {
                    Text("update")
                }
                
                Text("Contacts")
                List(contactModel.contacts, id: \.self) {
                    contact in HStack(alignment: .center) {
                        Spacer()
                        Text(contact.name)
                            .padding(.leading, 40)
                        Text(contact.email)
                        Text(contact.number)
                        Spacer()
                        Button(action: { removeContact(contact.id) }) {
                            Image(systemName: "minus")
                        }
                    }
                }
                
                Button(action: { print("contact added") }) {
                    NavigationLink(destination: ContactForm(company_id: company_id)) {
                        Text("Add Contact")
                    }
                }
            } else {
                LabeledContent {
                    TextField("Enter new lead...", text: $companyName)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 350)
                } label: {
                    Text("Company")
                }
                
                Picker(selection: $alumni, label: Text("Alumni")) {
                    Text("Yes").tag(true)
                    Text("No").tag(false)
                }
                .pickerStyle(.radioGroup)
                .horizontalRadioGroupLayout()
                
                Picker(selection: $postings, label: Text("Postings")) {
                    Text("Yes").tag(true)
                    Text("No").tag(false)
                }
                .pickerStyle(.radioGroup)
                .horizontalRadioGroupLayout()
                
                Button(action: { addLead() }) {
                    Image(systemName: "plus")
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Back")
                })
            }
        })
    }
    
    // Functions moved outside the body closure
    func addLead() {
        guard let url = URL(string: "http://127.0.0.1:5555/leads") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["company": companyName, "alumni": alumni, "postings": postings]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                print("Server returned error")
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                print("No data received or invalid format")
                return
            }
            
            print(responseString)
        }
        task.resume()
    }
    
    func removeContact(_ id: Int) {
        guard let url = URL(string: "http://127.0.0.1:5555/contacts/\(id)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                print("Server returned error")
                return
            }
            
            print("Contact removed successfully")
        }
        task.resume()
    }
    
    func updateLead(_ id: Int) {
        guard let url = URL(string: "http://127.0.0.1:5555/leads/\(id)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["alumni": alumni, "postings": postings]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Server returned error")
                return
            }
            
            print("Lead updated successfully")
        }
        task.resume()
    }
}


struct Company_Preview: PreviewProvider {
    static var previews: some View {
        NavigationManagerView()
    }
}



