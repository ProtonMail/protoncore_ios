//
//  Created on 7/3/24.
//
//  Copyright (c) 2024 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

import Foundation

public protocol ProductMetricsMeasurable {
    var productMetrics: ProductMetrics { get }

    func measureOnViewDisplayed()
    func measureOnViewClicked(item: String)
}

public extension ProductMetricsMeasurable {
    func measureOnViewDisplayed() {
        let event = TelemetryEvent(
            source: .fe, screen: productMetrics.screen, action: .displayed,
            measurementGroup: productMetrics.group,
            values: [
                .timestamp(Float(Date().timeIntervalSince1970))
            ],
            dimensions: [
                .flow(productMetrics.flow)
            ]
        )
        reportEvent(event: event)
    }

    func measureOnViewClicked(item: String) {
        let event = TelemetryEvent(
            source: .user, screen: productMetrics.screen, action: .clicked,
            measurementGroup: productMetrics.group,
            values: [
                .timestamp(Float(Date().timeIntervalSince1970))
            ],
            dimensions: [
                .flow(productMetrics.flow),
                .item(item)
            ]
        )
        reportEvent(event: event)
    }

    private func reportEvent(event: TelemetryEvent) {
        Task {
            await TelemetryService.shared.report(event: event)
        }
    }
}
