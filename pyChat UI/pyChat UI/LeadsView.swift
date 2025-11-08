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
    let alumni: Bool
    let postings: Bool
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
    
    var body: some View{
        NavigationStack(path: $stackPath){
            ScrollView{
                VStack(spacing: 20){
                    ForEach(viewModel.leads, id: \.self){
                        lead in NavigationLink(destination: Company(company_id: nil, company: nil, alumniPassed:nil, postingsPassed: nil)){
                            Text(lead.company)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetch()
            }
        }
    }
////    @State private var textInput: String = ""
//    var body: some View{
//        VStack{
//            HStack{
//                Text("Leads")
//                NavigationLink(destination: Company(company_id: nil, company: nil, alumniPassed:nil, postingsPassed: nil)){
//                    Image(systemName: "plus")
//                }
//            }
//            .padding(.horizontal)
//            HStack(spacing: 20){
//                Text("Company")
//                    .frame(width:100, alignment: .center)
//                Text("Postings")
//                    .frame(width:100, alignment: .center)
//                Text("Alumni")
//                    .frame(width:100, alignment: .center)
//            }
//            .padding(.horizontal)
//            
//            List{
//                ForEach(viewModel.leads, id :\.self) {
//                    lead in
//                    HStack(spacing: 20){
//                        Spacer(minLength: 20)
//                        NavigationLink(destination: Company(company_id : lead.id, company : lead.company, alumniPassed:lead.alumni, postingsPassed:lead.postings))
//                        
//                        {
//                        Text(lead.company)
//                            .frame(width:100, alignment: .center)
//                            .padding(.leading, 40)
//
//                        }
//                        
//                        Image(systemName: lead.postings ? "flag.fill" : "xmark")
//                            .frame(width:100, alignment: .center)
//                        
//                        Image(systemName: lead.alumni ? "flag.fill" : "xmark")
//                            .frame(width:100, alignment: .center)
//                        Spacer()
//                        Button(action: {
//                            print(lead.id)
//                            removeLead(lead.id)
//                        }) {Image(systemName: "minus")}
//                        
//                    }
//                    .padding(.horizontal)
//                }
//            }
//        }
//        .onAppear{
//            viewModel.fetch()
//        }
//    }
    
    
    
    /////////////////////////////////////
        
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



