import Foundation
import Observation

@Observable
final class Akinator {
    enum State: Equatable {
        case onboarding
        case questioning(Question)
        case guessing(Car)
    }
    
    var state: State = .onboarding
    var isLoading = false
    
    let engine = AkinatorEngine()
    
    func startGame() {
        isLoading = true
        engine.reset()
        
        if let question = engine.getNextQuestion() {
            state = .questioning(question)
        } else {
            state = .onboarding
        }
        
        isLoading = false
    }
    
    func answer(_ answerType: AnswerType) {
        guard case .questioning(let question) = state else { return }
        
        isLoading = true
        engine.processAnswer(question: question, answer: answerType)
        
        if let winner = engine.checkVictory() {
            state = .guessing(winner)
        } else if let nextQuestion = engine.getNextQuestion() {
            state = .questioning(nextQuestion)
        } else {
            state = .onboarding
        }
        
        isLoading = false
    }
    
    func continueAfterWrongGuess() {
        isLoading = true
        
        if let nextQuestion = engine.getNextQuestion() {
            state = .questioning(nextQuestion)
        } else {
            state = .onboarding
        }
        
        isLoading = false
    }
    
    func endGame() {
        state = .onboarding
    }
    // MARK: - Models

    struct Car: Equatable {
        let name: String
        let characteristics: [String: Double]
        let preview: String?
    }

    struct Question: Equatable {
        let text: String
        let characteristicKey: String
    }

    // MARK: - Answer Types

    enum AnswerType: CaseIterable {
        case yes, no, dontKnow, maybe, probablyNot
        
        var weight: Double {
            switch self {
            case .yes: return 1.0
            case .no: return 0.0
            case .dontKnow: return 0.5
            case .maybe: return 0.7
            case .probablyNot: return 0.3
            }
        }
    }
}

typealias Car = Akinator.Car
typealias Question = Akinator.Question
typealias AnswerType = Akinator.AnswerType

// MARK: - Engine Protocol

protocol AkinatorEngineProtocol {
    func processAnswer(question: Question, answer: AnswerType)
    func getNextQuestion() -> Question?
    func checkVictory() -> Car?
    func reset()
}

// MARK: - Akinator Engine

final class AkinatorEngine: AkinatorEngineProtocol {
    private let cars: [Car]
    private var scores: [String: Double]
    private let questions: [Question]
    private var usedQuestions: Set<String> = []
    private let victoryThreshold: Double = 0.8
    
    init() {
        self.cars = Self.loadCarsFromCSV() ?? []
        self.questions = Self.loadQuestionsFromCSV() ?? []
        self.scores = Dictionary(uniqueKeysWithValues: cars.map { ($0.name, 1.0) })
    }
    
    func processAnswer(question: Question, answer: AnswerType) {
        let answerWeight = answer.weight
        
        for car in cars {
            let carCharacteristic = car.characteristics[question.characteristicKey] ?? 0.5
            let similarity = 1.0 - abs(carCharacteristic - answerWeight)
            scores[car.name] = (scores[car.name] ?? 0) * similarity
        }
        
        normalizeScores()
        usedQuestions.insert(question.characteristicKey)
    }
    
    func getNextQuestion() -> Question? {
        let availableQuestions = questions.filter { !usedQuestions.contains($0.characteristicKey) }
        guard !availableQuestions.isEmpty else { return nil }
        
        return availableQuestions.max { entropy(for: $0) < entropy(for: $1) }
    }
    
    func checkVictory() -> Car? {
        let topCar = scores.max { $0.value < $1.value }
        guard let (carName, score) = topCar, score > victoryThreshold else { return nil }
        return cars.first { $0.name == carName }
    }
    
    func reset() {
        scores = Dictionary(uniqueKeysWithValues: cars.map { ($0.name, 1.0) })
        usedQuestions.removeAll()
    }
    
    private func normalizeScores() {
        let total = scores.values.reduce(0, +)
        guard total > 0 else { return }
        scores = scores.mapValues { $0 / total }
    }
    
    private func entropy(for question: Question) -> Double {
        let key = question.characteristicKey
        var yesScore = 0.0, noScore = 0.0
        
        for car in cars {
            let characteristic = car.characteristics[key] ?? 0.5
            let carScore = scores[car.name] ?? 0
            yesScore += carScore * characteristic
            noScore += carScore * (1.0 - characteristic)
        }
        
        let total = yesScore + noScore
        guard total > 0 else { return 0 }
        
        let p1 = yesScore / total
        let p2 = noScore / total
        
        return -(p1 * log2(p1 + 1e-10) + p2 * log2(p2 + 1e-10))
    }
    

    
    private static func loadCarsFromCSV() -> [Car]? {
        guard let path = Bundle.main.path(forResource: "cars", ofType: "csv"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else { return nil }
        
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else { return nil }
        
        let headers = lines[0].components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        return lines.dropFirst().compactMap { line in
            let values = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard values.count == headers.count else { return nil }
            
            let name = values[0]
            let preview = values.last
            
            // Get characteristic keys (exclude name and preview columns)
            let characteristicKeys = Array(headers.dropFirst().dropLast())
            let charValues = Array(values.dropFirst().dropLast())
            
            let characteristics = Dictionary(uniqueKeysWithValues: 
                zip(characteristicKeys, charValues.compactMap(Double.init))
            )
            
            return Car(name: name, characteristics: characteristics, preview: preview)
        }
    }
    
    private static func loadQuestionsFromCSV() -> [Question]? {
        guard let path = Bundle.main.path(forResource: "questions", ofType: "csv"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else { 
            debugPrint("[DEBUG][Akinator] Failed to load questions.csv")
            return nil 
        }
        
        debugPrint("[DEBUG][Akinator] Questions CSV content: \(content)")
        
        let questions: [Question] = content.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .compactMap { line in
                let components = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                guard components.count >= 2 else { 
                    debugPrint("[DEBUG][Akinator] Invalid line: \(line)")
                    return nil 
                }
                return Question(text: components[0], characteristicKey: components[1])
            }
        
        debugPrint("[DEBUG][Akinator] Loaded \(questions.count) questions")
        return questions.isEmpty ? nil : questions
    }
}
