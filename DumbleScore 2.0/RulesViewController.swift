//
//  RulesViewController.swift
//  DumbleScore 2.0
//
//  Created by Florian Sorin on 09/10/2016.
//  Copyright © 2016 Florian Sorin. All rights reserved.
//

import UIKit

class RulesViewController: UIViewController
{
    //Text view displaying rules
    @IBOutlet weak var rulesTextView: UITextView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        setPannel()
    }
    
    func setPannel()
    {
//        self.view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//        rulesTextView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        //Fonts
        let normalFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
        let boldFont = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        //Creating content
        let generalTitle = NSAttributedString(string: "General", attributes: boldFont)
        let generalContent = NSAttributedString(string: "\n\nEach player starts the game with five cards.\n\nEach card has a value: the number indicated for the cards with numbers, 10 for the face cards, 0 for the joker. The aces count for one.\n\nThe aim of the game is to have 9 points or less in the hand.\n\n\n", attributes: normalFont)
        let howToPlayTitle = NSAttributedString(string: "How to play", attributes: boldFont)
        let howToPlayContent = NSAttributedString(string: "\n\nThe non-distributed cards are placed in heap on the table (cards hidden) and the first card is revealed.\n\nThe first player chooses one card to reject and can take either the revealed card or the first of the heap. The next player does the same and can either take the last rejected card or the first of the heap. The game continues like this.\n\nWhen a player has 9 points or less, he can say 'Dumble', at the beginning of his turn.\n\nIf no one has the same amount of points (or less), every other players add their points to their total. If a player exceeds 100 points, he is eliminated from the game.\n\nIf someone has the same amount of points (or less), the player who said 'Dumble' adds 25 points to his total and the others add nothing.\n\nAfter adding the points, cards are melted and distributed again.\n\n\n", attributes: normalFont)
        let specialRulesTitle = NSAttributedString(string: "Special Rules", attributes: boldFont)
        let specialRulesContent = NSAttributedString(string: "\n\nIf a player reaches 50, 75 or 100, he goes back to 25, 50 or 75. It only works if it is the first time.\n\nIf a player has more than one card of the same type (same numbers or same faces), he can reject all of them and take only one card in exchange. It is the same if he has following cards of the same color (3 or more). If the last player did that, the following player can choose which of those cards he takes.", attributes: normalFont)
        
        //Creating attributed string for the text view
        let textViewContent = NSMutableAttributedString()
        textViewContent.append(generalTitle)
        textViewContent.append(generalContent)
        textViewContent.append(howToPlayTitle)
        textViewContent.append(howToPlayContent)
        textViewContent.append(specialRulesTitle)
        textViewContent.append(specialRulesContent)
        rulesTextView.attributedText = textViewContent
        
        
        if #available(iOS 13.0, *) {
            rulesTextView.textColor = UIColor.label
        } else {
            rulesTextView.textColor = UIColor.black
        }
        rulesTextView.textAlignment = NSTextAlignment.center
        self.view.addSubview(rulesTextView)
    }
    
    @IBAction func dismiss(_ sender: UIButton!)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
