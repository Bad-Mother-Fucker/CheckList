//
//  CollezioneNumerataViewController.swift
//  CheckList
//
//  Created by Michele De Sena on 04/02/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import SimplePDF


class CollezioneNumerataViewController: UIViewController {

    let fontSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
    let screenRecordingDetector = ScreeRecordingDetector()
    var collezione: CollezioneNumerata? {
        guard collectionIndex != nil else { return nil }
        return User.shared.collezioni[collectionIndex!] as? CollezioneNumerata
    }

    
    var cellIdentifier = "cellaConNumero"
    var collectionIndex: Int?
    var tap: UITapGestureRecognizer!
    var press: UIShortPressGestureRecognizer!
    let impact = UIImpactFeedbackGenerator(style: .medium)
    let check = UINotificationFeedbackGenerator()
    var doubleTap: UIShortDoubleTapGestureRecognizer!

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    var collezionabili: [CollectionElement] {
        switch menuBar.selectedIndex {
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
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.mainAppColor]
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.largeTitleTextAttributes = attributes
        

        NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: OperationQueue.main) { notification in

        }

        screenRecordingDetector.delegate = self
//
//        if (!collezione!.isChecklistMode) {
////            Load nib for cell
//            cellIdentifier = "cellaConDettagli"
//        }

     


        tap = UITapGestureRecognizer(target: self, action: #selector(tapOnCell))

        press = UIShortPressGestureRecognizer(target: self, action: #selector(pressOnCell))
        press.allowableMovement = 0.5
        press.minimumPressDuration = 1
        doubleTap = UIShortDoubleTapGestureRecognizer(target: self, action: #selector(doubleTapOnCell))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1

        tap.require(toFail: doubleTap)

        collectionView.addGestureRecognizer(doubleTap)
        collectionView.addGestureRecognizer(tap)
        collectionView.addGestureRecognizer(press)


        setupMenuBar()




        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(generatePDf))
        navigationItem.rightBarButtonItem = shareButton
        
    }

    let menuBar = MenuBar(frame: CGRect(x: 0, y: 0, width: 375, height: 50))

    func setupMenuBar() {
        menuBar.controller = self
        view.addSubview(menuBar)
        view.bringSubviewToFront(menuBar)
        menuBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        menuBar.autoSetDimension(.height, toSize: 50)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataManager.shared.update(collezione!)
        screenRecordingDetector.stopDetector()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        screenRecordingDetector.startDetector()
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
        if collezionabili.count > 0 {
             collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
        }

    }




    @objc func doubleTapOnCell(_ gesture: UITapGestureRecognizer) {
        impact.prepare()
        guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
            debugPrint("unable to find IndexPath")
            return
        }


        let cell = collectionView.cellForItem(at: indexPath)
        let collezionabile = collezionabili[indexPath.item]
        switch collezionabile.stato {
        case .mancante:

            return

        case .posseduto:
            collezionabile.stato = .mancante
            cell?.viewWithTag(3)?.backgroundColor = .white
            impact.impactOccurred()
            collectionView(collectionView, updateCountLabelAt: IndexPath(item: 0, section:1))

        case .ripetuto(rep: let rep):
            impact.impactOccurred()
            if rep == 2 {
                collezionabile.stato = .posseduto
                cell?.viewWithTag(3)?.backgroundColor = .pastelGreen
                if let label = cell?.viewWithTag(2) as? UILabel {
                    label.text = nil
                }
                collectionView(collectionView, updateCountLabelAt: IndexPath(item: 0, section:1))
                guard menuBar.selectedIndex == 2 else { return }
                self.collectionView.performBatchUpdates({
                    let indexSet = IndexSet(integersIn: 0...0)
                    self.collectionView.reloadSections(indexSet)
                    debugPrint("reloaded")

                }, completion: nil)

            } else {
                collezionabile.stato = .ripetuto(rep: rep-1)
                collectionView(collectionView, updateCountLabelAt: IndexPath(item: 0, section:1))
                cell?.viewWithTag(3)?.backgroundColor = .secondaryAppColor
                (cell?.viewWithTag(2) as! UILabel).text = "x\(collezionabile.stato.rawValue)"
            }


        }




    }


