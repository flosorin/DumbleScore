//
//  PlayerView.swift
//  DumbleScore 2.0
//
//  Created by Florian Sorin on 02/10/2016.
//  Copyright © 2016 Florian Sorin. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class PlayerViewCell: MGSwipeTableCell
{
    
    var distributer: UIImageView!
    var name: UILabel!
    var score: UILabel!
    var leader: UIImageView!
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let size = 21, distFromSide = 20, distBetween = 8
        let emptyImage = UIImage(named: "")
        
        distributer = UIImageView(image: emptyImage)
        distributer.frame = CGRect(x: distFromSide, y: 20, width: size, height: size)
        contentView.addSubview(distributer)
        
        name = UILabel()
        name.frame = CGRect(x: distFromSide + distBetween + size, y: 20, width: Int(UIScreen.main.bounds.size.width*0.4), height: size)
        name.textColor = UIColor.black
        contentView.addSubview(name)
        
        score = UILabel()
        score.frame = CGRect(x: Int(UIScreen.main.bounds.size.width) - size - distFromSide - 2*distBetween - Int(UIScreen.main.bounds.size.width*0.1), y: 20, width: Int(UIScreen.main.bounds.size.width*0.1), height: size)
        score.textAlignment = NSTextAlignment.right
        score.textColor = UIColor.black
        contentView.addSubview(score)
        
        leader = UIImageView(image: emptyImage)
        leader.frame = CGRect(x: Int(UIScreen.main.bounds.size.width) - size - distFromSide, y: 20, width: size, height: size)
        contentView.addSubview(leader)
        
    }
    
}
