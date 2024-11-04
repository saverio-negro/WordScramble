//
//  ContentView.swift
//  WordScramble
//
//  Created by Saverio Negro on 03/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    func startGame() {
        // Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            // Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                
                // Split the string into an array of strings - splitting on line breaks
                let words = startWords.components(separatedBy: "\n")
                
                // Pick one random word, or use "silkworm" as a sensible default
                let word = words.randomElement() ?? "silkworm"
                rootWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
                
            } else {
                fatalError("Unable to load `start.txt` file.")
            }
        } else {
            fatalError("Unable to locate `start.txt` file.")
        }
    }
    
    // Validate the new word and add it to the list of used words
    func addNewWord() -> Void {
        
        // Lowercase and trim the word, that will also make sure that we
        // don't add any duplicate words with case differences.
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Exit if the remaining string is empty
        guard answer.count > 0 else { return }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color.indigo, Color.blue], startPoint: .leading, endPoint: .trailing)
                    .ignoresSafeArea()
                
                VStack {
                    List {
                        Section("Word to spell from") {
                            Text(rootWord)
                                .font(.largeTitle)
                                .listRowBackground(Color.clear)
                        }
                        
                        Section("Word to spell from \(rootWord)") {
                            TextField("Enter your word", text: $newWord)
                                .textInputAutocapitalization(.never)
                                .onSubmit(addNewWord)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .scrollDisabled(true)
                    .listStyle(.plain)
                    
                    List {
                        Section("Used words") {
                            ForEach(usedWords, id: \.self) { usedWord in
                                HStack {
                                    Image(systemName: "\(usedWord.count).circle")
                                    Text(usedWord)
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("WordScramble")
        }
        .onAppear(perform: startGame)
    }
}

#Preview {
    ContentView()
}
