import SwiftUI

struct ContentView: View {
    @State private var textInput: String = ""
    @State private var responseMessage: String = ""
    
    var body: some View {
        VStack {
            TextField("Enter something...", text: $textInput)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                submitForm()
            }) {
                Text("Submit")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Text(responseMessage)
                .padding()
        }
        .padding()
    }
    
    func submitForm() {
        guard let url = URL(string: "http://127.0.0.1:5555/prompt") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = ["prompt": textInput]
        
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

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            guard httpResponse.statusCode == 200 else {
                print("Server returned status code \(httpResponse.statusCode)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            // Handle plain text response
            if let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    responseMessage = responseString
                }
                print("Response Data: \(responseString)")
            } else {
                print("Response data is not in expected format")
            }
        }

        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



