//
//  ViewController.swift
//  CheckList
//
//  Created by Michele De Sena on 03/02/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import UIKit

class CollezioniViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let infoLabel = UILabel(forAutoLayout: ())
    let helperLabel = UILabel(forAutoLayout: ())

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        addObservers()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    override func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        super.viewWillAppear(animated)

        DataManager.shared.fetchCollections(withPredicate: nil) { (results, error) in
            guard error == nil else { debugPrint(error!.localizedDescription); return }
            User.shared.collezioni = results
        }
        collezioniTableView.reloadData()
        if User.shared.collezioni.isEmpty {
            collezioniTableView.isHidden = true
            setHelperView()

        } else {
            collezioniTableView.isHidden = false
            removeHelperView()
        }

    }

    var tappedIndex: Int?

    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    private func removeHelperView() {
        helperLabel.removeFromSuperview()
        infoLabel.removeFromSuperview()
    }

    private func setHelperView() {
        infoLabel.text = NSLocalizedString("infoLabelText", comment: "")
        infoLabel.font = .systemFont(ofSize: 22, weight: .medium)
        helperLabel.text = NSLocalizedString("helperLabelText", comment: "")
        helperLabel.font = .systemFont(ofSize: 14)
        helperLabel.textColor = .lightGray

        view.addSubview(infoLabel)
        view.addSubview(helperLabel)

        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        helperLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -30).isActive = true
        helperLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor).isActive = true
        helperLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        helperLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true

        view.sendSubviewToBack(helperLabel)
        view.sendSubviewToBack(infoLabel)
    }


    private func setNavigationBar() {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.mainAppColor]
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.largeTitleTextAttributes = attributes

        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "buttonAdd")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(nuovaCollezioneSegue), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }


    private func addObservers() {
        NotificationCenter.default.addObserver(forName: CLNotificationNames.collectionUpdated, object: nil, queue: .main) { [weak self] (_) in
            self?.collezioniTableView.reloadData()
            self?.collezioniTableView.isUserInteractionEnabled = true
        }
    }


    @objc func nuovaCollezioneSegue() {
        performSegue(withIdentifier: "nuovaCollezioneSegue", sender: self)
    }


    @IBOutlet weak var collezioniTableView: UITableView! {
        didSet {
            collezioniTableView.delegate = self
            collezioniTableView.dataSource = self
            collezioniTableView.contentInset.top = 20
            collezioniTableView.scrollIndicatorInsets.top = 20
            
        }
    }




    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let index = tappedIndex else { return }
        if segue.identifier == "collezioneNumerataSegue" {
            let vc = segue.destination as! CollezioneNumerataViewController
            vc.collectionIndex = index
            
        } else if segue.identifier == "collezioneNonNumerataSegue" {
            let vc = segue.destination as! CollezioneViewController
            vc.collectionIndex = index
        }

    }

    // MARK: Delegate and Datasource methods

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 361
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let collezioni = User.shared.collezioni
        return collezioni.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "collectionTableViewCellBig", for: indexPath) as? CollezioniTableViewCell else {
            return UITableViewCell()
        }
        cell.setCell(for: User.shared.collezioni[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tappedIndex = indexPath.row
        var collezioni = User.shared.collezioni
        let tappedCollecion = collezioni[indexPath.row]
        if tappedCollecion is CollezioneNumerata {
            performSegue(withIdentifier: "collezioneNumerataSegue", sender: self)
        } else {
            performSegue(withIdentifier: "collezioneNonNumerataSegue", sender: self)
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) {
            (action, indexPath) in

            let alert = UIAlertController(title: NSLocalizedString("Do you want to delete this series?", comment: ""),
                                          message: NSLocalizedString("All data relating to it will be permanently removed from the application", comment: ""),
                                          preferredStyle: .actionSheet)
            let elimina = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (_) in
                DataManager.shared.deleteCollection(User.shared.collezioni[indexPath.row])
                User.shared.collezioni.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                if User.shared.collezioni.count == 0 {
                    tableView.isHidden = true
                    self.setHelperView()
                }
            })
            let annulla = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            })

            alert.addAction(elimina)
            alert.addAction(annulla)
            self.present(alert, animated: true, completion: nil)


        }

        let edit = UITableViewRowAction(style: .normal, title: NSLocalizedString("Edit", comment: "")) { (action, indexPath) in

            let navControl = self.storyboard!.instantiateViewController(withIdentifier: "navControl") as! UINavigationController
            let editViewController = navControl.visibleViewController as! NuovaCollezioneViewController

            editViewController.collezione = User.shared.collezioni[indexPath.row]
            self.navigationController?.present(navControl, animated: true, completion: nil)

        }

        edit.backgroundColor = .orange

        return [delete,edit]

    }

}

