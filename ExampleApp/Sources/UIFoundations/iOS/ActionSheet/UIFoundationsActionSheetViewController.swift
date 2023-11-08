//
//  UIFoundationsActionSheetViewV2Controller.swift
//  Example-iOS-Mail-AppStoreIAP - Created on 2023/1/19.
//  
//  Copyright (c) 2023 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore. If not, see https://www.gnu.org/licenses/.
//

import UIKit
import ProtonCoreLog
import ProtonCoreUIFoundations

class UIFoundationsActionSheetViewController: UIFoundationsAppearanceStyleViewController {
    private var table: UITableView = UITableView(frame: .zero)
    private let cellIdentifier = "actionSheetSample"
    private let sampleNames = [
        "Simple action sheet",
        "single Selection Sample",
        "multiSelection Sample with indentation",
        "two column sample",
        "toggle sample",
        "header sample",
        "header with icon sample",
        "exampleFromFigma_1",
        "select all sample",
        "grid sample",
        "pan style v2 demo",
        "new sheet style sample"
    ]
    private var functions: [() -> Void] = []

    override func loadView() {
        let container = UIView(frame: .zero)
        container.backgroundColor = ColorProvider.BackgroundNorm
        view = container
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        functions = [
            simpleActionSheet,
            singleSelectionSample,
            multiSelectionSample,
            twoColumnSample,
            toggleSample,
            headerSample,
            headerWithIconSample,
            exampleFromFigma_1,
            selectAllSample,
            gridSample,
            panStyleV2Demo,
            newSheetStyleSample
        ]
        setUpTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DFSSetting.enableDFS = true
        DFSSetting.limitToXXXLarge = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DFSSetting.enableDFS = false
        DFSSetting.limitToXXXLarge = false
    }
}

