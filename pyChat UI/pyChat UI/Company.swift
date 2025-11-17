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
    
    
    
    let company_id: Int
    let company: String?
    let alumniPassed: Bool?
    let postingsPassed: Bool?
    
    @StateObject var contactModel = ContactModel()
    @ObservedObject var leadModel: LeadModel
    
    @State private var companyName: String = ""
    @State private var alumni: Bool = false
    @State private var postings: Bool = false
    @State var showSheet: Bool = false
    
    
    var body: some View{
        VStack{
//            if let company_id = company_id{
            Text(company!)
                .padding()
                .font(.largeTitle)
                .onAppear{
                        contactModel.fetch(company_id: company_id)
                        alumni = alumniPassed ?? false //initialize here if you are passing values
                        postings = postingsPassed ?? false
                    }

                
                Toggle(isOn: $alumni) {
                    Text("Alumni?")
                }
                

                .toggleStyle(SwitchToggleStyle(tint: Color.green))
                .onChange(of: alumni) {newValue in
                    if newValue != alumniPassed {
                        updateLead(company_id)
                    }
                }
                
                Toggle(isOn: $postings) {
                    Text("Postings?")
                }
                .onChange(of: postings) {newValue in
                    if newValue != postingsPassed {
                        updateLead(company_id)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: Color.green))

                
            List{
                Section(header: HStack{
                    Text("Contacts")
                    Image(systemName: "person.fill")
                }
                .frame(maxWidth: .infinity, alignment: .center)){
                    ForEach(contactModel.contacts, id: \.self){
                        contact in HStack {
                            Text(contact.name).frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(contact.email).frame(maxWidth: .infinity, alignment: .center)
                            Text(contact.number).frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .swipeActions(
                            edge: .trailing,
                            allowsFullSwipe: true
                        ){
                            Button("Delete"){
                                removeContact(contact.id)
                            }
                            .tint(.red)
                        }
                    }
                    
                }
            }
            .padding()
            .frame(maxWidth:500)
            
            
            Button(action: {
                showSheet.toggle()
            }, label: {
                Text("Add Contact").padding()
            }).padding(.bottom)
            .sheet(isPresented: $showSheet, content: {
                ContactForm(contactModel: contactModel, company_id: company_id)
            })
        }
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
            
            //have to pass company_id in bc you are in a dependent view
            DispatchQueue.main.async {
                contactModel.fetch(company_id: company_id)
            }
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
        
        // Immediately update local model for reactive UI
        //searches through that array to find the index of the lead whose id matches the one just updated
        if let index = leadModel.leads.firstIndex(where: { $0.id == id }) {
            leadModel.leads[index].alumni = alumni
            leadModel.leads[index].postings = postings
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



