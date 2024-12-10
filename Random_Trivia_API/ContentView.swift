//
//  ContentView.swift
//  Random_Trivia_API
//
//  Created by Banibe Ebegbodi on 9/30/24.
//

import SwiftUI

// MARK: - QuizItem
struct QuizItem: Codable, Identifiable {
    let category: String
    let id: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let question: Question
    let tags: [String]
    let type: String
    let difficulty: String
    let regions: [String]
    let isNiche: Bool
    
    //shuffling things around for answers
    var allAnswers: [String] {
            (incorrectAnswers + [correctAnswer]).shuffled()
        }
}

// MARK: - Question
struct Question: Codable {
    let text: String
    }



class QuizViewModel: ObservableObject {
    @Published var quizList: [QuizItem] = []
    
    func fetchTrivia() {
        guard let url = URL(string: "https://the-trivia-api.com/v2/questions/") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                // Decode the JSON into your model
                               let decodedResponse = try JSONDecoder().decode([QuizItem].self, from: data)
                               DispatchQueue.main.async {
                                   self.quizList = decodedResponse
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()  // Start the data task
    }
}

//content vieww
struct ContentView: View {
    @StateObject var viewModel = QuizViewModel()
    @State private var selectedAnswer: String? = nil
    
    var body: some View {
        ZStack {
            Color.blue
                .opacity(0.2)
                .ignoresSafeArea()
            NavigationView {
                List(viewModel.quizList) { QuizItem in
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(QuizItem.category)
                                        .font(.caption)
                                    .foregroundColor(.secondary)
                                    Spacer()
                                    Text(QuizItem.difficulty)
                                        .font(.caption)
                                        .foregroundColor(difficultyColor(QuizItem.difficulty))
                                }
                                Text(QuizItem.question.text.isEmpty ? "No Question Available" : QuizItem.question.text)
                                    .foregroundColor(.primary)
                                    .padding(.bottom)
                                    .bold()
                                
                                ForEach(QuizItem.allAnswers, id: \.self) { answer in
                                    //using a tag helped get specific view for correct/incorrect answers
                                    NavigationLink(destination: AnswerResultView(quizItem: QuizItem, selectedAnswer: answer), tag: answer, selection: $selectedAnswer
                                    ) {
                                        Text(answer)
                                            .font(.system(size: 15, design: .rounded))
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                    .onTapGesture {
                                        selectedAnswer = answer
                                    }
                                } //answer in
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .scrollContentBackground(.hidden)
                    .background(.blue.opacity(0.15))
                    .navigationTitle("Random Trivia")
                    .onAppear {
                    viewModel.fetchTrivia()
                }
                    .refreshable {
                        viewModel.fetchTrivia()
                    }
            }
        }
    }
}

//extract view for answer view plz work (update: didn't work in getting correct view but made code look more organized)
struct AnswerResultView: View {
    let quizItem: QuizItem
    let selectedAnswer: String
    
    var body: some View {
        ZStack {
            Color.blue
                .opacity(0.2)
                .ignoresSafeArea()
            VStack {
                if selectedAnswer == quizItem.correctAnswer {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.system(size: 100, weight: .bold))
                } else {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                        .font(.system(size: 100, weight: .bold))
                }
                Text(quizItem.question.text)
                    .padding()
                    .font(.title)
                Text("Correct Answer:")
                    .font(.headline)
                Text(quizItem.correctAnswer)
                    .foregroundColor(.green)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("Incorrect Answers:")
                    .font(.headline)
                    .padding(.top)
                ForEach(quizItem.incorrectAnswers, id: \.self) { answer in
                    Text(answer)
                        .foregroundColor(.red)
                        .font(.system(size: 18, design: .rounded))
                    
                }
            }
            .padding()
        }
    }
}


//colors for dificulty
func difficultyColor(_ difficulty: String) -> Color {
    switch difficulty {
    case "easy":
        return .green
    case "medium":
        return .yellow
    case "hard":
        return .red
    default:
        return .secondary
    }
}

#Preview {
    ContentView()
}
