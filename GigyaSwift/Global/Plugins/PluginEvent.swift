//
//  PluginEvent.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 02/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public typealias PluginEventData = [String: Any]

public enum PluginEvent<T: GigyaAccountProtocol> {
    case onBeforeValidation(event : PluginEventData)
    case onBeforeSubmit(event: PluginEventData)
    case onSubmit(event: PluginEventData)
    case onAfterSubmit(event: PluginEventData)
    case onBeforeScreenLoad(event: PluginEventData)
    case onAfterScreenLoad(event: PluginEventData)
    case onFieldChanged(event: PluginEventData)
    case onHide(event: PluginEventData)
    case onLogin(account: T)
    case onLogout
    case onConnectionAdded
    case onConnectionRemoved
    case error(event: PluginEventData)
}
