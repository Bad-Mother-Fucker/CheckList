//
//  CollezioneNumerataViewController.swift
//  CheckList
//
//  Created by Michele De Sena on 04/02/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import UIKit


class CollezioneNumerataViewController: UIViewController {

    let fontSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize

    var collezione: CollezioneNumerata? {
        guard collectionIndex != nil else { return nil }
        return User.shared.collezioni[collectionIndex!] as? CollezioneNumerata
    }
    var cellIdentifier = "cellaConNumero"
    var collectionIndex: Int?
    var tap: UITapGestureRecognizer!
    var press: UILongPressGestureRecognizer!


    var collezionabili: [CollectionElement] {
        switch segmentedSwitch.selectedSegmentIndex{
        case 0:
            return collezione!.collezionabili
        case 1:

            return collezione!.collezionabili.filter({
                switch $0.stato {
                case .mancante:
                    return true
                default:
                    return false

                }
            })
        case 2:

            return collezione!.collezionabili.filter({
                switch $0.stato {
                case .ripetuto(rep: _):

                    return true
                default:
                    return false

                }
            })
        default:
            return []
        }
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        title = collezione?.nome

        if (!collezione!.isChecklistMode) {
//            Load nib for cell
//            cellIdentifier = "cellaConDettagli"
        }


        tap = UITapGestureRecognizer(target: self, action: #selector(tapOnCell))
        press = UILongPressGestureRecognizer(target: self, action: #selector(pressOnCell))
        press.allowableMovement = 0.5
        press.minimumPressDuration = 1
        collectionView.addGestureRecognizer(tap)
        collectionView.addGestureRecognizer(press)
        segmentedSwitch.backgroundColor = .white
        let titleLabel = UILabel(frame: navigationController!.navigationBar.frame)

        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        navigationItem.titleView = segmentedSwitch
        adjustLargeTitleSize()
        
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataManager.shared.update(collezione!)
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }


    @IBOutlet weak var segmentedSwitch: UISegmentedControl!

    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
       collectionView.reloadData()
    }


    @objc func tapOnCell(_ gesture: UITapGestureRecognizer) {

        debugPrint("cell tapped")
        guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
            debugPrint("unable to find IndexPath")
            return
        }

        let cell = collectionView.cellForItem(at: indexPath)

        let collezionabile = collezionabili[indexPath.item]
        switch collezionabile.stato {
        case .mancante:
            collezionabile.stato = .posseduto
            cell?.viewWithTag(3)?.backgroundColor = .green
            print("collezionabile numero: \(collezionabile.numero!) stato: \(collezionabile.stato)")

        case .posseduto:
            collezionabile.stato = .ripetuto(rep: 2)
            cell?.viewWithTag(3)?.backgroundColor = .red
            (cell?.viewWithTag(2) as! UILabel).text = "x\(2)"
            print("collezionabile numero: \(collezionabile.numero!) stato: \(collezionabile.stato)")
        case .ripetuto(rep: let rep):
            collezionabile.stato = .ripetuto(rep: rep+1)
            cell?.viewWithTag(3)?.backgroundColor = .red
            (cell?.viewWithTag(2) as! UILabel).text = "x\(collezionabile.stato.rawValue)"
            print("collezionabile numero: \(collezionabile.numero!) stato: \(collezionabile.stato)")
            
        }

        guard segmentedSwitch.selectedSegmentIndex != 0 else { return }
        self.collectionView.performBatchUpdates({
            let indexSet = IndexSet(integersIn: 0...0)
            self.collectionView.reloadSections(indexSet)

        }, completion: nil)

    }



    @objc func pressOnCell(_ gesture: UILongPressGestureRecognizer) {
        debugPrint("cell pressed")
        guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
            debugPrint("unable to find IndexPath")
            return
        }
        let collezionabile = collezionabili[indexPath.item]
        collezionabile.stato = .mancante

        let cell = collectionView.cellForItem(at: indexPath)

        if cell is ItemDetailCollectionViewCell {
            return
        }

        cell?.viewWithTag(3)?.backgroundColor = .white
        if let label = cell?.viewWithTag(2) as? UILabel {
            label.text = nil
        }


        guard segmentedSwitch.selectedSegmentIndex != 0 else { return }
        gesture.isEnabled = false


        self.collectionView.performBatchUpdates({
            let indexSet = IndexSet(integersIn: 0...0)
            self.collectionView.reloadSections(indexSet)
            gesture.isEnabled = true
            return
        },completion:  nil)


        return
    }


}


extension CollezioneNumerataViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collezionabili.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)

        if let cella = cell as? ItemDetailCollectionViewCell {

            cella.setCellaPer(collezionabili[indexPath.item])
            return cella

        } else {
            
            let label = cell.viewWithTag(1) as! UILabel
            let repLabel = cell.viewWithTag(2) as! UILabel
            let collezionabile = collezionabili[indexPath.item]
            let cardView = cell.viewWithTag(3)
            label.text = "\(collezionabile.numero!)"
            cardView?.layer.cornerRadius = 3
            cardView?.layer.masksToBounds = true
            cardView?.layer.borderWidth = 0.5
            cardView?.layer.borderColor = UIColor.black.cgColor

            switch collezionabile.stato {
            case .mancante:
                cardView?.backgroundColor = .white
                repLabel.text = nil
            case .posseduto:
                cardView?.backgroundColor = .green
                repLabel.text = nil
            case .ripetuto(rep: _):
                cardView?.backgroundColor = .red
                repLabel.text = "x\(collezionabile.stato.rawValue)"
            }
            return cell
        }

    }

}

extension CollezioneNumerataViewController {
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        press.isEnabled = true
    }
}
