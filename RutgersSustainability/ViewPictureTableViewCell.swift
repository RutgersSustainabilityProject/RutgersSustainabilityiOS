//
//  ViewPictureTableViewCell.swift
//  RutgersSustainability
//
//  Created by Vineeth Puli on 1/24/17.
//  Copyright © 2017 Rutgers Sustainability Project. All rights reserved.
//

import UIKit

class ViewPictureTableViewCell: UITableViewCell {

    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var trashPicView: UIImageView!
    @IBOutlet weak var tags: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
