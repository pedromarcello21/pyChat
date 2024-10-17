import SwiftUI
//import Foundation


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

struct PokemonID: Codable {
    let name: String
    let imageURL: String
    
}


class PokemonFetcher {
    
    func fetchPokemonInfo(name: String, completion: @escaping (PokemonID?) -> Void) {
        let urlString = "https://pokeapi.co/api/v2/pokemon/\(name.lowercased())"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let sprites = json["sprites"] as? [String: Any],
                   let frontDefault = sprites["front_default"] as? String {
                    let pokemon = PokemonID(name: name, imageURL: frontDefault)
                    completion(pokemon)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        
        task.resume()
    }
}


struct VictoryRoad: View {
    
    @Environment(\.presentationMode) private var
    presentationMode: Binding<PresentationMode>
    
    let teamIDPassed: Int?
    let teamNamePassed: String?
    let pokemonAnalysisPassed: String?
    let teamPassed: [String]?

    
    //initialize state of API response
    @State private var response = Response(count: 0, next: nil, previous: nil, results: [])
    //initialize search text
    @State private var searchText: String = ""
    //initialize state of selected pokemon.  ? allows for initial nil value
    @State private var selectedPokemon: Result?
    
    //define list of dictionaries of type Pokemon
    @State private var team: [Pokemon] = []
    
    @State private var pokemonIDTeam: [PokemonID] = [] //define as a state variable

    
    //define list of dictionaries of type Pokemon
    @State private var pokemonAnalysis: String = ""
    
    //define team name
    @State private var teamName: String = ""
    
    //fetched team
    @State private var fetchedTeam: [PokemonID] = []
    
    //set editting state
    @State private var editting: Bool = false


    
    //define column space for pokemon output
    let columns = [
        GridItem(.flexible()), // 1st column
        GridItem(.flexible()), // 2nd column
        GridItem(.flexible())  // 3rd column
    ]

