import CoreML
import Foundation

class CarMinder {
    private let knowledgeBase: VehicleKnowledgeBase
    private var userAnswers: [String: String] = [:]
    
    init() throws {
        self.knowledgeBase = try VehicleKnowledgeBase(configuration: MLModelConfiguration())
    }
    
    func setAnswer(for feature: String, value: String) {
        userAnswers[feature] = value
    }
    
    func predict() throws -> VehicleKnowledgeBasePrediction {
        let input = VehicleKnowledgeBaseInput(
            manufacturer: userAnswers["manufacturer"],
            country: userAnswers["country"],
            body_type: userAnswers["body_type"],
            car_class: userAnswers["car_class"],
            doors: userAnswers["doors"],
            seats: userAnswers["seats"],
            engine_type: userAnswers["engine_type"],
            fuel: userAnswers["fuel"],
            drivetrain: userAnswers["drivetrain"],
            transmission: userAnswers["transmission"],
            power_category: userAnswers["power_category"],
            start_year_category: userAnswers["start_year_category"]
        )
        return try knowledgeBase.prediction(input: input)
    }
    
    func getTopPredictions(count: Int = 5) throws -> [(car: String, probability: Double)] {
        let prediction = try predict()
        return prediction.labelProbability
            .sorted { $0.value > $1.value }
            .prefix(count)
            .map { (car: $0.key, probability: $0.value) }
    }
    
    func isConfident(threshold: Double = 0.9) throws -> String? {
        let topPredictions = try getTopPredictions(count: 1)
        return topPredictions.first?.probability ?? 0 > threshold ? topPredictions.first?.car : nil
    }
    
    func getBestQuestion() throws -> String? {
        let topCars = try getTopPredictions(count: 10)
        return calculateBestFeature(for: topCars.map { $0.car })
    }
    
    private func calculateBestFeature(for cars: [String]) -> String? {
        let features = ["manufacturer", "body_type", "fuel", "drivetrain", "power_category"]
        return features.first { userAnswers[$0] == nil }
    }
    
    func reset() {
        userAnswers.removeAll()
    }
}
