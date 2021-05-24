//
//  ViewController.swift
//  HangmanProject
//
//  Created by Irina Perepelkina on 14.05.2021.
//  Copyright © 2021 Irina Perepelkina. All rights reserved.

// Details:
// - find a dictionary of nouns appropriate for a game () and plug it into the app
// - number of failed attampts: 5
// - min number of characters in a word: 5
//
// Description of the project:
// Hangman game allows a user to guess the word which was picked randomly by an app
// To every word a dictionary has a description and a hint
// User tries to guess the word letter by letter
// If the guessed letter is right, it fills in corresponding place in a word-to-be-guessed (which consists of underscore lines - so the number of letters is known in advance)
// If the guessed letter is not right, hangman shows gallow. If the second guess is not right, hangman grows knees and so on up until his head appears in gallows
// When the limit of wrong guesses is reached, game is over. Words in dictionary should be long enough
// All wrong letters appear in a label for user to see and not to pick the wrong letter again

// Data objects to be used:
// word String, letter var, wrongAttempts array of chars, numberOfAttemptsLeft var Int

// Plan:
// - create or plug in dictionary of nouns with description and hints: explore rapidAPI methods. I need to downlaod for start 100 words, with description and synonims. Doesn't work very well this way since i need a sample of words for a game, not any words are appropriate. And i don't want to subscribe to every API just to test how it works: DONE
// - so words are found online and stored in a text file: DONE
// - learn how to work with text files using swift: DONE
// - fetch a description and synonim using API methods I'm subscribed to: DONE
// - create term objects: DONE
// ** i decided to omit connecting to a db here to move on with the project. It will be web-based
// - create 5 images of hangman on different stages. It can be done in a form of dictionary [numberOfAttempts: String(symbols)]: DONE
// - show randomly chosen word and description in corresponding label text fields: DONE
// - add new word button - when clicked displays a new word, if clicked repeatedly but game is not over, don't do anything. Create a flag which changes only when the game is over - in progress, need to finilize after gameover function
// - need to add fucntion to check if the user inserts letter which have been inserted before
// - create a textField which takes exactly one letter, check it's not nil and it's not a number: DONE
// - check if the letter is in a word.
//     - If so, replace corresponding letter in a word to be guessed field: DONE
//     - Check if the word is fully guessed:
//          - if there is at least one underscore, it's not. Continue playing
//          - if the word is guessed fully, game is over. Show congratulation message and invitation to play again
// - if it's not in the word, store it in a wrong guesses array, update wrongLetters array, decrement numberOfAttempts value & show a pic
// - if the hint is pressed at any point of the program, the alarm message with a hint pops up

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var hangmanPic: UILabel!
    @IBOutlet weak var wordToBeGuessed: UILabel!
    @IBOutlet weak var descriptionOfWord: UILabel!
    @IBOutlet weak var guessTextField: UITextField!
    @IBOutlet weak var newWordButton: UIButton!
    @IBOutlet weak var wrongAttempts: UILabel!
    @IBOutlet weak var hintLabel: UIButton!
    
    var guesses = ""
    var randomWord = ""
    var codedWord = ""
    var hintMessage = ""
    var termsArray = [Term]()
    var clickIsPressed: Bool = false
    var gameIsOver: Bool = false
    var foundLettersCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guessTextField.delegate = self
        newWordButton.isHidden = true
        wordToBeGuessed.text = "HANGMAN"
        print("ViewDidLoad started")
        hangmanPic.text = hangmanArray[maxNumberOfWrongAttempts]
        
        let model = Model()
        
        let group = DispatchGroup()
        guard let wordsArray = model.createWordsArray() else {
            print("No wordsArray to read")
            return
        }
        let n = wordsArray.count
        var i = 0
        
        while i < n && wordsArray[i] != "" {
            
            group.enter()
            print("Entering group")
            model.createTermObjects(word: wordsArray[i]) { (term) in
                switch term {
                    case .success(let termRecedived):
                        self.termsArray.append(termRecedived)
                        print("Inside of completion handler term is received")
                    case .failure(let error):
                        print("Inside of completion handler an error \(error)")
                }
                group.leave()
                print("leaving group")
            }
            i += 1
            
        }
        
        group.notify(queue: .main) {
            print("Finished fetching def and syn for term objects")
            print("termsArray contains \(self.termsArray.count) objects")
            // Here i will have to write the rest of the code?
            self.newWordButton.isHidden = false
        }
    }
    
    
    @IBAction func newWordButtonClicked(_ sender: UIButton) {
         
        // if clicked the first time, perform the function and set the flag to false to avoid multiple clicking
        if clickIsPressed == false {
            if termsArray.count > 0 {
                let randomWordObject = termsArray.randomElement()!
                randomWord = randomWordObject.term!
                hintMessage = randomWordObject.synonim!
                codedWord = String(repeating: "_ ", count: randomWordObject.term!.count)
                self.wordToBeGuessed.text = codedWord
                self.descriptionOfWord.text = randomWordObject.description
            }
        }
        clickIsPressed = true
        gameIsOver = false
        
    }
    
    
    @IBAction func hintButtonClicked(_ sender: UIButton) {
        
        if clickIsPressed {
            let alert = UIAlertController.init(title: "Hint", message: hintMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if gameIsOver == true || clickIsPressed == false {
            guessTextField.text?.removeAll()
            return false}
        
        guard let guessLetter = guessTextField.text else {
            print("No guess letter provided")
            return false
        }
        if guessLetter.count != 1 {
            guessTextField.text?.removeAll()
            print("Only one letter to guess is possible")
            return false
        }
        
        var n = 0
        var isfound = false
        for letter in randomWord {
            if letter.lowercased() == guessLetter.lowercased() {
                codedWord = String (codedWord.prefix(n)) + String (letter) + String (codedWord.dropFirst(n+1))
                wordToBeGuessed.text = codedWord
                isfound = true
                foundLettersCount += 1
                print("foundLettersCount is \(foundLettersCount)")
                if foundLettersCount == randomWord.count {
                    gameIsOver(condition: "CONGRATULATION! YOU WON!")
                }
            }
            n += 2
        }
        print("is found is \(isfound)")
        if isfound == false {
            
            if guesses.contains(guessLetter) == false {
                guesses += "\(guessLetter), "
                wrongAttempts.text = guesses
                maxNumberOfWrongAttempts -= 1
                print("maxNumber of wrong attemptd is \(maxNumberOfWrongAttempts)")
                hangmanPic.text = hangmanArray[maxNumberOfWrongAttempts]
            }
        }
        
            if maxNumberOfWrongAttempts == 0 {
                gameIsOver(condition: "GAME OVER")
            }
        
        // check if the word is fully guessed or if game is over
        guessTextField.text?.removeAll()
        
        return true
    }
    
    func gameIsOver(condition: String) {
        gameIsOver = true
        clickIsPressed = false
        guesses = ""
        wrongAttempts.text = ""
        wordToBeGuessed.text = condition
        descriptionOfWord.text = ""
        maxNumberOfWrongAttempts = 5
        hangmanPic.text = hangmanArray[maxNumberOfWrongAttempts]
    }
    

    var hangmanPicString = """
       ( )___
        |    |
      / | \\  |
        |    |
       / \\   |
    - - - - -/
    """
    
    var maxNumberOfWrongAttempts = 6
    
    var hangmanArray = [
        
        5: """
        
        
        
        
        
        - - - - -/
        """,
        
        4: """
              ___
                 |
                  |
                 |
                  |
        - - - - -/
        """,
        3: """
              ___
                 |
                  |
                 |
           / \\   |
        - - - - -/
        """,

        2: """
              ___
                 |
          / | \\  |
            |    |
           / \\   |
        - - - - -/
        """,
        1: """
              ___
            |    |
          / | \\  |
            |    |
           / \\   |
        - - - - -/
        """,
        0: """
           ( )___
            |    |
          / | \\  |
            |    |
           / \\   |
        - - - - -/
        """
    ]
}