extension UIFoundationsActionSheetViewController {
    private func setUpTableView() {
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func simpleActionSheet() {
        let sheet: PMActionSheet
        let items = (0...15).map {
            PMActionSheetItem(
                style: .default(IconProvider.star, "star \($0)"),
                userInfo: ["item": "star \($0)"]
            ) { item in
                print("Click \(item.userInfo ?? [:])")
            }
        }
        let group = PMActionSheetItemGroup(items: items, style: .clickable)
        sheet = PMActionSheet(headerView: nil, itemGroups: [group], enableBGTap: true, delegate: nil)
        sheet.presentAt(self, animated: true)
    }

    private func singleSelectionSample() {
        let sheet: PMActionSheet
        var items: [PMActionSheetItem] = []
        for i in 0...5 {
            let icon = PMActionSheetIconComponent(icon: IconProvider.star, edge: [nil, nil, nil, 16])
            let label = PMActionSheetTextComponent(text: .left("Star \(i)"), edge: [nil, nil, nil, 12])
            let info = ["index": i]
            let markType: PMActionSheetItem.MarkType = i == 0 ? .checkMark : .none
            let item = PMActionSheetItem(
                components: [icon, label],
                userInfo: info,
                markType: markType,
                handler: { item in
                    print("Click \(item.userInfo ?? [:]) \(item.markType)")
                })
            items.append(item)
        }

        let group = PMActionSheetItemGroup(items: items, style: .singleSelection)
        sheet = PMActionSheet(headerView: nil, itemGroups: [group], enableBGTap: true, delegate: nil)
        sheet.presentAt(self, animated: true)
    }

    private func multiSelectionSample() {
        let sheet: PMActionSheet
        var items: [PMActionSheetItem] = []
        for i in 0...5 {
            let icon = PMActionSheetIconComponent(icon: IconProvider.star, edge: [nil, nil, nil, 16])
            let label = PMActionSheetTextComponent(text: .left("Star \(i)"), edge: [nil, nil, nil, 12])
            let info = ["index": i]
            let markType: PMActionSheetItem.MarkType = i == 0 ? .checkMark : .none
            let item = PMActionSheetItem(
                components: [icon, label],
                indentationLevel: i,
                userInfo: info,
                markType: markType,
                handler: { item in
                    print("Click \(item.userInfo ?? [:]) \(item.markType)")
                })
            items.append(item)
        }

        let group = PMActionSheetItemGroup(items: items, style: .multiSelection)
        sheet = PMActionSheet(headerView: nil, itemGroups: [group], enableBGTap: true, delegate: nil)
        sheet.presentAt(self, animated: true)
    }

    private func twoColumnSample() {
        let sheet: PMActionSheet
        let items = (0...5).map {
            PMActionSheetItem(
                style: .twoColumn(
                    "LeftLeftLeftLeftLeftLeftLeftLeftLeftLeftLeftLeftLeftLeft \($0)",
                    "RightRightRightRightRightRightRightRightRightRightRightRightRightRightRightRightRight \($0)"
                ),
                userInfo: ["item": "Item \($0)"]
            ) { item in
            print("Click \(item.userInfo ?? [:])")
            }
        }
        let group = PMActionSheetItemGroup(items: items, style: .clickable)
        sheet = PMActionSheet(headerView: nil, itemGroups: [group], enableBGTap: true, delegate: nil)
        sheet.presentAt(self, animated: true)
    }

    private func toggleSample() {
        let sheet: PMActionSheet
        let items = (0...5).map {
            PMActionSheetItem(
                style: .toggle("Toggle row \($0)", true),
                userInfo: ["item": "Toggle row \($0)"]
            ) { item in
                print("Trigger toggle \(item.userInfo ?? [:]), new state is \(item.toggleState)")
            }
        }
        let group = PMActionSheetItemGroup(items: items, style: .toggle)
        sheet = PMActionSheet(headerView: nil, itemGroups: [group], enableBGTap: true, delegate: nil)
        sheet.presentAt(self, animated: true)
    }

    private func headerSample() {
        var sheet: PMActionSheet!
        let titleItem = PMActionSheetItem(components: [
            PMActionSheetTextComponent(text: .left("Possible project underway at the..."), edge: [nil, nil, nil, nil], font: .adjustedFont(forTextStyle: .subheadline, weight: .semibold))
        ], handler: nil)
        let subtitleItem = PMActionSheetItem(components: [
            PMActionSheetTextComponent(text: .left("Message from Danny"), textColor: ColorProvider.TextWeak, edge: [nil, nil, nil, nil], font: .adjustedFont(forTextStyle: .caption1))
        ], handler: nil)
        let leftButton = PMActionSheetButtonComponent(content: .right(IconProvider.cross), color: ColorProvider.IconNorm, size: CGSize(width: 40, height: 40), edge: [nil, nil, nil, 8])
        let rightButton = PMActionSheetButtonComponent(content: .left("Done"), color: ColorProvider.BrandNorm, edge: [nil, 8, nil, nil])
        let header = PMActionSheetHeaderView(
            titleItem: titleItem,
            subtitleItem: subtitleItem,
            leftItem: leftButton,
            rightItem: rightButton,
            hasSeparator: true) {
                print("Click left item")
                sheet.dismiss(animated: true)
            } rightItemHandler: {
                print("Click right item")
                sheet.dismiss(animated: true)
        }

        let items = (0...5).map {
            PMActionSheetItem(
                style: .default(IconProvider.star, "star \($0)"),
                userInfo: ["item": "star \($0)"]
            ) { item in
                print("Click \(item.userInfo ?? [:])")
            }
        }
        let group = PMActionSheetItemGroup(items: items, style: .clickable)
        sheet = PMActionSheet(headerView: header, itemGroups: [group], enableBGTap: true, delegate: nil)
        sheet.presentAt(self, animated: true)
    }

    private func headerWithIconSample() {
        var sheet: PMActionSheet!
        let titleItem = PMActionSheetItem(components: [
            PMActionSheetTextComponent(text: .left("This is a title"), edge: [nil, nil, nil, nil], font: .adjustedFont(forTextStyle: .subheadline, weight: .semibold)),
            PMActionSheetIconComponent(icon: IconProvider.heart, size: CGSize(width: 15, height: 15), edge: [nil, nil, nil, 8])
        ], handler: nil)
        let subtitleItem = PMActionSheetItem(components: [
            PMActionSheetTextComponent(text: .left("This is a subtitle"), edge: [nil, nil, nil, nil], font: .adjustedFont(forTextStyle: .caption1)),
            PMActionSheetIconComponent(icon: IconProvider.star, size: CGSize(width: 15, height: 15), edge: [nil, nil, nil, 8])
        ], handler: nil)
        let leftButton = PMActionSheetButtonComponent(content: .right(IconProvider.cross), color: ColorProvider.IconNorm, edge: [nil, nil, nil, 16])
        let rightButton = PMActionSheetButtonComponent(content: .left("Done"), color: ColorProvider.BrandNorm, edge: [nil, 16, nil, nil])
        let header = PMActionSheetHeaderView(
            titleItem: titleItem,
            subtitleItem: subtitleItem,
            leftItem: leftButton,
            rightItem: rightButton,
            hasSeparator: true) {
                print("Click left item")
                sheet.dismiss(animated: true)
            } rightItemHandler: {
                print("Click right item")
                sheet.dismiss(animated: true)
        }

        let items = (0...5).map {
            PMActionSheetItem(
                style: .default(IconProvider.star, "star \($0)"),
                userInfo: ["item": "star \($0)"]
            ) { item in
                print("Click \(item.userInfo ?? [:])")
            }
        }
        let group = PMActionSheetItemGroup(items: items, style: .clickable)
        sheet = PMActionSheet(headerView: header, itemGroups: [group], enableBGTap: true, delegate: nil)
        sheet.presentAt(self, animated: true)
    }

    private func exampleFromFigma_1() {
        var sheet: PMActionSheet!
        let header = PMActionSheetHeaderView(
            title: "5 conversations",
            subtitle: nil,
            leftItem: .right(IconProvider.arrowLeft),
            rightItem: .left("Done")) {
                print("Click left item")
                sheet.dismiss(animated: true)
            } rightItemHandler: {
                print("Click right item")
                sheet.dismiss(animated: true)
        }

        let toggle = PMActionSheetItem(style: .toggle("Send to archive?", true)) { item in
            print("Toggle state has changed, new state is \(item.toggleState)")
        }
        let toggleGroup = PMActionSheetItemGroup(items: [toggle], style: .toggle)
        let newLabel = PMActionSheetItem(style: .default(IconProvider.plus, "New label")) { _ in
            print("Click new label button")
        }
        let newGroup = PMActionSheetItemGroup(items: [newLabel], style: .clickable)

        let items = (0...5).map {
            PMActionSheetItem(
                style: .default(IconProvider.circle, "star \($0)"),
                userInfo: ["item": "star \($0)"],
                markType: .dash
            ) { item in
                print("Click \(item.userInfo ?? [:])")
            }
        }
        let group = PMActionSheetItemGroup(items: items, style: .multiSelectionNewStyle)
        sheet = PMActionSheet(headerView: header, itemGroups: [toggleGroup, newGroup, group], enableBGTap: true, delegate: nil)
        sheet.presentAt(self, animated: true)
    }

    private func selectAllSample() {
        var sheet: PMActionSheet!
        let header = PMActionSheetHeaderView(title: "Design pals", subtitle: nil, leftItem: nil, rightItem: nil, leftItemHandler: nil, rightItemHandler: nil)
        let selectAll = PMActionSheetItem(style: .text("Select all")) { item in
            guard let group = sheet.itemGroups[safeIndex: 1] else { return }
            print("Click select all")
            if item.markType == .checkMark {
                group.items.forEach { $0.update(markType: .checkMark) }
            }
            sheet.reloadSection(1)
        }
        let selectGroup = PMActionSheetItemGroup(items: [selectAll], style: .singleSelectionNewStyle)

        let items = (0...5).map {
            PMActionSheetItem(
                style: .default(IconProvider.star, "star \($0)"),
                userInfo: ["item": "star \($0)"],
                markType: .none
            ) { item in
                print("Click \(item.userInfo ?? [:])")
                if item.markType == .none {
                    guard let group = sheet.itemGroups[safeIndex: 0] else { return }
                    group.items.first?.update(markType: .none)
                    sheet.reloadSection(0)
                }
            }
        }
        let group = PMActionSheetItemGroup(title: "Section title", items: items, style: .multiSelectionNewStyle)
        sheet = PMActionSheet(headerView: header, itemGroups: [selectGroup, group], enableBGTap: true, delegate: nil)
        sheet.presentAt(self, animated: true)
    }

    private func gridSample() {
        var sheet: PMActionSheet!
        let header = PMActionSheetHeaderView(title: "Design pals", subtitle: nil, leftItem: nil, rightItem: nil, leftItemHandler: nil, rightItemHandler: nil)

        let grid: [(UIImage, String)] = [
            (IconProvider.reply, "Reply"),
            (IconProvider.replyAll, "Reply all"),
            (IconProvider.forward, "Forward")
        ]
        let gridItems = grid.map {
            PMActionSheetItem(
                style: .grid($0.0, $0.1),
                userInfo: ["item": $0.1]
            ) { item in
                print("Click \(item.userInfo ?? [:])")
            }
        }
        let gridGroup = PMActionSheetItemGroup(items: gridItems, style: .grid(2))

        let items = (0...5).map {
            PMActionSheetItem(
                style: .default(IconProvider.star, "star \($0)"),
                userInfo: ["item": "star \($0)"],
                markType: .none
            ) { item in
                print("Click \(item.userInfo ?? [:])")
                if item.markType == .none {
                    guard let group = sheet.itemGroups[safeIndex: 0] else { return }
                    group.items.first?.update(markType: .none)
                    sheet.reloadSection(0)
                }
            }
        }
        let group = PMActionSheetItemGroup(title: "Section title", items: items, style: .multiSelectionNewStyle)
        sheet = PMActionSheet(headerView: header, itemGroups: [gridGroup, group], enableBGTap: true, delegate: nil)
        sheet.presentAt(self, animated: true)
    }

    private func panStyleV2Demo() {
        PMActionSheetConfig.shared.panStyle = .v2
        PMActionSheetConfig.shared.actionSheetMaximumInitializeOccupy = 0.6
        var sheet: PMActionSheet!
        let header = PMActionSheetHeaderView(
            title: "Pan demo",
            subtitle: nil,
            leftItem: nil,
            rightItem: .left("Done"),
            leftItemHandler: nil,
            rightItemHandler: {
            sheet.dismiss(animated: true)
            })

        let items = (0...15).map {
            PMActionSheetItem(
                style: .default(IconProvider.star, "star \($0)"),
                userInfo: ["item": "star \($0)"]
            ) { item in
                print("Click \(item.userInfo ?? [:])")
            }
        }
        let group = PMActionSheetItemGroup(items: items, style: .clickable)
        sheet = PMActionSheet(headerView: header, itemGroups: [group], enableBGTap: true, delegate: self)
        sheet.presentAt(self, animated: true)
    }

    // Design is not finalized yet
    private func newSheetStyleSample() {
        PMActionSheetConfig.shared.isNewFigmaTheme = true
        PMActionSheetConfig.shared.actionSheetBackgroundColor = ColorProvider.BackgroundDeep
        PMActionSheetConfig.shared.sectionHeaderBackground = ColorProvider.BackgroundDeep
        var sheet: PMActionSheet
        let header = PMActionSheetHeaderView(title: "5 messages", subtitle: nil, leftItem: nil, rightItem: nil, leftItemHandler: nil, rightItemHandler: nil)
        let tuple1: [(UIImage, String)] = [
            (IconProvider.star, "Star"),
            (IconProvider.starSlash, "Unstar"),
            (IconProvider.envelopeDot, "Mark as unread"),
            (IconProvider.envelopeOpen, "Mark as read"),
            (IconProvider.tag, "Label as...")
        ]
        let items1 = tuple1.map { PMActionSheetItem(style: .default($0.0, $0.1), handler: nil) }
        let group1 = PMActionSheetItemGroup(title: "Manage", items: items1, style: .clickable)

        let tuple2: [(UIImage, String)] = [
            (IconProvider.trash, "Move to trash"),
            (IconProvider.archiveBox, "Archive"),
            (IconProvider.fire, "Move to spam"),
            (IconProvider.folderArrowIn, "Move to folder")
        ]
        let items2 = tuple2.map { PMActionSheetItem(style: .default($0.0, $0.1), handler: nil) }
        let group2 = PMActionSheetItemGroup(title: "Move", items: items2, style: .clickable)
        sheet = PMActionSheet(headerView: header, itemGroups: [group1, group2], delegate: self)
        sheet.presentAt(self, animated: true)
    }
}

extension UIFoundationsActionSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sampleNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = sampleNames[safeIndex: indexPath.row]
        cell.textLabel?.font = .preferredFont(forTextStyle: .subheadline)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        functions[indexPath.row]()
    }
}

extension UIFoundationsActionSheetViewController: PMActionSheetEventsListener {
    func willPresent() {

    }

    func willDismiss() {

    }

    func didDismiss() {
        PMActionSheetConfig.shared.isNewFigmaTheme = false
        PMActionSheetConfig.shared.actionSheetBackgroundColor = ColorProvider.BackgroundNorm
        PMActionSheetConfig.shared.sectionHeaderBackground = ColorProvider.BackgroundNorm
        PMActionSheetConfig.shared.panStyle = .v1
        PMActionSheetConfig.shared.actionSheetMaximumInitializeOccupy = 0.9
    }
}
