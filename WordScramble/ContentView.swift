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
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
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
        
        // Exit if the word has already been used
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "The word has already been used. Be more original.")
            return
        }
        
        // Exit if the word can't be spelled from the root word
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "The word you are trying to spell is not contained in \(rootWord).")
            return
        }
        
        // Exit if the word is not an English word
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "The word you inserted is not a real word. You can't just make them up, you know.")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
    }
    
    // Word Validation - ensure the user can't enter invalid words
    
    // Check whether the word has already been used
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    // Check whether the word can be spelled from the root word
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let index = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: index)
            } else {
                return false
            }
        }
        return true
    }
    
    // Check whether the word is an actual English word
    func isReal(word: String) -> Bool {
        /// Instantiate a spellchecker instance from `UITextChecker`
        let checker = UITextChecker()
        
        /// Create an Objective-C range to specify the part of the text to be checked for
        let range = NSRange(location: 0, length: word.utf16.count)
        
        /// Get the range of mispelled word
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        /// Return true if no range was found (the word is real)
        let isWordSpelledCorrectly = mispelledRange.location == NSNotFound
        return isWordSpelledCorrectly
    }
    
    // Manage the presentation of errors in the alert
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                RadialGradient(colors: [Color.blue, Color.white], center: .top, startRadius: 450, endRadius: 451)
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
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .destructive) {}
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear(perform: startGame)
    }
}

#Preview {
    ContentView()
}
