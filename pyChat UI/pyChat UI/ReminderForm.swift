import SwiftUI

struct ContactSearch: Hashable, Codable, Identifiable {
    let id: Int
    let company: Int
    let name: String
    let email: String
    let number: String
}

class ContactSearchModel: ObservableObject {
    @Published var contacts: [ContactSearch] = []
    
    func fetch() {
        guard let url = URL(string: "http://127.0.0.1:5555/contacts") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            // Convert JSON
            do {
                let contacts = try JSONDecoder().decode([ContactSearch].self, from: data)
                DispatchQueue.main.async {
                    self?.contacts = contacts
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct ReminderForm: View {
    
    @Environment(\.presentationMode) private var
    presentationMode: Binding<PresentationMode>
    
    @ObservedObject private var contactModel = ContactSearchModel()
    @State private var searchText: String = ""
    @State private var selectedContact: ContactSearch?
    @State private var selectedDate: Date = Date() // Default to current date
    @State private var reminderNote: String = ""



    
    // Filtered contacts based on the search text
    var filteredContacts: [ContactSearch] {
        if searchText.isEmpty {
            return []
        } else {
            return contactModel.contacts.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack {
            Text("Add Reminders")
                .font(.largeTitle)
            
            // Search Bar
            TextField("Search Contacts", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onTapGesture {
                    // Reset selection when tapping the search bar
                    selectedContact = nil
                }
            
            // Display filtered contacts
            if selectedContact == nil{
                if !filteredContacts.isEmpty { List(filteredContacts) { contact in
                    HStack {
                        Text(contact.name)
                            .foregroundColor(.gray)
                            .onTapGesture {
                                // Update the selected contact when tapped
                                selectedContact = contact
                                searchText = contact.name // Keep the selected name in the field
                            }
                        
                        
                    }
                }
                    
                .frame(maxHeight: 200) // Limit the height of the list
                    
                }
            }
            DatePicker("Select Date and Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(StepperFieldDatePickerStyle())
 // You can choose different styles
            TextField("Reminder Context", text: $reminderNote)
            Button(action:
//                    {print(selectedContact!.id, selectedDate, reminderNote)}
                   {
                       addReminder()
                   }
            )
            {
                Text("add reminder")
            }
        }
        .onAppear {
            contactModel.fetch() // Fetch contacts when the view appears
        }
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
        .padding()
    }
    func addReminder() {
        // URL of your API
        guard let url = URL(string: "http://127.0.0.1:5555/reminders") else {
            print("Invalid URL")
            return
        }
        
        // Create URLRequest for making the POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert the selected date to the required format (YYYY-MM-DD)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let formattedDate = dateFormatter.string(from: selectedDate)

        // Prepare parameters for the JSON payload
        let parameters: [String: Any] = [
            "contact_id": selectedContact!.id,
            "alert": formattedDate, // Use the formatted date here
            "note": reminderNote
        ]
        
        // Convert parameters to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }
        
        // Make the POST request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // Check for a successful response status code
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                print("Server returned error: \(response.debugDescription)")
                return
            }
            
            // Get the response data
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                print("No data received or invalid format")
                return
            }
            
            print("Response: \(responseString)") // Print response for debugging
        }
        task.resume() // Execute the task
    }

}


struct ReminderForm_Preview: PreviewProvider {
    static var previews: some View {
        NavigationManagerView()
    }
}
