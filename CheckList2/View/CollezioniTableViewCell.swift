//
//  CollezioniTableViewCell.swift
//  CheckList
//
//  Created by Michele De Sena on 04/02/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import UIKit
import GTProgressBar

class CollezioniTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        mainBackground.layer.cornerRadius = 20
        mainBackground.layer.masksToBounds = true
        mainBackground.layer.borderColor = UIColor.lightGray.cgColor
        mainBackground.layer.borderWidth = 0.5
        progressBar.bringSubviewToFront(progressLabel)
        progressLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        progressLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        progressBar.barFillColor = .secondaryAppColor
        progressBar.layer.cornerRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var mainBackground: UIView!

    @IBOutlet weak var progressLabel: UILabel!

    @IBOutlet weak var foto: UIImageView!

    @IBOutlet weak var titolo: UILabel! {
        didSet {
            titolo.adjustsFontSizeToFitWidth = true
        }
    }

    @IBOutlet weak var sottotitolo: UILabel! {
        didSet {
            sottotitolo.adjustsFontSizeToFitWidth = true

        }
    }

    @IBOutlet weak var progressBar: GTProgressBar!

    func setCell(for c: Collezione) {
        titolo.text = c.nome
        sottotitolo.text = c.editore
        var progress: CGFloat = 0

        if let cn = c as? CollezioneNumerata {
            if cn.completamento > 0.9950 && cn.numeroMancanti != 0 {
                progress = 0.99
            } else {
                progress = cn.completamento
            }

            progressBar.animateTo(progress: progress)
            progressBar.progress = progress
            progressLabel.text = "\(Int(progress * 100))%"

           
        } else {
            progressBar.isHidden = true
        }

        guard let artwork = c.foto else {
            foto.image = UIImage() //Inserire immagine di default
            return
        }

        foto.image = artwork

    }

}
