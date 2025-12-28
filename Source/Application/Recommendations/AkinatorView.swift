import SwiftUI
import SwiftUIComponents

struct AkinatorView: View {
    @State private var akinator = Akinator()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            // Top question area
            VStack(alignment: .leading, spacing: 20) {
                switch akinator.state {
                case .onboarding:
                    Text("I can guess any car you're thinking of in 10 questions or less! Think you can stump me?")
                        .font(.title)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                case .questioning(let question):
                    Text(question.text)
                        .font(.title)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .redacted(reason: akinator.isLoading ? .placeholder : [])
                        
                case .guessing(let car):
                    Text("Is it \(car.name)?")
                        .font(.title)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .redacted(reason: akinator.isLoading ? .placeholder : [])
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 40)
            .animation(.smooth, value: akinator.state)
            
            Spacer()
            
            // Bottom buttons area
            VStack(spacing: 16) {
                switch akinator.state {
                case .onboarding:
                    makeOnboardingButtons()
                case .questioning:
                    makeAnswerButtons()
                case .guessing:
                    makeResultButtons()
                }
            }
            .padding(.bottom, 40)
            .animation(.smooth, value: akinator.state)
        }
        .padding(.horizontal)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: makeToolbar)
    }
    
    @ViewBuilder
    private func makeOnboardingButtons() -> some View {
        VStack(spacing: 20) {
            Text("Let's find out if you can stump me!")
                .font(.title)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("I've Got One!") {
                akinator.startGame()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
    
    @ViewBuilder
    private func makeAnswerButtons() -> some View {
        VStack(spacing: 12) {
            Button("Yes") { akinator.answer(.yes) }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(akinator.isLoading)
            
            Button("Maybe") { akinator.answer(.maybe) }
                .buttonStyle(StrokeButtonStyle())
                .disabled(akinator.isLoading)
            
            Button("Don't Know") { akinator.answer(.dontKnow) }
                .buttonStyle(StrokeButtonStyle())
                .disabled(akinator.isLoading)
            
            Button("Probably Not") { akinator.answer(.probablyNot) }
                .buttonStyle(StrokeButtonStyle())
                .disabled(akinator.isLoading)
            
            Button("No") { akinator.answer(.no) }
                .buttonStyle(StrokeButtonStyle())
                .disabled(akinator.isLoading)
        }
        .opacity(akinator.isLoading ? 0.6 : 1.0)
    }
    
    @ViewBuilder
    private func makeResultButtons() -> some View {
        VStack(spacing: 12) {
            Button("Yes, correct!") {
                akinator.endGame()
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button("Wrong guess") {
                akinator.continueAfterWrongGuess()
            }
            .buttonStyle(StrokeButtonStyle())
        }
    }
    
    @ToolbarContentBuilder
    private func makeToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button("Reset", systemImage: "arrow.clockwise") {
                    akinator.endGame()
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}
