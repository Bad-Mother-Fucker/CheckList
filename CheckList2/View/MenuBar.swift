//
//  MenuBar.swift
//  CheckList2
//
//  Created by Michele De Sena on 14/03/2019.
//  Copyright © 2019 Michele De Sena. All rights reserved.
//

import UIKit
import PureLayout

class MenuBar: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellID)
        addSubview(collectionView)
        collectionView.configureForAutoLayout()
        collectionView.autoPinEdgesToSuperviewEdges()
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
        setupHorizontalBar()
    }

    var controller: CollezioneNumerataViewController?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    var selectedIndex = 0
    var barLeftConstraint: NSLayoutConstraint?
    let cellID = "reusableCell"

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .mainAppColor
        return cv
    }()

    func setupHorizontalBar() {
        let bar = UIView(forAutoLayout: ())
        addSubview(bar)

        bar.backgroundColor = .secondaryAppColor
        barLeftConstraint = bar.leftAnchor.constraint(equalTo: leftAnchor)
        barLeftConstraint?.isActive = true
        bar.autoPinEdge(toSuperviewEdge: .bottom)
        bar.autoSetDimensions(to: CGSize(width: frame.width/3, height: 4))
        bar.frame = CGRect(x: 0, y: 0, width: frame.width/3, height: 4)
        print(bar.frame)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MenuCell
        switch indexPath.item {
        case 0:
            cell.label.text = NSLocalizedString("Tutte", comment: "")
        case 1:
            cell.label.text = NSLocalizedString("Mancanti", comment: "")
        case 2:
            cell.label.text = NSLocalizedString("Ripetute", comment: "")
        default:
            break
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width/3, height: frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }




    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let x = CGFloat(indexPath.item) * frame.width / 3
        barLeftConstraint?.constant = x
        selectedIndex = indexPath.item

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)

        controller?.collectionView.reloadData()
    }















    class MenuCell: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = .white
            setupViews()

        }

        override var isHighlighted: Bool {
            didSet {
                print("wooo")
                label.textColor = isHighlighted ? .secondaryAppColor : .mainAppColor
            }
        }

        override var isSelected: Bool {
            didSet {
                label.textColor = isSelected ? .secondaryAppColor : .mainAppColor
            }
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        let label = UILabel()

        private func setupViews() {
            label.text = "label"

            label.textColor = .mainAppColor
            label.frame =  CGRect(x: 0, y: 0, width: 50, height: 20)
            addSubview(label)
            label.textAlignment = .center
            label.autoAlignAxis(toSuperviewAxis: .vertical)
            label.autoAlignAxis(toSuperviewAxis: .horizontal)
            label.adjustsFontSizeToFitWidth = true

        }

    }

}



