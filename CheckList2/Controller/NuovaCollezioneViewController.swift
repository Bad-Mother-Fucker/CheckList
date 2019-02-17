//
//  NuovaCollezioneViewController.swift
//  CheckList
//
//  Created by Michele De Sena on 04/02/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import UIKit

class NuovaCollezioneViewController: UIViewController {

    @IBOutlet weak var rootView: UIView!

    var collezione: Collezione?

    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if collezione != nil { setEditor() }
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(choosePhoto))
        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        artwork.addGestureRecognizer(imageTap)
        artwork.isUserInteractionEnabled = true
        rootView.addGestureRecognizer(keyboardTap)
        // Do any additional setup after loading the view.
    }


    func setEditor() {

        artwork?.image = collezione?.foto ?? UIImage(named: "picture")
        editoreTextField?.text = collezione?.editore
        titoloTextfield?.text = collezione?.nome
        if let cn = collezione as? CollezioneNumerata {
            numerataSwitch?.setOn(true, animated: true)
            numerataSwitch.isUserInteractionEnabled = false
            numerataSwitch.alpha = 0.3
            sliderNumeri.value = Float(cn.numeroElementi)
            textFieldNumero.text = "\(cn.numeroElementi)"
            checklistSwitch.isUserInteractionEnabled = false
            checklistSwitch.alpha = 0.3
            hiddenViews?.forEach { (view) in
                view.isHidden = false
            }
            checklistSwitch?.setOn(cn.isChecklistMode, animated: true)
        }
    }


    @IBOutlet weak var checklistSwitch: UISwitch! {
        didSet {
            checklistSwitch.setOn(false, animated: false)
        }
    }

    @IBOutlet weak var numerataSwitch: UISwitch! {
        didSet {
            numerataSwitch.setOn(false, animated: false)
        }
    }


    @IBAction func numerataSwitch(_ sender: UISwitch) {

        if sender.isOn {
            hiddenViews.forEach { (view) in
                view.fadeIn()
            }
        } else {
            hiddenViews.forEach { (view) in
                view.fadeOut()
            }
        }
    }


    @IBOutlet weak var textFieldNumero: UITextField! {
        didSet {
            textFieldNumero.text = "1"
            textFieldNumero.delegate = self
        }
    }


    @IBOutlet var hiddenViews: [UIView]! {
        didSet {
            hiddenViews.forEach { (view) in
                view.isHidden = true
            }
        }
    }



    

    @IBOutlet weak var sliderNumeri: UISlider! {
        didSet {
            sliderNumeri.maximumValue = 999
            sliderNumeri.minimumValue = 1
            sliderNumeri.setValue(1, animated: false)
        }
    }


    @IBAction func slider(_ sender: UISlider) {
        textFieldNumero.text = "\(Int(sender.value))"
    }


    
    @IBOutlet weak var artwork: UIImageView! {
        didSet {
            artwork.contentMode = .scaleAspectFit

            artwork.image = UIImage(named: "picture")
        }
    }

    @objc func dismissKeyboard() {
        textFieldNumero.resignFirstResponder()
        editoreTextField.resignFirstResponder()
        titoloTextfield.resignFirstResponder()
        textFieldNumero.endEditing(true)
    }

    @IBOutlet weak var titoloTextfield: UITextField! {
        didSet {
            titoloTextfield.delegate = self
        }
    }


    @IBOutlet weak var editoreTextField: UITextField! {
        didSet {
            editoreTextField.delegate = self
        }
    }


    @objc func choosePhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { ( _ ) in
            picker.sourceType = .camera
            sheet.dismiss(animated: true, completion: nil)
            self.present(picker, animated: true, completion: nil)
        }
        let library = UIAlertAction(title: "Galleria", style: .default) { ( _ ) in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
            sheet.dismiss(animated: true, completion: nil)
        }

        let cancel = UIAlertAction(title: "Annulla", style: .cancel) { ( _ ) in
            sheet.dismiss(animated: true, completion: nil)
        }
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        present(sheet, animated: true, completion: nil)
    }


    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func salva(_ sender: Any) {

        guard collezione == nil else {
            if let cn = collezione as? CollezioneNumerata {
                let coll = CollezioneNumerata(nome: titoloTextfield.text ?? "", editore: editoreTextField.text ?? "", numeroElementi: Int(sliderNumeri.value))
                coll.foto = artwork.image
                coll.collezionabili = collezione!.collezionabili
                DataManager.shared.update(cn,withDataFrom: coll)
            } else {
                let coll = Collezione(nome: titoloTextfield.text ?? "", editore: editoreTextField.text ?? "")
                coll.foto = artwork.image
                coll.collezionabili = collezione!.collezionabili
                coll.numeroPosseduti = collezione!.numeroPosseduti
                DataManager.shared.update(collezione!,withDataFrom: coll)
            }
            self.dismiss(animated: true, completion: nil)
            return
        }

        switch self.numerataSwitch.isOn {
        case true:
            let c = CollezioneNumerata(nome: self.titoloTextfield.text ?? "Senza nome", editore: self.editoreTextField.text ?? "", numeroElementi: Int(self.textFieldNumero.text!) ?? 0)
            c.isChecklistMode = self.checklistSwitch.isOn
            c.foto = artwork.image
            DataManager.shared.salva(c)

        case false:
            let c = Collezione(nome: self.titoloTextfield.text ?? "Senza nome", editore: self.editoreTextField.text ?? "")
            c.foto = artwork.image
            
            DataManager.shared.salva(c)

        }
        self.dismiss(animated: true, completion: nil)

    }

}


extension NuovaCollezioneViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            debugPrint(pickedImage)
            picker.dismiss(animated: true, completion: nil)
            artwork.image = pickedImage
        }
    }
}

extension NuovaCollezioneViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            DispatchQueue.main.async {
                self.view.viewWithTag(2)?.becomeFirstResponder()
            }
        } else {
            debugPrint("dismiss keyboard")
            textField.resignFirstResponder()
        }
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: textField.center.y - 100), animated: true)

    }


    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        if textField.tag == 3 {
            sliderNumeri.setValue(Float(textField.text!) ?? 0, animated: true)
        }
    }
}



extension UIView {
    func fadeIn() {
        self.isHidden = false
        self.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
        }
    }

    func fadeOut() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
        }
    }
}


extension Date {
    static func stringTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy hh:mm:ss"
        return formatter.string(from: self.init())
    }
}