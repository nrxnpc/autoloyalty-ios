import Foundation
import ScopeGraph

/// Use case for create welcome notificaiton
public struct CreateBuiltInRecommendationsSetUseCase {
    private let scope: Scope
    public init(scope: Scope) {
        self.scope = scope
    }
    
    public func execute() async throws {
        let context = scope.coreDataContext
        
        let messages = try context.fetch(CarRecommendation.allDrafts())
        guard messages.isEmpty else {
            return
        }
        
        try await context.perform {
            let rawRecommendations = [
                ("Porsche", "911 Turbo S", 2020, "", "Legendary sports car with 650 horsepower, speed and elegance. Features carbon roof for improved aerodynamics and premium Burmester sound system. 0-100 km/h in 2.7 seconds makes it one of the fastest cars in its class.", "3.8L Twin-Turbo Flat-6", "Automatic", "Gasoline", "Coupe", "AWD", "", "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2F911_0.jpg?alt=media&token=a02489e4-7d7f-4fc6-a3b1-fc97f913bf2e"),
                ("Rolls-Royce", "Cullinan", 2019, "", "Luxury SUV that perfectly combines power and elegance. Equipped with powerful V12 engine producing 571 hp. Interior features luxurious leather with nubuck panels and LED starlight headliner. Every detail creates unparalleled atmosphere of sophistication and comfort.", "6.7L V12", "Automatic", "Gasoline", "SUV", "AWD", "", "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2FCullinan_0.jpg?alt=media&token=10f0a63c-af36-4888-b98c-8c4bd55cebef"),
                ("Porsche", "911 Targa 4S", 2020, "", "Sports car with unique design combining classic Targa features and modern Porsche style. Features retractable roof for open-air driving enjoyment. Interior made from high-quality materials with digital instrument cluster and 10.9-inch touchscreen.", "3.0L Twin-Turbo Flat-6", "Automatic", "Gasoline", "Targa", "AWD", "", "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2FTarga_0.jpg?alt=media&token=909a0653-ad49-452f-b0f0-db5948407a1e"),
                ("Porsche", "911 Turbo Cabriolet", 2020, "", "Sports convertible with open top, combining traditional forms with innovative equipment. Dashboard features analog tachometer surrounded by large screens. Powerful 3.8L engine produces 580 hp. Smooth control system with electronic assistants ensures full driver control.", "3.8L Twin-Turbo Flat-6", "Automatic", "Gasoline", "Cabriolet", "AWD", "", "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2FCabrio_0.jpg?alt=media&token=e45f7e31-c251-4e99-8396-84d88e4a20e1"),
                ("Porsche", "911 Carrera 4S Cabriolet", 2019, "", "Spectacular sports convertible with classic forms and distinctive style. Features bi-xenon optics, active all-wheel drive system and comfortable ergonomic cabin. 3.0L flat-six engine with 420 hp accelerates to 100 km/h in under 4 seconds.", "3.0L Flat-6", "Automatic", "Gasoline", "Cabriolet", "AWD", "", "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2FCabrio%204S_0.jpg?alt=media&token=a0abf176-3fe8-4d25-a214-38feba400fec"),
                ("Audi", "RS 7 Sportback", 2020, "", "Sports liftback with elegant stylish lines, combining external aggression and powerful V8 TFSI engine. Wide body pressed to the road, protruding wheel arches and continuous LED line. Virtual instrument panel, sports steering wheel and RS1/RS2 modes. Carbon-ceramic brake system and individual lighting technology.", "4.0L Twin-Turbo V8 TFSI", "Automatic", "Gasoline", "Liftback", "AWD", "", "https://firebasestorage.googleapis.com/v0/b/note-mess-8a48b.firebasestorage.app/o/nsp-content-pack%2FAudi_0.jpg?alt=media&token=67eca8ca-0d33-47fc-b291-392188cce034")
            ]
            
            for (brand, model, year, price, description, engine, transmission, fuel, body, drivetrain, color, imageURL) in rawRecommendations {
                let recommendation = CarRecommendation(context: context)
                recommendation.sync.isDraft = true
                recommendation.isActive = true
                recommendation.brand = brand
                recommendation.model = model
                recommendation.year = Int(Int32(year))
                recommendation.price = price
                recommendation.carDescription = description
                recommendation.engine = engine
                recommendation.transmission = transmission
                recommendation.fuelType = fuel
                recommendation.bodyType = body
                recommendation.drivetrain = drivetrain
                recommendation.color = color
                recommendation.imageURL = URL(string: imageURL)
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
}
