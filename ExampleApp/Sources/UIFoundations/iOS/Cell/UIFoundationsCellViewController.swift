//
//  UIFoundationsCellViewController.swift
//  Showcase
//
//  Created by Igor Kulman on 16.12.2020.
//

import UIKit
import ProtonCoreUIFoundations

final class UIFoundationsCellViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(PMCell.nib, forCellReuseIdentifier: PMCell.reuseIdentifier)
        tableView.register(PMCellSectionView.nib, forHeaderFooterViewReuseIdentifier: PMCellSectionView.reuseIdentifier)
        tableView.separatorColor = UIColor.dynamic(light: #colorLiteral(red: 0.9607843137, green: 0.9647058824, blue: 0.9803921569, alpha: 1), dark: #colorLiteral(red: 0.1450980392, green: 0.1529411765, blue: 0.1725490196, alpha: 1))
        tableView.rowHeight = UITableView.automaticDimension

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
}

// MARK: - Table view delegates

extension UIFoundationsCellViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: PMCell.reuseIdentifier) as! PMCell
            cell.title = UIFoundationsHelpItem.allCases[indexPath.row].description
            cell.icon = UIFoundationsHelpItem.allCases[indexPath.row].icon
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: PMCell.reuseIdentifier) as! PMCell
            switch indexPath.row {
            case 0:
                cell.title = "Disabled"
                cell.icon = UIFoundationsHelpItem.allCases.last?.icon
                cell.isDisabled = true
                cell.subtitle = "Subtitle"
            case 1:
                cell.title = "Loading"
                cell.icon = UIFoundationsHelpItem.allCases.last?.icon
                cell.isLoading = true
                cell.subtitle = "Subtitle"
            case 2:
                cell.title = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque quis est eget augue tristique semper. Nunc eget nulla in nisi consectetur tempor. In tellus arcu, lobortis nec tincidunt ac, pharetra ut erat."
                cell.icon = UIFoundationsHelpItem.allCases.last?.icon
            default:
                fatalError()
            }
            return cell
        default:
            fatalError()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return UIFoundationsHelpItem.allCases.count - 1
        case 1:
            return 3
        default:
            fatalError()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PMCellSectionView.reuseIdentifier) as! PMCellSectionView
            header.title = "Different states"
            return header
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return UITableView.automaticDimension
        default:
            return 0
        }
    }
}

extension UIFoundationsCellViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
