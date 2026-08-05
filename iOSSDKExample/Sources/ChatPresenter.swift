//
// Copyright (c) 2021-2026. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN "AS IS" BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import CXoneChatSDK
import CXoneChatUI
import SwiftUI
import UIKit

/// Owns chat-presentation state and lifecycle: whether SwiftUI's `.sheet` /
/// `.navigationDestination` is currently bound to chat, which presentation style to use,
/// the active deeplink, and the bridge `ChatCoordinator` instance that drives the SDK UI.
///
/// Owns the injected ``ChatProvider`` and exposes it as ``chatProvider`` so the host app
/// (`AppDelegate`, view models that need SDK-level calls like analytics or sign-out) can
/// reach it without ever falling back to a global singleton.
@MainActor
class ChatPresenter: ObservableObject, ChatPresenting {

    // MARK: - Properties

    let chatProvider: ChatProvider
    let chatCoordinator: MyChatCoordinator

    @Published var isPresented = false

    /// Treated as immutable for the duration of a single presentation — `open(...)` snapshots
    /// the user's setting into this property before flipping `isPresented`, and the
    /// `StoreView` `.sheet` / `.navigationDestination` bindings read it via the same
    /// instance. Do not mutate from outside `open(...)`.
    @Published var presentationStyle: ChatPresentationStyle = .modal

    var deeplinkOption: DeeplinkOption?

    // MARK: - Init

    init(chatProvider: ChatProvider) {
        self.chatProvider = chatProvider
        self.chatCoordinator = MyChatCoordinator(chatProvider: chatProvider)
    }

    // MARK: - Methods

    /// Push host-app custom fields into the SDK's `chatConfiguration`, then present chat.
    func open(deeplinkOption: DeeplinkOption? = nil) {
        chatCoordinator.prepareAdditionalFields()
        self.deeplinkOption = deeplinkOption
        presentationStyle = LocalStorageManager.chatPresentationStyle ?? .modal
        isPresented = true
    }

    /// Dismiss chat and reset the UIKit appearance globals the chat SDK customised so its
    /// branding does not bleed back into the host app's other screens.
    func dismiss() {
        Task { @MainActor in
            isPresented = false
        }
        
        deeplinkOption = nil
    }

    /// Refresh the chat coordinator's `ChatStyle` after the user changes brand colours in Settings.
    func onChatStyleChanged() {
        chatCoordinator.chatStyle = ChatAppearance.getChatStyle()
    }
}
