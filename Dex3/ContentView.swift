import SwiftUI
import CoreData
 
struct ContentView: View {
 
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Pokemon.id,
            ascending: true
        )],
        animation: .default
    ) private var pokedex: FetchedResults<Pokemon>
 
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(
            keyPath: \Pokemon.id,
            ascending: true
        )],
        predicate: NSPredicate(format: "favorite = %d", true),
        animation: .default
    ) private var favorites: FetchedResults<Pokemon>
 
    @State var filterByFavorites = false
    @StateObject private var pokemonVM = PokemonViewModel(
        controller: FetchController()
    )
 
    var body: some View {
        switch pokemonVM.status {
        case .success:
            NavigationStack {
                List(filterByFavorites ? favorites : pokedex) { pokemon in
                    NavigationLink(value: pokemon) {
                        AsyncImage(url: pokemon.sprite) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        Text(pokemon.name!.capitalized)
 
                        if pokemon.favorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
 
                    }
                }
                .navigationTitle("Pokedex")
                .navigationDestination(for: Pokemon.self, destination: { Pokemon in
                    PokemonDetail()
                        .environmentObject(Pokemon)
                })
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            withAnimation {
                                filterByFavorites.toggle()
                            }
                        } label: {
                            Image(systemName: filterByFavorites ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.title)
                        }
                    }
                }

            }
        default :
            ProgressView()
        }
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(
                \.managedObjectContext,
                 PersistenceController.preview.container.viewContext
            )
    }
}

