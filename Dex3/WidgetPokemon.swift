import SwiftUI

enum WidgetSize {
    case small, medium, large , extraLarge
}

struct WidgetPokemon: View {
    @EnvironmentObject var pokemon: Pokemon
    let widgetSize: WidgetSize

    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 0) {
                switch widgetSize {
                case .small: smallWidget
                case .medium: mediumWidget
                case .large , .extraLarge: largeWidget
                }
            }
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 10)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(gradient: Gradient(colors: [
            Color(pokemon.types![0].capitalized).opacity(0.8),
            Color(pokemon.types![0].capitalized)
        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var smallWidget: some View {
        VStack {
            FetchedImage(url: pokemon.sprite)

                .scaledToFit()
                .frame(width: 60, height: 60)
                .shadow(color: .white.opacity(0.6), radius: 6, x: 0, y: 3)
            
            Text(pokemon.name!.capitalized)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
    
    private var mediumWidget: some View {
        HStack {
            FetchedImage(url: pokemon.sprite)

                .scaledToFit()
                .frame(width: 80, height: 80)
                .shadow(color: .white.opacity(0.6), radius: 6, x: 0, y: 3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pokemon.name!.capitalized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(pokemon.types!.joined(separator: ", ").capitalized)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                HStack {
                    statView(title: "HP", value: pokemon.hp)
                    statView(title: "ATK", value: pokemon.attack)
                }
            }
            Spacer()
        }
        .padding(8)
        .background(Color.black.opacity(0.2))
        .cornerRadius(10)
    }
    
    private var largeWidget: some View {
        VStack {
            Text(pokemon.name!.capitalized)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)
            
            FetchedImage(url: pokemon.sprite)

                .scaledToFit()
                .frame(height: 120)
                .shadow(color: .white.opacity(0.6), radius: 10, x: 0, y: 5)
            
            HStack {
                ForEach(pokemon.types!, id: \.self) { type in
                    Text(type.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.3))
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 5)
            
            VStack(spacing: 5) {
                statBar(title: "HP", value: pokemon.hp, color: .green)
                statBar(title: "Attack", value: pokemon.attack, color: .red)
                statBar(title: "Speed", value: pokemon.speed, color: .yellow)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(20)
    }
    
    private var extraLargeWidget: some View {
        VStack {
            Text(pokemon.name!.capitalized)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 2)

            FetchedImage(url: pokemon.sprite)
                .scaledToFit()
                .frame(height: 180) // حجم أكبر للصورة
                .shadow(color: .white.opacity(0.6), radius: 10, x: 0, y: 5)

            HStack {
                ForEach(pokemon.types!, id: \.self) { type in
                    Text(type.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.3))
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 5)

            VStack(spacing: 10) {
                statBar(title: "HP", value: pokemon.hp, color: .green)
                statBar(title: "Attack", value: pokemon.attack, color: .red)
                statBar(title: "Speed", value: pokemon.speed, color: .yellow)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(20)
    }
    
    private func statView(title: String, value: Int16) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
            Text("\(value)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.black.opacity(0.3))
        .cornerRadius(5)
    }
    
    private func statBar(title: String, value: Int16, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 60, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: min(CGFloat(value) / 255 * geometry.size.width, geometry.size.width))
                }
            }
            .frame(height: 8)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text("\(value)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

struct WidgetPokemon_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetPokemon(widgetSize: .small)
            WidgetPokemon(widgetSize: .medium)
            WidgetPokemon(widgetSize: .large)
            WidgetPokemon(widgetSize: .extraLarge)
        }
        .environmentObject(SamplePokemon.samplePokemon)
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray)
    }
}


