//
//  ViewController.swift
//  DumbleScore 2.0
//
//  Created by Florian Sorin on 02/10/2016.
//  Copyright © 2016 Florian Sorin. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var playerTableView = UITableView()
    let emptyImage = UIImage(named: "")
    let coupe = UIImage(named: "coupe_dumble")
    let cards = UIImage(named: "cards")
    let dead = UIImage(named: "mort")
    var distributerIndex = 0
    
    //Number of players handlers
    var nbPlayers = 0
    var nbLost = 0
    
    //Edit settings
    var edit = UIButton()
    var editingMode = false
    
    //All infos about players
    struct player
    {
        var name = String()
        var score = 0
        var fiftyReached = false
        var seventyFiveReached = false
        var hundredReached = false
        var gameLose = false
        var lastFlagActivated = 0 //0 - 50 - 75 - 100 (0 means no flag activated at the last update)
    }
    
    //Array with all players
    var players = [player]()
    //All player names (used for saving names for the next launch)
    var playerNames = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setTopBar()
        setBottomBar()
        checkMemory()
    }
    
    //Call when the app is launch to recover previous players names
    func checkMemory()
    {
        let defaults = UserDefaults.standard
        
        if let nbPlayersMemorized = defaults.object(forKey: "nbPlayersKey") as? Int
        {
            nbPlayers = nbPlayersMemorized
        }
        
        if nbPlayers != 0
        {
            if let namesMemorized = defaults.object(forKey: "namesKey") as? [String]
            {
                playerNames = namesMemorized
                createScoreBoard(true) //Create the player pannel using stored names
            }
        }
    }
    
    //Update the data stored for the next launching
    func updateMemory()
    {
        let defaults = UserDefaults.standard
        defaults.set(nbPlayers, forKey: "nbPlayersKey")
        defaults.set(playerNames, forKey: "namesKey")
    }
    
    //Create the top bar
    func setTopBar()
    {
        //New game button
        let newGame = UIButton()
        newGame.setTitle("New Game", for: UIControl.State())
        newGame.isEnabled = true //Enable the key
        newGame.setTitleColor(UIColor.blue, for: UIControl.State())
        newGame.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width*0.4, height: UIScreen.main.bounds.size.height*0.07)
        newGame.addTarget(self, action: #selector(ViewController.newGame(_:)), for: .touchUpInside) //Add action to the key
        newGame.center = CGPoint(x: UIScreen.main.bounds.size.width*0.2, y: UIScreen.main.bounds.size.height*0.07)
        self.view.addSubview(newGame)
        
        //Edit button
        edit.setTitle("Edit", for: UIControl.State())
        edit.isEnabled = true //Enable the key
        edit.setTitleColor(UIColor.blue, for: UIControl.State())
        edit.frame = CGRect(x: 0, y: 0, width: 100, height: UIScreen.main.bounds.size.height*0.07)
        edit.addTarget(self, action: #selector(ViewController.edit(_:)), for: .touchUpInside) //Add action to the key
        edit.center = CGPoint(x: UIScreen.main.bounds.size.width*0.87, y: UIScreen.main.bounds.size.height*0.07)
        self.view.addSubview(edit)
        
    }
    
    //Create the bottom bar
    func setBottomBar()
    {
        //Rules button
        let rules = UIButton()
        rules.setTitle("Rules", for: UIControl.State())
        rules.isEnabled = true //Enable the key
        rules.setTitleColor(UIColor.blue, for: UIControl.State())
        rules.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width*0.4, height: UIScreen.main.bounds.size.height*0.07)
        rules.addTarget(self, action: #selector(ViewController.rules(_:)), for: .touchUpInside) //Add action to the key
        rules.center = CGPoint(x: UIScreen.main.bounds.size.width*0.15, y: UIScreen.main.bounds.size.height*0.96)
        self.view.addSubview(rules)
        
        //Distributer button
        let distributerButton = UIButton()
        distributerButton.setImage(cards, for: UIControl.State())
        distributerButton.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
        distributerButton.addTarget(self, action: #selector(ViewController.chooseDistributer(_:)), for: .touchUpInside) //Add action to the key
        distributerButton.center = CGPoint(x: UIScreen.main.bounds.size.width*0.5, y: UIScreen.main.bounds.size.height*0.96)
        self.view.addSubview(distributerButton)
        
        //Add button
        let add = UIButton()
        add.setTitle("+", for: UIControl.State())
        add.isEnabled = true //Enable the key
        add.setTitleColor(UIColor.blue, for: UIControl.State())
        add.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width*0.4, height: UIScreen.main.bounds.size.height*0.07)
        add.addTarget(self, action: #selector(ViewController.addPlayerButton(_:)), for: .touchUpInside) //Add action to the key
        add.center = CGPoint(x: UIScreen.main.bounds.size.width*0.9, y: UIScreen.main.bounds.size.height*0.96)
        self.view.addSubview(add)
        
    }
    
    //Buttons for top and bottom bar
    
    @objc func newGame(_ sender: UIButton!)
    {
        //If there is already a game playing, ask for reset or not before asking for the number of players
        if nbPlayers != 0
        {
            endGame("Keep existing players?")
        }
        else
        {
            askNumberOfPlayers();
        }
    }
    
    @objc func edit(_ sender: UIButton!)
    {
        editingMode = !editingMode
        
        if editingMode
        {
            edit.setTitle("OK", for: UIControl.State())
        }
        else
        {
            edit.setTitle("Edit", for: UIControl.State())
        }
        
        edit.removeFromSuperview()
        self.view.addSubview(edit)
    }
    
    @objc func rules(_ sender: UIButton!)
    {
        performSegue(withIdentifier: "mainToRules", sender: self)
    }
    
    @objc func chooseDistributer(_ sender: UIButton!)
    {
        if nbLost != nbPlayers - 1
        {
            //Create an alert controller
            let alert = UIAlertController(title: "Which player is distributing?", message:nil, preferredStyle: .alert)
            
            //One button for each player in game
            for i in 0...nbPlayers-1
            {
                if !self.players[i].gameLose
                {
                    alert.addAction(UIAlertAction(title: self.players[i].name, style: .default, handler: { (action) -> Void in
                        self.distributerIndex = i
                        self.playerTableView.reloadData()
                        self.reloadCellsState()
                        self.updateDistributer(add: false)}))
                }
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            //Show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func addPlayerButton(_ sender: UIButton!)
    {
        if nbLost != nbPlayers - 1
        {
            nbPlayers += 1
            players.append(player())
            addPlayer(i: nbPlayers-1, givenName: false, initialize: false)
            
            //Create an alert controller
            let alert = UIAlertController(title: "Which score for the new player ?", message:nil, preferredStyle: .alert)
            
            //Mean of all scores button
            alert.addAction(UIAlertAction(title: "Mean of all scores", style: .default, handler: { (action) -> Void in
                self.players[self.nbPlayers-1].score = self.meanOfScores()
                self.playerTableView.reloadData()
                self.reloadCellsState()
                self.updateDistributer(add: false)
            }))
            
            alert.addAction(UIAlertAction(title: "Zero", style: .default, handler: nil))
            
            //Show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func askNumberOfPlayers()
    {
        //Create an alert controller
        let alert = UIAlertController(title: "Enter the number of players", message:nil, preferredStyle: .alert)
        
        //Add a text field
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = nil
            textField.keyboardType = UIKeyboardType.numberPad})
        
        //Add an "OK" button and Grab the value from the text field
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            if let myNumber = NumberFormatter().number(from: textField.text!)
            {
                self.nbPlayers = myNumber.intValue
                //Silly values handlers
                if(self.nbPlayers < 2)
                {
                    self.nbPlayers = 2
                }
                
                self.createScoreBoard(false) //Create the main pannel with default names
            }
            else
            {
                print("Error converting string to int in askNumberOfPlayers()")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        //Show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //Create the table view which displays names and scores
    func createScoreBoard(_ givenNames: Bool)
    {
        //Fill the player's array and display it
        for i in 0...nbPlayers-1
        {
            players.append(player())
            addPlayer(i: i, givenName: givenNames, initialize: true)
        }
        
        playerTableView = UITableView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height*0.1, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.83), style: UITableView.Style.grouped)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress(_:)))
        playerTableView.addGestureRecognizer(longPressRecognizer)
        playerTableView.delegate = self
        playerTableView.dataSource = self
        playerTableView.backgroundColor = UIColor.white
        view.addSubview(playerTableView)
        var waitingTime = Timer()
        waitingTime = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(endWaiting), userInfo: nil, repeats: false)
    }
    
    @objc func endWaiting(sender: Timer!)
    {
        updateDistributer(add: false)
    }
    
    //Add a player
    func addPlayer(i:Int, givenName:Bool, initialize: Bool)
    {
        //Name display
        if givenName
        {
            players[i].name = playerNames[i]
        }
        else
        {
            players[i].name = "Player\(i+1)"
            playerNames.append("Player\(i+1)")
            
            if !initialize
            {
                // Update Table Data
                playerTableView.beginUpdates()
                playerTableView.insertRows(at: [
                IndexPath(row: playerNames.count-1, section: 0)
                ], with: .automatic)
                playerTableView.endUpdates()
            }
            
            updateMemory()
        }
    }
    
    //Delete a player
    func delPlayer(index: IndexPath)
    {
        if nbPlayers > 2
        {
            players.remove(at: index.row)
            playerNames.remove(at: index.row)
            nbPlayers -= 1
            updateMemory()
            playerTableView.reloadData()
            reloadCellsState()
            updateDistributer(add: false)
        }
    }
    
    //Mean of all scores of players still in the game except the last one, cannot be 25, 50 or 75
    func meanOfScores()->Int
    {
        var mean = 0
        
        for i in 0...nbPlayers-2
        {
            if !players[i].gameLose
            {
                mean = mean + players[i].score
            }
        }
        
        mean = Int(mean / (nbPlayers-nbLost-1))
        
        //Special cases handlers
        if mean == 25 || mean == 50 || mean == 75
        {
            mean += 1
        }
        if mean > 50
        {
            players[nbPlayers-1].fiftyReached = true
        }
        if mean > 75
        {
            players[nbPlayers-1].seventyFiveReached = true
        }
        
        return mean
    }
    
    //Manage a simple press on a cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var alertTitle = String()
        var realIndex = [Int]()
        
        if editingMode
        {
            alertTitle = "Enter the new name for "+playerNames[(indexPath as NSIndexPath).row]
        }
        else if(!players[(indexPath as NSIndexPath).row].gameLose) && nbLost != nbPlayers - 1
        {
            alertTitle = "Enter the score of losers"
        }
        
        //Create an alert controller
        let alert = UIAlertController(title: alertTitle, message:nil, preferredStyle: .alert)
        
        if editingMode
        {
            //Add a text field
            alert.addTextField(configurationHandler: { (textField) -> Void in
                textField.text = nil
                textField.autocapitalizationType = .words
            })
        }
        else if !players[(indexPath as NSIndexPath).row].gameLose  && nbLost != nbPlayers - 1
        {
            for i in 0...nbPlayers-1
            {
                if i != (indexPath as NSIndexPath).row && !self.players[i].gameLose                {
                    //Add a text field
                    alert.addTextField(configurationHandler: { (textField) -> Void in
                        textField.placeholder = self.playerNames[i]
                        textField.keyboardType = UIKeyboardType.numberPad
                        realIndex.append(i)
                    })
                }
            }
        }
        
        //Add an "OK" button and Grab the value from the text field
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            if self.editingMode
            {
                let textField = alert.textFields![0] as UITextField
                if !(textField.text?.isEmpty)!
                {
                    self.playerNames[(indexPath as NSIndexPath).row] = textField.text!
                    self.players[(indexPath as NSIndexPath).row].name = textField.text!
                    self.updateMemory()
                }
                
            }
            else if !self.players[(indexPath as NSIndexPath).row].gameLose && self.nbLost != self.nbPlayers - 1
            {
                for i in 0...self.nbPlayers-self.nbLost-2
                {
                    
                    let textField = alert.textFields![i] as UITextField
                    if let myNumber = NumberFormatter().number(from: textField.text!)
                    {
                        
                        self.players[realIndex[i]].score += myNumber.intValue
                        self.specialCasesHandler(realIndex[i])
                        
                    }
                }
            }
            
            self.playerTableView.reloadData()
            self.reloadCellsState()
            
            if !self.editingMode
            {
                self.updateDistributer(add: true)
                self.checkVictory()
            }
            else
            {
                self.updateDistributer(add: false)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
            let cell = self.playerTableView.cellForRow(at: indexPath) as! PlayerViewCell
            cell.isSelected = false
        }))
        
        //Show the alert
        if editingMode || !players[(indexPath as NSIndexPath).row].gameLose && nbLost != nbPlayers - 1
        {
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let cell = playerTableView.cellForRow(at: indexPath) as! PlayerViewCell
            cell.isSelected = false
        }
    }
    
    //Manage a long press on a cell
    @objc func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer)
    {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began
        {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.playerTableView)
            if let indexPath = playerTableView.indexPathForRow(at: touchPoint)
            {
                if !players[(indexPath as NSIndexPath).row].gameLose && nbLost != nbPlayers - 1
                {
                    //Create an alert controller
                    let alert = UIAlertController(title: "Dumble lost for "+playerNames[(indexPath as NSIndexPath).row]+"?", message:nil, preferredStyle: .alert)
                    
                    //Add a "Reset" button and reset everything
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                        self.players[(indexPath as NSIndexPath).row].score += 25
                        self.specialCasesHandler((indexPath as NSIndexPath).row)
                        self.playerTableView.reloadData()
                        self.reloadCellsState()
                        self.updateDistributer(add: true)
                        self.checkVictory()
                    }))
                    
                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                    
                    //Show the alert
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
    }
    
    //Allow user to modify a score
    func modifyScore(index: IndexPath)
    {
        var rightScore = 0
        
        if nbLost != nbPlayers - 1
        {
            //Create an alert controller
            let alert = UIAlertController(title: "Enter the right score", message:nil, preferredStyle: .alert)
            
            //Add a text field
            alert.addTextField(configurationHandler: { (textField) -> Void in
                textField.text = nil
                textField.keyboardType = UIKeyboardType.numberPad})
            
            //Add an "OK" button and Grab the value from the text field
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                let textField = alert.textFields![0] as UITextField
                if let myNumber = NumberFormatter().number(from: textField.text!)
                {
                    //Acquire the right score
                    rightScore = myNumber.intValue
                    if rightScore < 0
                    {
                        rightScore = self.players[index.row].score
                    }
                    
                    //Prevent bug with special cases
                    if rightScore < self.players[index.row].score && self.players[index.row].lastFlagActivated != 0
                    {
                        if rightScore < self.players[index.row].lastFlagActivated
                        {
                            switch(self.players[index.row].lastFlagActivated)
                            {
                            case 50: self.players[index.row].fiftyReached = false
                            case 75: self.players[index.row].seventyFiveReached = false
                            default: self.players[index.row].hundredReached = false
                            }
                        }
                        
                        self.players[index.row].lastFlagActivated = 0
                        
                    }
                    
                    //Update the score
                    self.players[index.row].score = rightScore
                    
                    if rightScore < 100 && self.players[index.row].gameLose
                    {
                        self.players[index.row].gameLose = false
                        self.nbLost -= 1
                    }
                    
                    //Special cases handlers
                    self.specialCasesHandler(index.row)
                    
                    //Actualisation
                    self.playerTableView.reloadData()
                    self.reloadCellsState()
                    self.updateDistributer(add: false)
                    
                    self.checkVictory()
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            //Show the alert
            self.present(alert, animated: true, completion: nil)
        }
        
        let cell = playerTableView.cellForRow(at: index) as! PlayerViewCell
        cell.isSelected = false
    }
    
    func specialCasesHandler(_ i:Int)
    {
        if players[i].score == 50 && players[i].fiftyReached == false
        {
            players[i].score = 25
            players[i].fiftyReached = true
            players[i].lastFlagActivated = 50
        }
        else if players[i].score == 75 && players[i].seventyFiveReached == false
        {
            players[i].score = 50
            players[i].fiftyReached = true
            players[i].seventyFiveReached = true
            players[i].lastFlagActivated = 75
        }
        else if players[i].score == 100 && players[i].hundredReached == false
        {
            players[i].score = 75
            players[i].fiftyReached = true
            players[i].seventyFiveReached = true
            players[i].hundredReached = true
            players[i].lastFlagActivated = 100
        }
        else if players[i].score > 100
        {
            players[i].gameLose = true
            nbLost += 1
        }
        
        playerTableView.reloadData()
        reloadCellsState()
        
    }
    
    func reloadCellsState()
    {
        var bestScore = 100
        var isBeginning = true
        
        for player in players
        {
            if player.score < bestScore
            {
                bestScore = player.score
            }
            
            if player.score != 0
            {
                isBeginning = false
            }
        }
        
        for i in 0...players.count-1
        {
            let playerIndex = IndexPath(row: i, section: 0)
            let cell = playerTableView.cellForRow(at: playerIndex) as! PlayerViewCell
            
            if players[i].gameLose
            {
                cell.name.textColor = UIColor.lightGray
                cell.score.textColor = UIColor.lightGray
                cell.leader.image = dead
            }
            else if !isBeginning
            {
                if players[i].score == bestScore
                {
                    cell.leader.image = coupe
                }
                else
                {
                    cell.leader.image = emptyImage
                }

            }
        }
    }
    
    func updateDistributer(add: Bool)
    {
        if add
        {
            distributerIndex += 1
        }
        
        if distributerIndex > nbPlayers - 1
        {
            distributerIndex = 0
        }
        
        if !players[distributerIndex].gameLose
        {
            let playerIndex = IndexPath(row: distributerIndex, section: 0)
            let cell = playerTableView.cellForRow(at: playerIndex) as! PlayerViewCell
            cell.distributer.image = cards
        }
        else
        {
            updateDistributer(add: true)
        }
    }
    
    func checkVictory()
    {
        var winner = ""
        
        if nbLost == nbPlayers - 1
        {
            for i in 0...nbPlayers-1
            {
                if players[i].gameLose == false
                {
                    winner = playerNames[i]
                }
            }
            
            self.endGame(winner+" wins the game !")
        }
    }
    
    //End the game with a message (name of the winner or ask for reset)
    func endGame(_ message: String)
    {
        //Create an alert controller
        let alert = UIAlertController(title: message, message:nil, preferredStyle: .alert)
        
        if message == "Keep existing players?"
        {
            //Add a "Yes" button which resets everything except names and number of players
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                for i in 0...self.nbPlayers-1
                {
                    //Reset booleans
                    self.players[i].fiftyReached = false
                    self.players[i].seventyFiveReached = false
                    self.players[i].hundredReached = false
                    self.players[i].gameLose = false
                    //Reset other flags
                    self.players[i].lastFlagActivated = 0
                    //Reset score
                    self.players[i].score = 0
                    //Reset distributer
                    self.distributerIndex = 0
                }
                self.playerTableView.reloadData()
                self.updateDistributer(add: false)
                self.nbLost = 0
            }))
            
            //Add a "No" button which resets everything
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
                //Erase the array
                if(self.nbPlayers != 0)
                {
                    self.players.removeAll()
                    self.playerNames.removeAll()
                    self.playerTableView.reloadData()
                    self.playerTableView.removeFromSuperview()
                }
                self.nbPlayers = 0
                self.nbLost = 0
                self.updateMemory()
                self.askNumberOfPlayers()
            }))
            
        }
        else
        {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        
        //Show the alert
        self.present(alert, animated: true, completion:
        {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.closeAlert(_:))))
        })
    }
    
    // Close alert when tapping outside
    @objc func closeAlert(_ gesture: UITapGestureRecognizer)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return playerNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = PlayerViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "playerView")
        let index = (indexPath as NSIndexPath).row
        cell.name.text = playerNames[index]
        cell.score.text = "\(players[index].score)"
        
        //configure left buttons
        cell.leftButtons = [MGSwipeButton(title: "Edit\nScore", backgroundColor: UIColor.blue, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.modifyScore(index: indexPath)
            return true})]
        
        cell.leftSwipeSettings.transition = MGSwipeTransition.rotate3D
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor.red, callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.delPlayer(index: indexPath)
            return true})]
        cell.rightSwipeSettings.transition = MGSwipeTransition.rotate3D
        
        return cell
    }
}

