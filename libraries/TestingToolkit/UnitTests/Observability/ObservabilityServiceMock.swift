//
//  ObservabilityServiceMock.swift
//  ProtonCore-TestingToolkit - Created on 14.02.2023.
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
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

#if canImport(ProtonCoreTestingToolkitUnitTestsCore)
import ProtonCoreTestingToolkitUnitTestsCore
#endif
import TrustKit
import ProtonCoreObservability

public final class ObservabilityServiceMock: ObservabilityService {

    public init() {}

    private func reportNoGenerics(_ event: AggregableObservabilityEvent) {}
    @FuncStub(ObservabilityServiceMock.reportNoGenerics) public var reportStub
    public func report<Labels>(_ event: ObservabilityEvent<PayloadWithLabels<Labels>>) where Labels: Encodable, Labels: Equatable {
        reportStub(AggregableObservabilityEvent(event: event))
    }
}