    @objc func tapOnCell(_ gesture: UITapGestureRecognizer) {
        check.prepare()


        guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
            debugPrint("unable to find IndexPath")
            return
        }
        guard indexPath.section == 0 else { return }
        check.notificationOccurred(.success)
        let cell = collectionView.cellForItem(at: indexPath)
        let collezionabile = collezionabili[indexPath.item]
        switch collezionabile.stato {
        case .mancante:
            collezionabile.stato = .posseduto
            cell?.viewWithTag(3)?.backgroundColor = .pastelGreen
            print("collezionabile numero: \(collezionabile.numero!) stato: \(collezionabile.stato)")

        case .posseduto:
            collezionabile.stato = .ripetuto(rep: 2)
            cell?.viewWithTag(3)?.backgroundColor = .secondaryAppColor
            (cell?.viewWithTag(2) as! UILabel).text = "x\(2)"
            print("collezionabile numero: \(collezionabile.numero!) stato: \(collezionabile.stato)")
        case .ripetuto(rep: let rep):
            collezionabile.stato = .ripetuto(rep: rep+1)
            cell?.viewWithTag(3)?.backgroundColor = .secondaryAppColor
            (cell?.viewWithTag(2) as! UILabel).text = "x\(collezionabile.stato.rawValue)"
            print("collezionabile numero: \(collezionabile.numero!) stato: \(collezionabile.stato)")
            
        }

        collectionView(collectionView, updateCountLabelAt: IndexPath(item: 0, section:1))

        guard menuBar.selectedIndex != 0 else { return }
        self.collectionView.performBatchUpdates({
            let indexSet = IndexSet(integersIn: 0...0)
            self.collectionView.reloadSections(indexSet)

        }, completion: nil)



    }



    @objc func pressOnCell(_ gesture: UILongPressGestureRecognizer) {
        debugPrint("cell pressed")
        check.prepare()
        guard menuBar.selectedIndex == 0 else { return }

        guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
            debugPrint("unable to find IndexPath")
            return
        }

        let collezionabile = collezionabili[indexPath.item]
        guard collezionabile.stato != .mancante else { return }
        collezionabile.stato = .mancante
        check.notificationOccurred(.error)
        let cell = collectionView.cellForItem(at: indexPath)

        if cell is ItemDetailCollectionViewCell {
            return
        }

        cell?.viewWithTag(3)?.backgroundColor = .white
        if let label = cell?.viewWithTag(2) as? UILabel {
            label.text = nil
        }


        collectionView(collectionView, updateCountLabelAt: IndexPath(item: 0, section:1))

        return
    }

   @objc func generatePDf() {

    guard User.shared.purchasedProducts.contains(productIDs.PDFExtension) else {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InAppPurchase") as! IAPurchaseViewController
        present(vc, animated: true, completion: nil)
        return
    }

        let pdfCreator = PDFCreator()
        pdfCreator.collection = self.collezione

        let action = UIAlertController(title: NSLocalizedString("GeneratePDFActionSheetTitle", comment: ""), message: NSLocalizedString("GeneratePDFActionSheetMessage", comment: ""), preferredStyle: .actionSheet)

        let mancanti = UIAlertAction(title: NSLocalizedString("Mancanti", comment: ""), style: .default) { _ in
            guard let pdf = pdfCreator.createPDF(ofSize: .A4, contentTypes: [.mancanti]) else { return }
             self.share(pdf)
             action.dismiss(animated: true, completion: nil)
        }

        let tutte = UIAlertAction(title: NSLocalizedString("Tutte", comment: ""), style: .default) { (_) in
            guard let pdf = pdfCreator.createPDF(ofSize: .A4, contentTypes: [.possedute,.mancanti,.ripetute]) else { return }
            self.share(pdf)
            action.dismiss(animated: true, completion: nil)
        }

        let ripetute = UIAlertAction(title: NSLocalizedString("Ripetute", comment: ""), style: .default) { _ in
            guard let pdf = pdfCreator.createPDF(ofSize: .A4, contentTypes: [.ripetute]) else { return }
            self.share(pdf)
             action.dismiss(animated: true, completion: nil)
        }

        let both = UIAlertAction(title: NSLocalizedString("Mancanti e Ripetute", comment: ""), style: .default) { _ in
            guard let pdf = pdfCreator.createPDF(ofSize: .A4, contentTypes: [.mancanti,.ripetute]) else { return }
            self.share(pdf)
             action.dismiss(animated: true, completion: nil)
        }

        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in

             action.dismiss(animated: true, completion: nil)
        }

        action.addAction(tutte)
        action.addAction(mancanti)
        action.addAction(ripetute)
        action.addAction(both)
        action.addAction(cancel)
        present(action, animated: true, completion: nil)
    }

    func share(_ pdf: URL) {

        let activityViewController = UIActivityViewController(activityItems: [pdf] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // present the view controller

        self.present(activityViewController, animated: true, completion: nil)

    }


}