    var body: some View {
        VStack {
            Text("Victory Road")
                .font(.largeTitle)
                .padding()
            
            
            if let teamIDPassed = teamIDPassed, let teamPassed = teamPassed, let pokemonAnalysisPassed = pokemonAnalysisPassed, !editting{
                VStack{
                    Button(action: {
                        editTeam()
                        
                    })
                    {
                        Text("Edit Team")
                    }
                    Text(teamNamePassed!)
                    
                }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(fetchedTeam, id: \.name) { pokemon in
                            VStack {
                                Text(pokemon.name.capitalized)
                                    .font(.title2)
                                
                                AsyncImage(url: URL(string: pokemon.imageURL)) { image in
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
                            }.frame(maxWidth: .infinity) // Ensures even spacing in the column
                        }
                    }; Spacer()
                    Text(pokemonAnalysisPassed)
                }
                
                
            }
            else if var teamIDPassed = teamIDPassed, var teamPassed = teamPassed, editting {
                
                ZStack{
                    VStack {
                        Text(teamNamePassed!)
                        if fetchedTeam.count < 6{
                            TextField("Search Pokémon", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            
                        }
                        
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(fetchedTeam, id: \.name) { pokemon in
                                    HStack {
                                        VStack {
                                            Text(pokemon.name.capitalized)
                                                .font(.title2)
                                            
                                            AsyncImage(url: URL(string: pokemon.imageURL)) { image in
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
                                        }
                                        .frame(maxWidth: .infinity) // Ensures even spacing in the column
                                        
                                        Button(action: {
                                            print("Pokemon deleted")
                                            var index = fetchedTeam.firstIndex(where: {$0.name == pokemon.name})
                                            fetchedTeam.remove(at:index!)
                                            for pokemon in fetchedTeam {
                                                print(pokemon.name)
                                            }

                                            
                                        }) {
                                            Image(systemName: "minus")
                                        }
                                    }
                                }
                            }
                            Spacer()
                            Text(pokemonAnalysis) // Display the state variable here
                        }
                        if fetchedTeam.count == 6 && pokemonAnalysis.isEmpty{
                            Button(action: {
                                print("Analyzing Team...")
                                analyzeTeam(team: fetchedTeam)
                                print(type(of: fetchedTeam))
//                                for pokemon in fetchedTeam{
//                                    print(pokemon)
//                                }
                            }){
                                //copy button is rendered as followinng icon
                                Text("Analyze Team")
                                
                            }
                        } else if fetchedTeam.count == 6 && !pokemonAnalysis.isEmpty{
                            HStack{
                                TextField("Enter Pokémon Team Name", text: $teamName).padding()
                                    .onAppear {
                                                if let teamNamePassed = teamNamePassed {
                                                    teamName = teamNamePassed //prepopulate the text field with the passed team name
                                                }
                                            }
                                Button(action: {
                                    print("Updating Team...")
//                                    addTeam()
                                    updateTeam(teamIDPassed)
                                })
                                {
                                    
                                    Text("Update Team")
                                        .padding()
                                }
                            }
                        }
                    }
//                    .onAppear {
//                        // Reset pokemonAnalysis when this view appears
//                        pokemonAnalysis = ""
//                    }
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
                                            let pokemonImage = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(substring).png"
                                            if fetchedTeam.count < 6 { fetchedTeam.append(PokemonID(name: searchText, imageURL:pokemonImage))
                                            }
                                            
                                            searchText = ""
                                            //
                                            
                                            
                                            
                                        }
                                }
                            }
                            .frame(maxHeight: 200)
                            .listStyle(PlainListStyle())
                        }
                    }

                }
            }

            else{
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
                            if !pokemonAnalysis.isEmpty {
                                Text(pokemonAnalysis)
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
                                            let pokemonImage = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(substring).png"
                                            if team.count < 6 { team.append(Pokemon(id: team.count, name: searchText, image:pokemonImage))
                                            }
                                            pokemonIDTeam = convertTeamToPokemonID(team: team)


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
                if team.count == 6 && pokemonAnalysis.isEmpty{
                    Button(action: {
                        print("Analyzing Team...")
                        print(pokemonIDTeam)
                        analyzeTeam(team: pokemonIDTeam)
                    }){
                        //copy button is rendered as followinng icon
                        Text("Analyze Team")
                        
                    }
                } else if team.count == 6 && !pokemonAnalysis.isEmpty{
                    HStack{
                        TextField("Enter Pokémon Team Name", text: $teamName).padding()
                        Button(action: {
                            print("Adding Team...")
                            addTeam()
                        })
                        {
                            
                            Text("Add Team")
                                .padding()
                        }
                    }
                }
            }
        }
        .onAppear {
            getPokemon() // Existing method
            fetchTeamPokemon() // Fetch data for passed team
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
    
    func convertTeamToPokemonID(team: [Pokemon]) -> [PokemonID] {
        return team.map { pokemon in
            PokemonID(name: pokemon.name, imageURL: pokemon.image)
        }
    }
    
    func analyzeTeam(team: Array<PokemonID>) {
        //url of my api
        //looks like this will have to hit a different endpoint
        guard let url = URL(string: "http://127.0.0.1:5555/analyze-team") else {
            print("Invalid URL")
            return
        }
        
        //SWIFT UI for URL requesting
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "prompt": [
                "pokemon1": team[0].name,
                "pokemon2": team[1].name,
                "pokemon3": team[2].name,
                "pokemon4": team[3].name,
                "pokemon5": team[4].name,
                "pokemon6": team[5].name,
            ]
        ]
        
        print("Parameters: \(parameters)")


        //convert to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
//            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("Serialized Data: \(jsonString)")
//            }

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
                pokemonAnalysis = responseString

//                responseMessage = responseString
//                chatHistory.append((message: responseString, isUser: false))
            }
        }
        //calls the task defined above
        task.resume()
    }
    
    func addTeam(){

        //url of my api
        guard let url = URL(string: "http://127.0.0.1:5555/add-team") else {
            print("Invalid URL")
            return
        }
        
        //SWIFT UI for URL requesting
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["name":teamName,"pokemon_1": team[0].name, "pokemon_2": team[1].name,"pokemon_3": team[2].name,"pokemon_4": team[3].name,"pokemon_5": team[4].name,"pokemon_6": team[5].name,"analysis":pokemonAnalysis]
        
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
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
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
                    pokemonAnalysis = ""
                    team = []
                    teamName = ""
            
            }
        }
        //calls the task defined above
        task.resume()
    }
    func fetchTeamPokemon() {
        guard let teamPassed = teamPassed else { return }
        
        // Create a dispatch group to manage concurrent fetches
        let dispatchGroup = DispatchGroup()
        
        for name in teamPassed {
            dispatchGroup.enter()
            PokemonFetcher().fetchPokemonInfo(name: name) { pokemon in
                if let pokemon = pokemon {
                    DispatchQueue.main.async {
                        self.fetchedTeam.append(pokemon)
                    }
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Finished fetching all Pokémon data.")
        }
    }
    func editTeam() {
        editting = !editting
        print(editting)
    }
    func updateTeam(_ teamIDPassed: Int){
//        print(teamIDPassed)
        print(pokemonAnalysis)
        print(fetchedTeam)

        //url of my api
        guard let url = URL(string: "http://127.0.0.1:5555/update-pokemon-team/\(teamIDPassed)") else {
            print("Invalid URL")
            return
        }
        
        //SWIFT UI for URL requesting
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["name":teamName,"pokemon_1": fetchedTeam[0].name, "pokemon_2": fetchedTeam[1].name,"pokemon_3": fetchedTeam[2].name,"pokemon_4": fetchedTeam[3].name,"pokemon_5": fetchedTeam[4].name,"pokemon_6": fetchedTeam[5].name,"analysis":pokemonAnalysis]
        
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
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
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
                    pokemonAnalysis = pokemonAnalysis //new analysis value
                    teamName = teamName //new team name value
            }
        }
        editting = !editting
        presentationMode.wrappedValue.dismiss()

        //calls the task defined above
        task.resume()
    
}


    
}

struct Pokecenter_Preview: PreviewProvider {
    static var previews: some View {
        NavigationManagerView()
    }
}
