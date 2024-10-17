//
//  VictoryRoad.swift
//  pyChat UI
//
//  Created by pedro on 10/8/24.
//

import SwiftUI

//defie pokemon struct
struct Pokemon: Hashable, Codable, Identifiable{
    var id: Int
    var name: String
    var image: String
}

struct PokemonTeam: Hashable, Codable, Identifiable{
    let id: Int
    let name: String
    let pokemon_1: String
    let pokemon_2: String
    let pokemon_3: String
    let pokemon_4: String
    let pokemon_5: String
    let pokemon_6: String
    let analysis: String
}



class PokemonTeamModel: ObservableObject{
    @Published var teams: [PokemonTeam] = []
    
    func fetch() {
        guard let url = URL(string: "http://127.0.0.1:5555/pokemon-teams") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(String(describing: error))")
                return
            }
            
            // Log the JSON response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON Response: \(jsonString)")
            }
            
            //convert JSON
            do {
                let teams = try JSONDecoder().decode([PokemonTeam].self, from: data)
                DispatchQueue.main.async {
                    self?.teams = teams
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }

}

struct PokemonCenter: View {
    @StateObject var viewModel = PokemonTeamModel()
    var body: some View{
        VStack{
            HStack{
                Text("Pokemon Teams")
                NavigationLink(destination: VictoryRoad(teamIDPassed: nil, teamNamePassed: nil, pokemonAnalysisPassed: nil, teamPassed: nil)){
                    Image(systemName: "plus")
                }
                //                NavigationLink(destination: Company(company_id: nil, company: nil, alumniPassed:nil, postingsPassed: nil))
            }
            .padding(.horizontal)

            
            List{
                ForEach(viewModel.teams, id :\.self) {
                    team in
                    HStack(spacing: 20){
                        Spacer()
                        NavigationLink(destination: VictoryRoad(teamIDPassed: team.id, teamNamePassed: team.name, pokemonAnalysisPassed: team.analysis, teamPassed: [team.pokemon_1,team.pokemon_2,team.pokemon_3,team.pokemon_4,team.pokemon_5,team.pokemon_6]))
                        
                        
                            {
                                Text(team.name)
                                    .frame(width:100, alignment: .center)
                                    .padding(.leading, 40)
                            }


                        Spacer()
                        Button(action: {
                            removeTeam(team.id)
                            print("Team Deleted")
                        }){
                            Image(systemName: "minus")
                        }

                        
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear{
            viewModel.fetch()
        }
    }
    func removeTeam(_ id: Int) {
        //url of my api
        guard let url = URL(string: "http://127.0.0.1:5555/pokemon-team/\(id)") else {
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

struct PokemonCenter_Preview: PreviewProvider {
    static var previews: some View {
        NavigationManagerView()
    }
}
