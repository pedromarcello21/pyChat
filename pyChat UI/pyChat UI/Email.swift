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
            HStack{
                Text("Purpose")
                Button(action: {print("HR")}){
                    Text("HR")
                }
//                .background(Color.blue)

                
                Button(action: {print("Recruiter")}){
                    Text("Recruiter")

                }
            }
            

        }
        
    }
}


struct Email_Preview: PreviewProvider {
    static var previews: some View {
        NavigationManagerView()
    }
}
