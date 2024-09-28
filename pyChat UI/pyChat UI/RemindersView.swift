//
//  RemindersView.swift
//  pyChat UI
//
//  Created by pedro on 9/23/24.
//
import SwiftUI

struct ReminderContact: Hashable, Codable {
    let id: Int
    let name: String
    let email: String
    let number: String
    let company: Int
}

struct Reminder: Hashable, Codable, Identifiable{
    let id: Int
    let contact: ReminderContact
    let alert: String
    let note: String
}


class ReminderModel: ObservableObject{
    @Published var reminders: [Reminder] = []
    
    func fetch(){
        guard let url = URL(string: "http://127.0.0.1:5555/upcoming-reminders") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data,
            _, error in
            guard let data = data, error == nil else {
                return
            }
            //convert JSON
            do{
                let reminders = try JSONDecoder().decode([Reminder].self, from: data)
                DispatchQueue.main.async {
                    self?.reminders = reminders
                }
            }
            catch{
                print(error)
                
            }
        }
        task.resume()
    }
}

struct Reminders: View {
    @StateObject var reminderModel = ReminderModel()
    
    var body: some View{
        VStack{
            Text("Reminders")
            NavigationLink(destination: ReminderForm()){
                Image(systemName: "plus")
            }
            List(reminderModel.reminders) { reminder in
                HStack {
                    Spacer()
                    Text(reminder.contact.name)
                    Text(reminder.alert)
                    Text(reminder.note)
                    Spacer()
                }
            }
        }
        .onAppear {
            reminderModel.fetch()
        }
        }
}

struct Reminders_Preview: PreviewProvider {
    static var previews: some View {
        NavigationManagerView()
    }
}
