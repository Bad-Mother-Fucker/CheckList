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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var possedutiLabel: UILabel! 

    @IBOutlet weak var foto: UIImageView!

    @IBOutlet weak var titolo: UILabel!

    @IBOutlet weak var sottotitolo: UILabel!

    @IBOutlet weak var progressBar: GTProgressBar!

    func setCell(for c: Collezione) {
        titolo.text = c.nome
        sottotitolo.text = c.editore


        if let cn = c as? CollezioneNumerata {
           
            progressBar.animateTo(progress: cn.completamento)
            progressBar.progress = cn.completamento
            possedutiLabel.isHidden = true
        } else {

            progressBar.isHidden = true
            possedutiLabel.text = "\(c.numeroPosseduti) elementi"

        }

        guard let artwork = c.foto else {
            foto.image = UIImage() //Inserire immagine di default
            return
        }

        foto.image = artwork

    }

}