extension CollezioneNumerataViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {

       return 2

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch  section {
        case 0:
            return collezionabili.count
        default:
            return 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: 60, height: 65)
        case 1:
            return CGSize(width: 300, height: 30)
        default:
            return CGSize.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {
        case 0:
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
                cardView?.layer.cornerRadius = 5
                cardView?.layer.masksToBounds = true
                cardView?.layer.borderWidth = 0.5
                cardView?.layer.borderColor = UIColor.black.cgColor

                switch collezionabile.stato {
                case .mancante:
                    cardView?.backgroundColor = .white
                    repLabel.text = nil
                case .posseduto:
                    cardView?.backgroundColor = .pastelGreen
                    repLabel.text = nil
                case .ripetuto(rep: _):
                    cardView?.backgroundColor = .secondaryAppColor
                    repLabel.text = "x\(collezionabile.stato.rawValue)"
                }
                return cell
            }
        case 1 :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "counter cell", for: indexPath)
            if let countLabel = cell.viewWithTag(1) as? UILabel {
                switch menuBar.selectedIndex {
                case 0:
                    countLabel.text = "\(collezione!.numeroPosseduti)" + NSLocalizedString(" of ", comment: "Numero di posseduti") + "\(collezione!.numeroElementi)"
                case 1:
                    countLabel.text = "\(collezione!.numeroMancanti)" + NSLocalizedString(" missing", comment: "")
                default:
                    countLabel.text = "\(collezione!.repNumber) " + NSLocalizedString("repetitions", comment: "")

                }
                countLabel.textColor = .lightGray
                countLabel.font = .systemFont(ofSize: 18, weight: .light)
            }

            return cell
        default:
            return UICollectionViewCell()
        }

    }

    func collectionView(_ collectionView:UICollectionView, updateCountLabelAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if let countLabel = cell?.viewWithTag(1) as? UILabel {
            switch menuBar.selectedIndex {
            case 0:
                countLabel.text = "\(collezione!.numeroPosseduti)" + NSLocalizedString(" of ", comment: "Numero di posseduti") + "\(collezione!.numeroElementi)"
            case 1:
                countLabel.text = "\(collezione!.numeroMancanti)" + NSLocalizedString(" missing", comment: "")
            default:
                countLabel.text = "\(collezione!.repNumber) " + NSLocalizedString("repetitions", comment: "")

            }
        }
    }

}


extension CollezioneNumerataViewController: ScreenRecordingDetectorObserver {
    func userDidStartRecordingScreen() {
        self.collectionView.isHidden = true
        setupRecordingViews()
    }

    func userDidFinishRecordingScreen() {
        destroyRecordingViews()
        self.collectionView.isHidden = false
    }

    func setupRecordingViews() {
        let infoLabel = UILabel(forAutoLayout: ())
        let helperLabel = UILabel(forAutoLayout: ())
        infoLabel.tag = 10
        helperLabel.tag = 11
        infoLabel.text = NSLocalizedString("screenReordingInfoLabelText", comment: "")
        infoLabel.font = .systemFont(ofSize: 22, weight: .medium)
        helperLabel.text = NSLocalizedString("screenRecordingHelperLabelText", comment: "")
        helperLabel.font = .systemFont(ofSize: 14)
        helperLabel.textColor = .lightGray

        view.addSubview(infoLabel)
        view.addSubview(helperLabel)

        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        helperLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -30).isActive = true
        helperLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor).isActive = true

        helperLabel.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 10).isActive = true
        helperLabel.rightAnchor.constraint(greaterThanOrEqualTo: view.rightAnchor, constant: 10).isActive = true
        helperLabel.numberOfLines = 0
        helperLabel.textAlignment = .center
        view.bringSubviewToFront(infoLabel)
        view.bringSubviewToFront(helperLabel)

    }

    func destroyRecordingViews() {
        view.viewWithTag(10)?.removeFromSuperview()
        view.viewWithTag(11)?.removeFromSuperview()
    }


}



