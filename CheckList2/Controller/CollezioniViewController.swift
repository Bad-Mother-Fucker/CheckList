//
//  ViewController.swift
//  CheckList
//
//  Created by Michele De Sena on 03/02/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import UIKit

class CollezioniViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = true
        addObservers()
       

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.largeTitleTextAttributes =
            [.font: UIFont.boldSystemFont(ofSize: fontSize)]
        super.viewWillAppear(animated)

        DataManager.shared.fetchCollections(withPredicate: nil) { (results, error) in
            guard error == nil else { debugPrint(error!.localizedDescription); return }
            User.shared.collezioni = results
        }
        adjustLargeTitleSize()

        collezioniTableView.reloadData()
        if User.shared.collezioni.count == 0 {
            collezioniTableView.isHidden = true
        } else {
            collezioniTableView.isHidden = false
        }

    }

    var tappedIndex: Int?
    let fontSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize


    func addObservers() {
        NotificationCenter.default.addObserver(forName: CLNotificationNames.collectionUpdated, object: nil, queue: .main) { [weak self] (_) in
            self?.collezioniTableView.reloadData()
            self?.collezioniTableView.isUserInteractionEnabled = true
        }
    }

    
    // MARK: Outlets

    @IBOutlet weak var collezioniTableView: UITableView! {
        didSet {
            collezioniTableView.delegate = self
            collezioniTableView.dataSource = self
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
        return 100
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let collezioni = User.shared.collezioni
        return collezioni.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "collectionTableViewCell", for: indexPath) as? CollezioniTableViewCell else {
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
        let delete = UITableViewRowAction(style: .destructive, title: "Elimina") { (action, indexPath) in

            let alert = UIAlertController(title: "Vuoi eliminare questa collezione?", message: "Tutti i dati ad essa relativi saranno definitivamente rimossi dall'applicazione", preferredStyle: .actionSheet)
            let elimina = UIAlertAction(title: "Elimina", style: .destructive, handler: { (_) in
                DataManager.shared.deleteCollection(User.shared.collezioni[indexPath.row])
                User.shared.collezioni.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                if User.shared.collezioni.count == 0 {
                    tableView.isHidden = true
                }
            })
            let annulla = UIAlertAction(title: "Annulla", style: .cancel, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            })

            alert.addAction(elimina)
            alert.addAction(annulla)
            self.present(alert, animated: true, completion: nil)


        }

        let edit = UITableViewRowAction(style: .normal, title: "Modifica") { (action, indexPath) in


            let navControl = self.storyboard!.instantiateViewController(withIdentifier: "navControl") as! UINavigationController
            let editViewController = navControl.visibleViewController as! NuovaCollezioneViewController

            editViewController.collezione = User.shared.collezioni[indexPath.row]
            self.navigationController?.present(navControl, animated: true, completion: nil)

        }

        edit.backgroundColor = .orange

        return [delete,edit]

    }

}

