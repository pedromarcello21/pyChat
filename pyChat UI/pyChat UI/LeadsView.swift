//
//  LeadsView.swift
//  pyChat UI
//
//  Created by pedro on 9/23/24.
//

import SwiftUI

struct Lead: Hashable, Codable, Identifiable{
    let id: Int
    let company: String
    var alumni: Bool
    var postings: Bool
}


class LeadModel: ObservableObject{
    @Published var leads: [Lead] = []
    
    func fetch(){
        guard let url = URL(string: "http://127.0.0.1:5555/leads") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data,
            _, error in
            guard let data = data, error == nil else {
                return
            }
            //convert JSON
            do{
                let leads = try JSONDecoder().decode([Lead].self, from: data)
                DispatchQueue.main.async {
                    self?.leads = leads
                }
            }
            catch{
                print(error)
                
            }
        }
        task.resume()
    }
}

struct Leads: View {
    
    @StateObject var viewModel = LeadModel()
    @State private var stackPath: [String] = []
    @State private var isHovering = false

    
    var body: some View{
        NavigationStack(path: $stackPath){
                VStack{
                    HStack {
                        Text("Company")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Job postings")
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("Alumni")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: 400)
                    
                    List{
                        ForEach(viewModel.leads, id: \.self){
                        lead in NavigationLink(
                            destination: Company(
                                company_id: lead.id,
                                company: lead.company,
                                alumniPassed: lead.alumni,
                                postingsPassed: lead.postings,
                                leadModel: viewModel)
                        )
                        {
                        HStack {
                            Text(lead.company)
                                .frame(width:120, alignment: .leading)
                            
                            Image(systemName: lead.postings ? "flag.fill" : "xmark")
                                .frame(width:120, alignment: .center)
                            
                            Image(systemName: lead.alumni ? "flag.fill" : "xmark")
                                .frame(width:120, alignment: .trailing)
                        }

                        .padding(.vertical, 8)
                        .frame(width: 420)
                        .cornerRadius(8)

                        
                        }
                        
                        .swipeActions(
                            edge: .trailing,
                            allowsFullSwipe: true
                        ){
                            Button("Delete"){
                                removeLead(lead.id)
                            }
                            .tint(.red)
                        }

                    }

                }

                .frame(width: 450)
                .listStyle(.plain)
//                .onHover { hovering in
//                        isHovering = hovering
//                    }
            }
        }
        .onAppear {
            viewModel.fetch()
        }
    }
    
        
        func removeLead(_ id: Int) {
            //url of my api
            guard let url = URL(string: "http://127.0.0.1:5555/leads/\(id)") else {
                print("Invalid URL")
                return
            }
            
            //SWIFT UI for URL requesting
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let parameters: [String: Any] = ["id": id]
            
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
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                    print("Server returned error")
                    return
                }
                
                //get return value from pychat
                guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                    print("No data received or invalid format")
                    return
                }
                
                DispatchQueue.main.async {
                    viewModel.fetch()
                }
            }
            //calls the task defined above
            task.resume()
        }
    }

struct Leads_Preview: PreviewProvider {
    static var previews: some View {
        NavigationManagerView()
    }
}



