//
//  StudentLocationCell.swift
//  On the Map
//
//  Created by hind on 1/12/19.
//  Copyright © 2019 hind. All rights reserved.
//

import UIKit

class StudentLocationCell: UITableViewCell {

    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var mediaURL: UILabel!
    
    func configureStudentLocationCell(studentLocation: StudentLocationModel){
        
        fullName.text = studentLocation.student.fullName
        mediaURL.text = studentLocation.student.mediaURL
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
