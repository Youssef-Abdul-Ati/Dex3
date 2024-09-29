import Foundation
import CoreData

struct FetchController {
    
    enum NetworkError: Error {
        case badURL
        case badResponse
        case badData
    }

    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon/")!

    func fetchAllPokemon() async throws -> [TempPokemon]? {
        
        if havePokemon() {
            return nil
        }
        
        var allPokemon: [TempPokemon] = []
        // إعداد URLComponents لإضافة معلمات الاستعلام
        var fetchComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        fetchComponents?.queryItems = [
            URLQueryItem(name: "limit", value: "386") // تحديد عدد البوكيمون الذين سيتم جلبهم
        ]
        
        // تحقق من أن الـ URL صحيح
        guard let fetchURL = fetchComponents?.url else {
            throw NetworkError.badURL
        }

        // طلب البيانات من الـ API
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        
        // التحقق من الاستجابة HTTP
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        // تحويل البيانات القادمة من JSON إلى قاموس
        guard let pokeDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let pokedex = pokeDictionary["results"] as? [[String: String]] else {
            throw NetworkError.badData
        }
        
        // التعامل مع كل بوكيمون
        for pokemon in pokedex {
            if let urlString = pokemon["url"], let url = URL(string: urlString) {
                allPokemon.append(try await fetchPokemon(from: url))
            }
        }
        
        return allPokemon
    }

    private func fetchPokemon(from url: URL) async throws -> TempPokemon {
        // طلب بيانات البوكيمون الفردي
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // التحقق من الاستجابة HTTP
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        // فك التشفير من JSON إلى TempPokemon
        let tempPokemon = try JSONDecoder().decode(TempPokemon.self, from: data)
        print("Fetched \(tempPokemon.id): \(tempPokemon.name)")
        
        return tempPokemon
    }
    
    private func havePokemon() -> Bool {
        let context = PersistenceController.shared.container.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", [1, 386])
        
        do {
            let checkPokemon = try context.fetch(fetchRequest)
            if checkPokemon.count == 2 {
                return true
            }
        } catch {
            print("Fetch failed: \(error)")
            return false
        }
        
        return false
    }
}
