//
//  Email.swift
//  pyChat UI
//
//  Created by pedro on 10/29/24.
//

import SwiftUI

struct Email: View {
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var company: String = ""
    @State private var role: String = ""
    @State private var jd: String = ""
    @State private var selectedPurpose: String = ""
    @State private var responseMessage: String = ""
//    @State private var selected: Bool = false
    let purposes = ["HR", "Recruiter"]


    var body: some View{
        
        VStack{
            HStack{
                Text("Email")
                TextField("Enter email", text: $email)
            }
            HStack{
                Text("Name")
                TextField("Enter First Name", text: $name)

            }
            HStack{
                Text("Company")
                TextField("Enter Company this person works at", text: $company)

            }
            HStack{
                Text("Role")
                TextField("Enter Role", text: $role)

            }
            HStack{
                Text("JD")
                TextField("Enter Job Posting", text: $jd)

            }
            ForEach(purposes, id:\.self) { purpose in
                Button(action: {
                    selectedPurpose = purpose
                }) {
                    HStack{
                        Image(systemName : selectedPurpose == purpose ? "circle.fill" : "circle")
                        Text(purpose)
                    }
                }
            }
            if !email.isEmpty, !name.isEmpty, !company.isEmpty, !role.isEmpty, !jd.isEmpty, !selectedPurpose.isEmpty {
                Button(action: {
                    sendEmail()
                }){
                    Text("Send")
                }
                
            }
            
            if !responseMessage.isEmpty{
                Text(responseMessage)
            }


        }
        
    }
    func sendEmail(){

            //url of my api
            guard let url = URL(string: "http://127.0.0.1:5555/email") else {
                print("Invalid URL")
                return
            }
            
            //SWIFT UI for URL requesting
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        let parameters: [String: Any] = ["receiver":email,"name":name, "company": company,"link": jd,"purpose": selectedPurpose, "role":role]
            
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
                
    //            update state to UI
                    DispatchQueue.main.async {
                        responseMessage = responseString // Display response in the UI

                        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                            email = ""
                            name = ""
                            company = ""
                            role = ""
                            jd = ""
                            selectedPurpose = ""
                            responseMessage = ""
                        }
                
                }
            }
            //calls the task defined above
            task.resume()
        
    }
}


struct Email_Preview: PreviewProvider {
    static var previews: some View {
        NavigationManagerView()
    }
}
