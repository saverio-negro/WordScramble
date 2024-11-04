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
                LinearGradient(colors: [Color.cyan, Color.teal], startPoint: .leading, endPoint: .trailing)
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
        .onAppear {
            if let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
                if let fileContents = try? String(contentsOf: fileURL, encoding: .utf8) {
                    let words = fileContents.components(separatedBy: "\n")
                    if let word = words.randomElement()?.trimmingCharacters(in: .whitespacesAndNewlines) {
                        rootWord = word
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
