import SwiftUI

//define result struct in the JSON response
struct Result: Hashable, Codable {
    var name: String
    var url: String
}

//define the response of the PokeAPI call
struct Response: Hashable, Codable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [Result]
}

//defie pokemon struct
struct Pokemon: Hashable, Codable, Identifiable{
    var id: Int
    var name: String
    var image: String
    
}

struct Pokecenter: View {
    //initialize state of API response
    @State private var response = Response(count: 0, next: nil, previous: nil, results: [])
    //initialize search text
    @State private var searchText: String = ""
    //initialize state of selected pokemon.  ? allows for initial nil value
    @State private var selectedPokemon: Result?
    
    //define list of dictionaries of type Pokemon
    @State private var team: [Pokemon] = []
    
    //define column space for pokemon output
    let columns = [
        GridItem(.flexible()), // 1st column
        GridItem(.flexible()), // 2nd column
        GridItem(.flexible())  // 3rd column
    ]

    var body: some View {
        VStack {
            Text("Pokémon Center")
                .font(.largeTitle)
                .padding()

            //search Bar
            TextField("Search Pokémon", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            //display filtered Pokémon based on search.  show dropdown only if no pokemon is selected
                //if search bar populated
            ZStack{
                ScrollView{
                    VStack{
                        if !team.isEmpty {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(team) { pokemon in
                                    VStack{
                                        Text(pokemon.name.capitalized)
                                            .font(.title2)

                                         AsyncImage(url: URL(string: pokemon.image)) { image in
                                             image
                                                 .resizable()
                                                 .scaledToFit()
                                                 .cornerRadius(8)
                                                 .padding(10)
                                                 .background(Color.white)
                                                 .frame(width: 80, height: 80)
                                         } placeholder: {
                                             ProgressView()
                                         }
                                    }.frame(maxWidth: .infinity)// Ensures even spacing in the column
                                }
                            }
                         }
                    }
                }
                    if !searchText.isEmpty {
                        VStack {
                            List(filteredPokemon, id: \.name) { result in
                                HStack {
                                    Text(result.name.capitalized)
                                        .foregroundColor(.gray)
                                        .onTapGesture {
                                            // Update the selected Pokémon when tapped
    //                                        selectedPokemon = result
                                            searchText = result.name.capitalized

                                            let startSkip = "https://pokeapi.co/api/v2/pokemon/".count
                                            // Remove trailing slash if it exists
                                            let trimmedURL = result.url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                                            let startIndex = trimmedURL.index(trimmedURL.startIndex, offsetBy: startSkip)
                                            let substring = trimmedURL[startIndex...] // Extract the substring from startSkip to the end
                                            let pokemonImage = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-ii/crystal/\(substring).png"
                                            if team.count < 6 { team.append(Pokemon(id: team.count, name: searchText, image:pokemonImage))
                                            }
                                            searchText = ""
//                                            print(team)


                                        }
                                }
                            }
                            .frame(maxHeight: 200)
                            .listStyle(PlainListStyle())
                        }
                    }
                }
            if team.count == 6{
                Button(action: {
                    print("Analyzing Team...")
                    analyzeTeam()
                }){
                    //copy button is rendered as followinng icon
                    Text("Analyze Team")
                    
                }
            }
         }
        .onAppear(perform: getPokemon) // Fetch Pokémon when the view appears
        
    }

    //filtered pokemon based on the search text
    var filteredPokemon: [Result] {
        response.results.filter {
            //shorthand for each result in list of Result objects
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    //function for API call to fetch pokemon.  more or less boilerplate from youtube videos I seen
    func getPokemon() {
        let urlString = "https://pokeapi.co/api/v2/pokemon?limit=151&offset=0"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching Pokémon: \(error)") // Log any errors
                    return
                }
                
                // Log the HTTP response status code
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Response Status Code: \(httpResponse.statusCode)")
                }
                
                guard let data = data else {
                    print("No data returned.")
                    return
                }

                do {
                    //sauce for JSON decoding
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(Response.self, from: data)
                    self.response = decodedData
                } catch {
                    print("Failed to decode data: \(error)") //log any decoding errors
                }
            }
        }.resume()
    }
    func analyzeTeam() {
        //url of my api
        guard let url = URL(string: "http://127.0.0.1:5555/prompt") else {
            print("Invalid URL")
            return
        }
        
        //SWIFT UI for URL requesting
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "team": [
                "pokemon1": team[0].name,
                "pokemon2": team[1].name,
                "pokemon3": team[2].name,
                "pokemon4": team[3].name,
                "pokemon5": team[4].name,
                "pokemon6": team[5].name,
            ]
        ]
        
        print(parameters)

        //convert to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
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
            
            //update state to UI
            DispatchQueue.main.async {
                print("Response from server: \(responseString)")

//                responseMessage = responseString
//                chatHistory.append((message: responseString, isUser: false))
            }
        }
        //calls the task defined above
        task.resume()
    }
}

struct Pokecenter_Preview: PreviewProvider {
    static var previews: some View {
        NavigationManagerView()
    }
}
