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
//    let team: [Pokemon]
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
            
            // Convert JSON
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

struct VictoryRoad: View {
    @StateObject var viewModel = PokemonTeamModel()
    var body: some View{
        VStack{
            HStack{
                Text("Pokemon Teams")
                NavigationLink(destination: Pokecenter(teamIDPassed: nil, teamNamePassed: nil, pokemonAnalysisPassed: nil, teamPassed: nil)){
                    Image(systemName: "plus")
                }
                //                NavigationLink(destination: Company(company_id: nil, company: nil, alumniPassed:nil, postingsPassed: nil))
            }
            .padding(.horizontal)

            
            List{
                ForEach(viewModel.teams, id :\.self) {
                    team in
                    HStack(spacing: 20){
                        Spacer(minLength: 20)
                        NavigationLink(destination: Pokecenter(teamIDPassed: team.id, teamNamePassed: team.name, pokemonAnalysisPassed: team.analysis, teamPassed: [team.pokemon_1,team.pokemon_2,team.pokemon_3,team.pokemon_4,team.pokemon_5,team.pokemon_6]))
                        
                        
                            {
                                Text(team.name)
                                    .frame(width:100, alignment: .center)
                                    .padding(.leading, 40)
                            }


                        Spacer()

                        
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear{
            viewModel.fetch()
        }
    }
}

struct VictoryRoad_Preview: PreviewProvider {
    static var previews: some View {
        NavigationManagerView()
    }
}
