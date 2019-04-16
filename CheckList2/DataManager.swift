//
//  DataManager.swift
//  CheckList
//
//  Created by Michele De Sena on 04/02/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class DataManager {
    static let shared = DataManager()
    weak var appDelegate: AppDelegate! {
       return UIApplication.shared.delegate as? AppDelegate
    }

    var managedContext: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }

    private init () {}

    func deleteCollection(_ collection: Collezione) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Collection")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", collection.uuid as CVarArg)

        do {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results {
                let managedObjectData: NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch {
            print("Detele all data error : \(error) ")
        }

    }


    func deleteCollections() {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Collection")
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch {
            print("Detele all data error : \(error) ")
        }
    }


    func salva(_ collezione: Collezione) {
        User.shared.collezioni.append(collezione)
        _salva(collezione)
    }

    func update(_ coll: Collezione, withDataFrom aNewCollection: Collezione? = nil) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Collection")
        request.predicate = NSPredicate(format: "uuid == %@", coll.uuid)
        request.returnsObjectsAsFaults = false
        var collection = coll
        if aNewCollection != nil {
            collection = aNewCollection!
        }

        do {
            let result = try managedContext.fetch(request) as! [CollectionMO]
            debugPrint("trovati \(result.count) risultati")
            result.forEach { (collectionData) in
                let encodedElements = encodeElementsOfArray(collection.collezionabili)
                collectionData.elements = encodedElements
                collectionData.name = collection.nome
                collectionData.dealer = collection.editore
                collectionData.photo = collection.foto?.pngData()
            }
            saveContext()

        } catch {
            print(error)
        }


    }


    func update(_ cCollection: CollezioneNumerata, withDataFrom collection: CollezioneNumerata? = nil) {
        print("cerco collezione con uuid \(cCollection.uuid)")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CountedCollection")
        request.predicate = NSPredicate(format: "uuid == %@", cCollection.uuid )
        request.returnsObjectsAsFaults = false
        var countedCollection = cCollection
        if collection != nil {
            countedCollection = collection!
        }


        do {
            let result = try self.managedContext.fetch(request) as! [CountedCollectionMO]
            debugPrint("trovati \(result.count) risultati")
            result.forEach { (collectionData) in
                let encodedElements = self.encodeElementsOfArray(countedCollection.collezionabili)
                collectionData.elements = encodedElements
                collectionData.name = countedCollection.nome
                collectionData.dealer = countedCollection.editore
                collectionData.photo = countedCollection.foto?.pngData()
                collectionData.elementCount = Int64(countedCollection.numeroElementi)
            }
            self.saveContext()
            NotificationCenter.default.post(name: CLNotificationNames.collectionUpdated, object: nil)

        } catch {
            print(error)
        }

    }


    func saveContext() {
        do {
            try managedContext.save()
            debugPrint("stored in CoreData")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }



    func _salva(_ collezione: Collezione) {

        func setCollection(_ collection: CollectionMO) {
            collection.setValue(collezione.nome, forKeyPath: "name")
            collection.setValue(collezione.editore, forKey: "dealer")
            collection.setValue(collezione.numeroPosseduti, forKey: "posseduti")
            collection.setValue(collezione.foto!.pngData()! as NSData, forKey: "photo")
            collection.setValue(collezione.collezionabili, forKey: "elements")
            collection.name = collezione.nome
            collection.dealer = collezione.editore
            collection.uuid = collezione.uuid

            let encodedArray = encodeElementsOfArray(collezione.collezionabili)
            collection.elements = encodedArray

        }

        func setCountedCollection(_ collection: CountedCollectionMO) {
            let collezioneNum = collezione as! CollezioneNumerata
            collection.name = collezioneNum.nome
            collection.elementCount = Int64(collezioneNum.numeroElementi)
            collection.isChecklistMode = collezioneNum.isChecklistMode
            collection.photo = collezioneNum.foto?.pngData()
            collection.dealer = collezioneNum.editore
            collection.uuid = collezioneNum.uuid
            let encodedArray = encodeElementsOfArray(collezioneNum.collezionabili)
            collection.elements = encodedArray

        }









        

        if collezione is CollezioneNumerata {
            let countedCollection = CountedCollectionMO(context: managedContext)
            setCountedCollection(countedCollection)
            debugPrint("Salvo collezione \(collezione) come collezione numerata")
        } else {
            debugPrint("Salvo collezione \(collezione) come collezione")
            let collection = CollectionMO(context: managedContext)
            setCollection(collection)
        }


       saveContext()



    }

    func encodeElementsOfArray(_ array: [CollectionElement]) -> [Data] {
        
        var data: [Data] = []
        array.forEach { (element) in
            let coder = NSKeyedArchiver(requiringSecureCoding: false)
            element.encode(with: coder)
            data.append(coder.encodedData)
        }
        return data
    }

    func decodeElementsOfArray(from data: [Data]) -> [CollectionElement] {

        var array: [CollectionElement] = []
        data.forEach { (elementData) in
            let decoder = try! NSKeyedUnarchiver(forReadingFrom: elementData)
            let element = CollectionElement(coder: decoder)
            array.append(element!)
        }


        return array

    }


    

    func fetchCollections(withPredicate aPredicate: NSPredicate?, completionHandler: ([Collezione],Error?) -> Void) {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Collection")
        request.predicate = aPredicate ?? NSPredicate(value: true)
        request.returnsObjectsAsFaults = false

        do {
            let result = try managedContext.fetch(request) as! [CollectionMO]
            debugPrint("trovati \(result.count) risultati")

            let results = result.filter { (data) -> Bool in  // Forzatissimo per evitare duplicazioni, da rivedere
                data.name != nil && data.uuid != nil
            }


            let collezioni = results.map { (data) -> Collezione? in


                if let countedCollData = data as? CountedCollectionMO {
                    let cc = CollezioneNumerata()
                    cc.numeroElementi = Int(countedCollData.elementCount)
                    cc.isChecklistMode = countedCollData.isChecklistMode
                    if countedCollData.elements != nil {
                        let elements = decodeElementsOfArray(from: countedCollData.elements!)
                        cc.collezionabili = elements
                    }
                    cc.nome = countedCollData.name ?? "no name"
                    cc.editore = countedCollData.dealer ?? "no dealer"
                    if countedCollData.uuid != nil {
                        cc.uuid = countedCollData.uuid!
                    }

                    if let photoData = countedCollData.photo {
                        cc.foto = UIImage(data: photoData)
                    }
                    return cc
                } else {
                    let collectionData = data
                    let coll = Collezione(nome: collectionData.name ?? "", editore: collectionData.dealer ?? "" )
                    coll.numeroPosseduti = Int(collectionData.posseduti)
                    coll.uuid = data.uuid!
                    if collectionData.elements != nil {
                        let elements = decodeElementsOfArray(from: collectionData.elements!)
                        coll.collezionabili = elements
                    }
                    coll.foto = UIImage(data: collectionData.photo ?? Data())
                    return coll

                }

            }

            completionHandler(collezioni as! [Collezione], nil)

        } catch {
            completionHandler([],error)
        }
    }


}
