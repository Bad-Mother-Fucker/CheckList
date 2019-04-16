//
//  IAPurchaseViewController.swift
//  CheckList2
//
//  Created by Michele De Sena on 03/03/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import UIKit
import StoreKit
typealias SKProductIdentifier = String
import PureLayout

class IAPurchaseViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver, IAPurchaseDelegate {

    let currencyFormatter = NumberFormatter()


    // We'll force unwrap with the !, if you've got defined data you may need more error checking
   // Displays $9,999.99 in the US locale


    func didBuy(_ product: SKProduct) {
        let alert = UIAlertController(title: NSLocalizedString("DidBuyProductAlertTitle", comment: ""), message: NSLocalizedString("DidBuyProductAlertMessage", comment: ""), preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("OKAction", comment: ""), style: .default) { _ in
            User.shared.purchaseProduct(product.productIdentifier)
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    func didCancelPayment(for reason: Error) {
        let alert = UIAlertController(title: NSLocalizedString("DidCancelPaymentAlertTitle", comment: ""), message: NSLocalizedString("DidCancelPaymentAlertMessage", comment: "") + reason.localizedDescription , preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("OKAction", comment: ""), style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }


    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            switch transaction.transactionState {
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                purchaseDelegate.didBuy(products.productWithId(transaction.payment.productIdentifier)!)
            case .purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                purchaseDelegate.didBuy(products.productWithId(transaction.payment.productIdentifier)!)
            case .failed:
                print("Transaction Failed: \(transaction.error!.localizedDescription)");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                didCancelPayment(for: transaction.error!)
            default:
               break
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
    override func viewDidLoad() {
        SKPaymentQueue.default().add(self)

        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        
        currencyFormatter.locale = Locale.current

        descriptionLabel.text = NSLocalizedString("PurchaseFeatureDescription", comment: "")
        view.addSubview(restorePurchasesButton)
        pureLayout()
        buyButton.isUserInteractionEnabled = false
        try! request([productIDs.PDFExtension])
        purchaseDelegate = self
        let progress = UIActivityIndicatorView(style: .gray)
        progress.color = .mainAppColor
        progress.configureForAutoLayout()
        progress.tag = 1
        buyButton.addSubview(progress)
        progress.autoAlignAxis(toSuperviewAxis: .vertical)
        progress.autoAlignAxis(toSuperviewAxis: .horizontal)
        progress.startAnimating()
        buyButton.layer.masksToBounds = true
        buyButton.layer.cornerRadius = 10
        buyButton.setTitleColor(.black, for: .normal)

        buyButton.addTarget(self, action: #selector(showPurchaseActions), for: .touchUpInside)
    }

    var selectedProductIndex = 0
    var transactionInProgress = false
    var purchaseDelegate: IAPurchaseDelegate!


    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard response.products.count > 0 else { print("no product with the given ID"); return }
        products.append(contentsOf: response.products)
        buyButton.isUserInteractionEnabled = true
        let priceString = currencyFormatter.string(from: products[0].price)!

        let progress = buyButton.viewWithTag(1) as! UIActivityIndicatorView
        progress.stopAnimating()
        buyButton.setAttributedTitle(NSAttributedString(string: priceString, attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold)]), for: .normal)
        if !response.invalidProductIdentifiers.isEmpty {
            response.invalidProductIdentifiers.forEach { print("Prod uct ID: " + $0 + " not valid") }
        }
    }


    var productsIDs: [SKProductIdentifier] = [productIDs.PDFExtension]

    var products: [SKProduct] = []

    let restorePurchasesButton: UIButton = {
        let button = UIButton(forAutoLayout: ())
        button.setTitle("Restore Purchases", for: .normal)
        button.tintColor = .secondaryAppColor
        button.setTitleColor(.secondaryAppColor, for: .normal)
        button.addTarget(self, action: #selector(restorePurchases), for: .touchUpInside)
        return button
    }()


    @objc func restorePurchases() {
        if SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }


    func request(_ products: [SKProductIdentifier]) throws {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: Set(products))
            request.delegate = self
            request.start()
        } else {
            throw RequestError.cannotMakePayments
        }
    }

   @objc func showPurchaseActions() {

        guard !transactionInProgress else { return }


        let priceString = currencyFormatter.string(from: products[0].price)!
        let alert = UIAlertController(title: NSLocalizedString("PurchaseAlertControllerTitle", comment: ""), message: NSLocalizedString("PurchaseAlertControllerMessage", comment: "") + priceString + "?", preferredStyle: .alert)
        let buyAction = UIAlertAction(title: NSLocalizedString("PurchaseAlertControllerBuyAction", comment: ""), style: .default) { _ in
            let product = self.products[0]
            let payment = SKPayment(product: product )
            SKPaymentQueue.default().add(payment)

            self.transactionInProgress = true
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("CancelAction", comment: ""), style: .cancel) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }

        alert.addAction(buyAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var premiumLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var roundCheck: UIImageView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var dismissBtn: UIButton!


    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

fileprivate enum RequestError: Error, CustomStringConvertible {

    var description: String {
        switch self {
        case .cannotMakePayments:
            return "Reason: cannot make payments"
        }
    }

    case cannotMakePayments

}

fileprivate extension Array where Element: SKProduct {
    func productWithId(_ identifier: SKProductIdentifier) -> SKProduct? {
        return self.filter({ (p) -> Bool in
            return p.productIdentifier == identifier
        }).first
    }
}

enum productIDs {
    static let PDFExtension = "ChecklistPDFExtension"
}





extension IAPurchaseViewController {
    func pureLayout() {
        view.subviews.forEach { (view) in
            view.configureForAutoLayout()
        }
        dismissBtn.autoPinEdge(toSuperviewEdge: .top, withInset: 60)
        dismissBtn.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        dismissBtn.autoSetDimensions(to: CGSize(width: 30, height: 30))

        logoView.autoAlignAxis(toSuperviewAxis: .vertical)
        logoView.autoSetDimension(.height, toSize: 40)
        logoView.autoPinEdge(toSuperviewEdge: .left, withInset:81)
        logoView.autoPinEdge(toSuperviewEdge: .right, withInset:81)
        logoView.autoPinEdge(toSuperviewEdge: .top, withInset: 155)

        premiumLabel.autoPinEdge(.top, to: .bottom, of: logoView)
        premiumLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        premiumLabel.autoSetDimensions(to: CGSize(width: 100, height: 25))

        descriptionLabel.autoPinEdge(.top, to: .bottom, of: premiumLabel, withOffset: 50)
        descriptionLabel.autoAlignAxis(toSuperviewAxis: .vertical)


        descriptionLabel.autoSetDimension(.width, toSize: 245)
        roundCheck.autoAlignAxis(.horizontal, toSameAxisOf: descriptionLabel)
        roundCheck.autoSetDimensions(to: CGSize(width: 30, height: 30))
        roundCheck.autoPinEdge(.right, to: .left, of: descriptionLabel, withOffset: -10)

        buyButton.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: 90)

        buyButton.autoPinEdge(toSuperviewEdge: .left, withInset: 100)
        buyButton.autoPinEdge(toSuperviewEdge: .right, withInset: 100)
        buyButton.autoSetDimension(.height, toSize: 48)

        restorePurchasesButton.autoPinEdge(toSuperviewEdge: .left, withInset: 100)
        restorePurchasesButton.autoPinEdge(toSuperviewEdge: .right, withInset: 100)
        restorePurchasesButton.autoSetDimension(.height, toSize: 48)
        restorePurchasesButton.autoPinEdge(.top, to: .bottom, of: buyButton,withOffset: 20)

        
    }
}
