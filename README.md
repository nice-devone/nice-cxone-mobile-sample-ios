![](https://img.shields.io/badge/security-Veracode-blue)

# CXone Mobile SDK Sample App

CXone Mobile SDK lets you integrate CXone into your enterprise iOS mobile phone application with operation system iOS 13 and later.

The following are sample codes to help configure and customize application Digital First Omnichannel chat integration experience. The sample codes come from a sample app that you can get from the [Sample app](https://github.com/BrandEmbassy/cxone-mobile-sdk-ios-sample).

## Chat Provider
Whole SDK is available with shared instance via `CXoneChat.shared` which provides [`ChatProvider`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatProvider.html) with available delegates, feature providers and more.

### SDK Version
CXoneChat provides an interface to be able to check version of the SDK runtime. For this case, it is accessible with [`CXoneChat.version`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatProvider.html#/s:12CXoneChatSDK0B8ProviderP7versionSSvpZ) property. 

### SDK Logging
CXoneChat SDK provides its own logging to be able to track its flow or detect errors occured during events. Internal **LogManager** forwards errors to the host application via [`onError(_:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CXoneChatDelegate.html#/s:12CXoneChatSDK0aB8DelegateP7onErroryys0F0_pF) delegate method. You can it to your Log manager or just print messages.

```swift
extension Manager: LogDelegate {
    
    func logError(_ message: String) {
        Log.message("[SDK] \(message)")
    }
    
    func logWarning(_ message: String) {
        Log.message("[SDK] \(message)")
    }
    
    func logInfo(_ message: String) {
        Log.message("[SDK] \(message)")
    }
    
    func logTrace(_ message: String) {
        Log.message("[SDK] \(message)")
    }
}
```

### Logger Configuration
To be able to use internal logger, it is necessary to setup it with a [`configureLogger(level:verbosity:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatProvider.html#/s:12CXoneChatSDK0B8ProviderP15configureLogger5level9verbosityyAA10LogManagerC5LevelO_AH9VerbosityOtFZ) method. The method parameters specify log level and verbosity. The [level](https://cautious-sniffle-1d4a9c48.pages.github.io/Classes/LogManager/Level.html) determines which messages are going to be forwarded to the host application - `error`, `warning`, `info`, `trace`. The `error` level should be the one, if you want to receive just necessary and serious messages from the SDK. On the other hand, `trace` is the lowest level for tracking SDK so it provides detailed information about what is happening in the SDK. [Verbosity](https://cautious-sniffle-1d4a9c48.pages.github.io/Classes/LogManager/Verbosity.html) specify how detailed are messages from the internal Log manager - simple, medium, full. The minimum level is a **simple** one which logs occurrence date time and its message. The **full**, apart of that, logs file, line number and function name.

Configure the logger before first interaction with the SDK and register the log delegate.
```swift
CXoneChat.configureLogger(level: .trace, verbosity: .full)
CXoneChat.shared.logDelegate = self
```

### Chat Delegates
Host application triggers events for various situations - load threads, send message, report sender did start typing etc. Those actions are triggered manually but some events are received as a consequences of sent event. For example, when host application is about to load threads, SDK receives an event `proactiveAction` with welcome message which is not necessary connected with required thread `load()` action. SDK provides several methods described in sections [Event Delegates](#event-delegates).

Host application doesn't necessarily have to register all those methods - the SDK handles this with a default implements. Chat delegate manager can register only those are related to current scene context.

### Sign Out
Whenever user are about to log out or end the chat, the SDK provides method to signs the customer out, disconnect from the web socket and reset its services.
  > Important
  > This action also remove all stored data - customer, visitor ID, keychain etc, and creates new instance of the SDK!
```swift
@objc
func signOut() {
    CXoneChat.signOut()
    ...
}
```

## Connection
Section with connection related methods and properties. These methods allows to get channel configuration, connect to the to the CXone service or send a ping to ensure connection connection is established.

Following features are provided via [`CXoneChat.shared.connection`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ConnectionProvider.html) provider.

### Get Channel Configuration
The SDK provides two ways for channel configuration. In case host application is already connected to the CXone service, it is possible to use [`channelConfiguration`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ConnectionProvider.html#/s:12CXoneChatSDK18ConnectionProviderP20channelConfigurationAA07ChannelG0Vvp) which returns current configuration. If you call this property without established connection, it returns default configuration which is might not be related to required channel configuration.
```swift
let configuration = CXoneChat.shared.connection.channelConfiguration

// Channel is a multi-thread
if configuration.hasMultipleThreadsPerEndUser {
    ...
} else {
    ...
}
```
In case you need configuration before establishing connection or even preparing for the establishing, there is a [`getChannelConfiguration(environment:brandId:channelId:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ConnectionProvider.html#/s:12CXoneChatSDK18ConnectionProviderP23getChannelConfiguration11environment7brandId07channelK0AA0gH0VAA11EnvironmentO_SiSStYaKF) method which uses prepared [`Environemnt`](https://cautious-sniffle-1d4a9c48.pages.github.io/Enums/Environment.html). This method uses new Swift [concurrency](https://developer.apple.com/documentation/swift/updating_an_app_to_use_swift_concurrency).

For example: Get the configuration for brand **1234**, channel **"chat_abcd_1234_efgh"** and located in the **Europe**.
```swift
let configuration = try await CXoneChat.shared.connection.getChannelConfiguration(
    environment: .EU1, 
    brandId: 1234, 
    channelId: "chat_abcd_1234_efgh"
)
```

The method throws `channelConfigFailure` or `DecodingError.dataCorrupted(_:)` error when it is not possible to initialize connection URL or decode URL response.

### Establish the Connection
Same as getting channel configuration method, establishing a connection with method [connect(environment:brandId:channelId:)](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ConnectionProvider.html#/s:12CXoneChatSDK18ConnectionProviderP7connect11environment7brandId07channelI0yAA11EnvironmentO_SiSStYaKF) uses prepared [Environment](https://cautious-sniffle-1d4a9c48.pages.github.io/Enums/Environment.html). It uses new Swift [concurrency](https://developer.apple.com/documentation/swift/updating_an_app_to_use_swift_concurrency).

For example: Connect to the brand **1234**, channel **"chat_abcd_1234_efgh"** and located in the **Europe**.
```swift
try await CXoneChat.shared.connection.connect(
    environment: .EU1, 
    brandId: 1234, 
    channelId: "chat_abcd_1234_efgh"
)
```

### Disconnect from CXone Service
Whenever host application should keep customer logged in and sign out from CXone service, use [`disconnect()`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ConnectionProvider.html#/s:12CXoneChatSDK18ConnectionProviderP10disconnectyyF). It keep connection context and just invalides the web socket.
```swift
CXoneChatSDK.shared.connection.disconnect()
```

### Ping the Chat Server
The SDK provides [`ping()`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ConnectionProvider.html#/s:12CXoneChatSDK18ConnectionProviderP4pingyyF) method to check if SDK is connected to the server. In case of any error, the SDK logs the error via internal Log Manager.
```swift
CXoneChatSDK.shared.connection.ping()
```

### Execute Trigger Manually
CXone platform can contain various triggers related to specific events. Host application can trigger it manually via [`executeTrigger(_:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ConnectionProvider.html#/s:12CXoneChatSDK18ConnectionProviderP14executeTriggeryy10Foundation4UUIDVKF) method based on its unique identifier. This method throws a `missingParameter` error in case of not established connection and missing customer.
```swift
if let triggerId = UUID(uuidString: "1a2bc345-6789-12a3-4Bbc-d67890e12fhg") {
    do {
        try CXoneChat.shared.connection.executeTrigger(triggerId)
    } catch {
        ...
    }
}
```

## Customer
Section with customer related methods and properties. These methods allows to retrieve or set current customer, set OAuth stuff or just update customer credentials.

Following features are provided via [`CXoneChat.shared.customer`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CustomerProvider.html) provider.

### Get Current Customer
The [`get()`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CustomerProvider.html#/s:12CXoneChatSDK16CustomerProviderP3getAA0D8IdentityVSgyF) returns a customer who is currently using host application. When establishing a connection, the SDK initialize new customer with empty credentials, so this method returns a customer with nil first and last name.
```swift
let customer = CXoneChat.shared.customer.get()
```

### Set Current Customer
[set(_:)](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CustomerProvider.html#/s:12CXoneChatSDK16CustomerProviderP3setyyAA0D8IdentityVSgF) a customer can be used to update empty credentials, creating new one or removing the current.
> Important
> Some features are available only when any customer is set. Setting `nil` customer might impact usability of the SDK.
```swift
// Update current
var customer = CXoneChat.shared.customer.get()
customer.firstName = "John"
customer.lastName = "Doe"
CXoneChat.shared.customer.set(customer)

// Create new
let customer = Customer(id: UUID().uuidString, firstName: "John", lastName: "Doe")
CXoneChat.shared.customer.set(customer)

// Reset current
CXoneChat.shared.customer.set(nil)
```

### Set Device Token
It is necessary to register device to be able to use push notifications. For this case, the SDK provides two methods - [first](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CustomerProvider.html#/s:12CXoneChatSDK16CustomerProviderP14setDeviceTokenyySSF) uses a *String* representation of the token, [second](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CustomerProvider.html#/s:12CXoneChatSDK16CustomerProviderP14setDeviceTokenyy10Foundation4DataVF) uses `Data` data type.
```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    CXoneChat.shared.customer.setDeviceToken(deviceToken)
}
```

### Set Authorization Code
The SDK supports OAuth user authorization. For this feature, application has to provide the code with [`setAuthorizationCode(_:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CustomerProvider.html#/s:12CXoneChatSDK16CustomerProviderP20setAuthorizationCodeyySSF) to be able to obtain an access token. It has to be obtained before establishing a connection via `connect()` methods. 

Example from he sample application uses Amazon OAuth:
```swift
AMZNAuthorizationManager.shared().authorize(request) { [weak self] result, _, error in
    ...
    CXoneChat.shared.customer.setAuthorizationCode(result.authorizationCode)
    ...
}
```

### Set Code Verifier
The SDK supports OAuth 2.0 which uses proof key for code exchange - [PKCE](https://oauth.net/2/pkce/). Above setting the authorization code, it is necessary to provide a code verifier with [`setCodeVerifier(_:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CustomerProvider.html#/s:12CXoneChatSDK16CustomerProviderP15setCodeVerifieryySSF), which is forwarded in the request to the OAuth authorization manager. Code verifier has to be passed so CXone can retrieve an authorization token. 

The sample application uses third party framework [Swift-PKCE](https://github.com/hendrickson-tyler/swift-pkce) to be able to generate code verifier.
```swift
let request = AMZNAuthorizeRequest()
...

do {
    let codeVerifier = try generateCodeVerifier()
    request.codeChallenge = try generateCodeChallenge(for: codeVerifier)

    CXoneChat.shared.customer.setCodeVerifier(codeVerifier)
} catch {
    ...
}

AMZNAuthorizationManager.shared().authorize(request) { [weak self] result, _, error in
    ...
}
```

### Set Customer Name
Method [`setName(firstName:lastName:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CustomerProvider.html#/s:12CXoneChatSDK16CustomerProviderP7setName05firstG004lastG0ySS_SStF) updates a customer name, even with empty values or initialize new one when the customer has been set to `nil` with [`set(_:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CustomerProvider.html#/s:12CXoneChatSDK16CustomerProviderP3setyyAA0D8IdentityVSgF) method.

In the sample application, user credentials are provided with pre-chat survey and parsed from the custom fields.
```swift
let controller = FormViewController(entity: enity) { [weak self] customFields in
    CXoneChat.shared.customer.setName(
        firstName: customFields.first { $0.key == "firstName" }.map(\.value) ?? "",
        lastName: customFields.first { $0.key == "lastName" }.map(\.value) ?? ""
    )

    ...
}
```

## Customer Custom Fields
Section with custom fields related methods. These methods allows to contact, specific thread, or customer, persists across all threads, custom fields.

Following features are provided via [`CXoneChat.shared.customFields`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CustomerCustomFieldsProvider.html) provider.

### Set Customer Custom Fields
Customer custom fields are related to the customer and across all chat cases (threads). The [`set(_:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CustomerCustomFieldsProvider.html#/s:12CXoneChatSDK28CustomerCustomFieldsProviderP3setyySDyS2SGKF) method has to be called only with established connection to the CXone service; otherwise, it throws and error.
```swift
CXoneChat.shared.customeFields.set(["age": "29"])
```

### Get Customer Custom Fields
Method [`get()`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CustomerCustomFieldsProvider.html#/s:12CXoneChatSDK28CustomerCustomFieldsProviderP3getSDyS2SGyF) returns key-value pairs if any customer custom fields exists; otherwise, it returns empty array.
```swift
let ageCustomField = CXoneChat.shared.customeFields
    .get()
    .first { $0.key == "age" }
```

## Chat Threads
You can make your app single- or multi-threaded. If your app is single-threaded, each of your contacts can have only one chat thread. Any interaction they have with your organization takes place in that one chat thread. If your app is multi-threaded, your contacts can create as many threads as they want to discuss new topics. These threads can be active at the same time.
 Threads provider allows to get current or load thread/s, create new one, archive or even mark thread a read.
 
 Following features are provided via [`CXoneChat.shared.threads`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatThreadsProvider.html) provider.

> Important
> Threads provider also contain providers for message and contact custom fields according to its context.

### Get Current Threads
Retrieving an array of current threads is provided with the [`get()`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatThreadsProvider.html#/s:12CXoneChatSDK0B15ThreadsProviderP3getSayAA0B6ThreadVGyF) method. It returns threads if any exist; otherwise, it returns empty array.
```swift
documentState.threads = CXoneChat.shared.threads
    .get()
    .filter(\.canAddMoreMessages)
```

### Create New Thread
For creating a new array, the SDK provides [`create()`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatThreadsProvider.html#/s:12CXoneChatSDK0B15ThreadsProviderP6create10Foundation4UUIDVyKF) method. Mandatory is to have established connection to the CXone service. Also, if your channel does not support multi-channel configuration, you should not call this method, if you already have a thread. On the other hand, the SDK throws  `unsupportedChannelConfig` error. This method also returns unique identifier of newly created thread.
```swift
let threadId = try CXoneChat.shared.threads.create()

guard  let thread = CXoneChat.shared.threads.get().thread(by: threadId) else {
    ...
}
...
```

### Load Thread/s
The SDK provides two load methods. [First](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatThreadsProvider.html#/s:12CXoneChatSDK0B15ThreadsProviderP4loadyyKF) one loads all of the threads for the current customer which should be called only for multi-thread channel configuration or if you are convinced you don't have any existing threads. Also, it has to be called when connection is established. [Second](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatThreadsProvider.html#/s:12CXoneChatSDK0B15ThreadsProviderP4load4withy10Foundation4UUIDVSg_tKF) method uses a thread ID to load specific or when you pass `nil`, it will try to load active thread. If there is no active thread, this returns an error which is forwarded to the [`onThredLoadFail(_:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CXoneChatDelegate.html#/s:12CXoneChatSDK0aB8DelegateP16onThreadLoadFailyys5Error_pF) delegate method.

> Important
> Load error should be marked as a soft error because it means there are just no available thread/s.

```swift
func loadThreads() throws {
    if documentState.isMultiThread {
        try CXoneChat.shared.threads.load()
    } else {
        try CXoneChat.shared.threads.load(with: nil)
    }
}
```

### Load Thread Information
[`loadInfo(for:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatThreadsProvider.html#/s:12CXoneChatSDK0B15ThreadsProviderP8loadInfo3foryAA0B6ThreadV_tKF) loads metadata of the thread. It also provides the move reset message for the thread so can use this to show a preview of the last message. It is necessary to have established connection. On the other hand, it throws and error. 
```swift
func updateThreadsMetadata() throws {
    try CXoneChat.shared.threads.get().forEach { thread in
        try CXoneChat.shared.threads.loadInfo(for: thread)
    }
}
```

### Update Thread Name
Updating thread name with [`updateName(_:for:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatThreadsProvider.html#/s:12CXoneChatSDK0B15ThreadsProviderP10updateName_3forySS_10Foundation4UUIDVtKF) method is available only for multi-thread channel configuration. Also it has to be called only when connection is established and for existing thread. If one of this condition is not satisifed, it throws and error.
```swift
do {
    try CXoneChat.shared.threads.updateName(title, for: self.documentState.thread.id)
} catch {
    ...
}
```

### Archive Thread
[archive(_:)](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatThreadsProvider.html#/s:12CXoneChatSDK0B15ThreadsProviderP7archiveyyAA0B6ThreadVKF) method change thread property `canAddMoreMessages` so user can not communicate with an agent in selected thread. Method is available only for multi-thread channel configuration and with established connection. Any other way it throws an error.
```swift
func onThreadSwipeToDelete(_ thread: ChatThread) {
    ...

    do {
        try CXoneChat.shared.threads.archive(thread)
        ...
    } catch {
    ...
    }
}
```

### Mark Thread as Read
The SDK provides [`markRead(_:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatThreadsProvider.html#/s:12CXoneChatSDK0B15ThreadsProviderP8markReadyyAA0B6ThreadVKF) method which reports that the most recept message, of the specific thread, was ready by the customer.
```swift
do {
    try CXoneChat.shared.threads.markRead(thread)
} catch {
    ...
}
```

### Report Typing Start/End
[`reportTypingStart(_: in:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ChatThreadsProvider.html#/s:12CXoneChatSDK0B15ThreadsProviderP17reportTypingStart_2inySb_AA0B6ThreadVtKF) reports the customer has started or finished typing in the specified chat thread. It is necessary to have established connection; otherwise, it throws and error.
```swift
func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
    ...
    try CXoneChat.shared.threads.reportTypingStart(true, in: presenter.documentState.thread)
    
    ...
    self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer  in
        ...
        try  CXoneChat.shared.threads.reportTypingStart(false, in: self.presenter.documentState.thread)
    }
}
```

## Thread Messages
Section with thread messages related methods. These methods allows to load additional messages and send a message.

Following features are provided via [`CXoneChat.shared.threads.messages`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/MessagesProvider.html) provider.

### Load More Messages
 [loadMore(for:)](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/MessagesProvider.html#/s:12CXoneChatSDK16MessagesProviderP8loadMore3foryAA0B6ThreadV_tKF) loads another page of messages for the thread. By default, when a user loads an old thread, they see a page of 20 messages. This function loads 20 more messages if the user scrolls up and swipe down to load more.
```swift
@objc
func didPullToRefresh() {
    if presenter.documentState.thread.hasMoreMessagesToLoad {
        do {
            try CXoneChat.shared.threads.messages.loadMore(for: presenter.documentState.thread)
        } catch {
            ...
        }
    } else {
        ...
    }
}
```

### Send a Message
Sends the contact's message string, via [`send(_:for:`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/MessagesProvider.html#/s:12CXoneChatSDK16MessagesProviderP4send_3forySS_AA0B6ThreadVtYaKF) method, through the WebSocket to the thread it belongs to. It uses new Swift [concurrency](https://developer.apple.com/documentation/swift/updating_an_app_to_use_swift_concurrency). It is necessary to have established connection; otherwise, it throws and error.
```swift
Task { @MainActor in
    do {
        try await CXoneChat.shared.threads.messages.send(text, for: presenter.documentState.thread)
    } catch {
        ...
    }
}
```

### Send a Message with an Attachment
Sends images and other attachments, via [`send(_:with:for:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/MessagesProvider.html#/s:12CXoneChatSDK16MessagesProviderP4send_4with3forySS_SayAA16AttachmentUploadVGAA0B6ThreadVtYaKF) from the contact to the agent. Contacts can upload more than one at a time. It uses new Swift [concurrency](https://developer.apple.com/documentation/swift/updating_an_app_to_use_swift_concurrency). It is necessary to have established connection; otherwise, it throws and error. It also throws and error when attachment sending process failed.
```swift
Task { @MainActor in
    do {
        try await CXoneChat.shared.threads.messages.send(
            message, 
            with: attachments, 
            for: presenter.documentState.thread
        )
    }
}
```

## Thread Custom Fields
Section with contact custom fields related methods. These methods allows to get and set contact, specific thread, custom fields.

Following features are provided via [`CXoneChat.shared.threads.customFields`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ContactCustomFieldsProvider.html) provider.

### Set Contact Custom Fields
Contact custom fields are related to the customer and specific chat case (thread). [`set(_:for:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ContactCustomFieldsProvider.html#/s:12CXoneChatSDK27ContactCustomFieldsProviderP3set_3forySDyS2SG_10Foundation4UUIDVtKF) stores custom fields based on thread unique identifier. This method has to be called only with established connection to the CXone service; otherwise, it throws and error.
```swift
let controller = FormViewController(entity: entity) { [weak  self] customFields in
    ...
    do {
        try CXoneChat.shared.threads.customFields.set(customFields, for: self.documentState.thread.id)
    } catch {
        ...
    }
}
```

### Get Contact Custom Fields
Retrieving contact custom fields with method [`get(for:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/ContactCustomFieldsProvider.html#/s:12CXoneChatSDK27ContactCustomFieldsProviderP3get3forSDyS2SG10Foundation4UUIDV_tF) is based on the unique thread identifier. If custom fields exists, it returns key-value pairs; otherwise, it returns empty array.
```swift
let locationCustomField = CXoneChat.shared.threads.customFields
    .get(for: documentState.thread.id)
    .first { $0.key == "location" }
```


## Analytics
The SDK allows to report several events from the client side. You can report open the application, page view, proactive actions or even when customer did start typing.

Following features are provided via [`CXoneChat.shared.analytics`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/AnalyticsProvider.html) provider.

### Get VisitorID
Whenever you need customer visitor identifier, this provider allows it. It is necessary to be connected to the CXone service because this identifier generates with establishing a connection; otherwise, it returns nil.
```swift
let visitorId = CXoneChat.shared.analytics.visitorId
```

### Application Visit
Method [`visit()`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/AnalyticsProvider.html#/s:12CXoneChatSDK15AnalyticsProviderP5visityyKF) reports to CXone service visitor has visited the application. It is necessary to have established connection; otherwise, it throws and error.
```swift
func onConnect() {
    ...
    do {
        ...
        try CXoneChat.shared.analytics.visit()
        ...
    } catch {
        ...
    }
}
```

### View Page
The SDK provides [viewPage(title:uri:)](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/AnalyticsProvider.html#/s:12CXoneChatSDK17AnalyticsProviderP8viewPage5title3uriySS_SStKF) method which reports to CXone service some page in the application has been viewed by the visitor. It reports its title and uri. It is necessary to have established connection; otherwise, it throws and error.
```swift
func onViewWillAppear() {
    ...
    do {
        try CXoneChat.shared.analytics.viewPage(title: "ChatView", uri: "chat-view")
    } catch {
        ...
    }
}
```
### Chat Window Open
[`chatWindowOpen()`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/AnalyticsProvider.html#/s:12CXoneChatSDK15AnalyticsProviderP14chatWindowOpenyyKF) reports to CXone the chat window has been opened by the visitor. It is necessary to have established connection; otherwise, it throws and error.
```swift
func onConnect() {
    ...
    do {
        ...
        CXoneChat.shared.analytics.chatWindowOpen()
        ...
	} catch {
        ...
    }
}
```
### Conversion
[`conversion(type:value:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/AnalyticsProvider.html#/s:12CXoneChatSDK15AnalyticsProviderP10conversion4type5valueySS_SdtKF) is an event which notifes the backend that a conversion has been made. Conversions are understood as a completed activities that are important to your business. It is necessary to have established connection; otherwise, it throws and error.
```swift
try CXoneChat.shared.analytics.conversion(type: conversionType, value: conversionValue)
```

### Custom Visitor Event
[customVisitorEvent(data:)](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/AnalyticsProvider.html#/s:12CXoneChatSDK15AnalyticsProviderP18customVisitorEvent4datayAA0gH8DataTypeO_tKF) can report to CXone service some event, which is not covered by other existing methods, occurred with the visitor. It is necessary to have established connection; otherwise, it throws and error.
```swift
try CXoneChat.analytics.customVisitorEvent(data: .custom(eventData))
```

### Proactive Action Display
[`proactiveActionDisplay(data:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/AnalyticsProvider.html#/s:12CXoneChatSDK15AnalyticsProviderP22proactiveActionDisplay4datayAA09ProactiveG7DetailsV_tKF) reports proactive action was displayed to the visitor in the application. It is necessary to have established connection; otherwise, it throws and error.
```swift
func setup() {
    ...
    try? CXoneChat.shared.analytics.proactiveActionDisplay(data: actionDetails)
}
```

### Proactive Action Click
[`proactiveActionClick(data:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/AnalyticsProvider.html#/s:12CXoneChatSDK15AnalyticsProviderP20proactiveActionClick4datayAA09ProactiveG7DetailsV_tKF) reports proactive action was clicked or acted upon by the visitor. It is necessary to have established connection; otherwise, it throws and error.
```swift
func setup() {
    ...
    try? CXoneChat.shared.analytics.proactiveActionClick(data: actionDetails)
}
```

### Proactive Action Success/Failure
[`proactiveActionSuccess(_: data:)`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/AnalyticsProvider.html#/s:12CXoneChatSDK15AnalyticsProviderP22proactiveActionSuccess_4dataySb_AA09ProactiveG7DetailsVtKF) reports proactive action was successful or fails and lead to a conversion based on `Bool` given in the parameter. It is necessary to have established connection; otherwise, it throws and error.
```swift
@objc
func fireTimer() {
    ...
    do {
        try CXoneChat.shared.analytics.proactiveActionSuccess(false, data: actionDetails)
    } catch {
        ...
    }
}
```

## Event Delegates
The following are examples, from the sample application, of actions that can occur during a chat that you might want to have trigger an action. These [`CXoneChatDelegate`](https://cautious-sniffle-1d4a9c48.pages.github.io/Protocols/CXoneChatDelegate.html) events might cause a notification to appear, a new page to open, or some other action to occur.

### On Connect
Callback to be called when the connection has successfully been established.
```swift
extension ThreadListPresenter: CXoneChatDelegate {

    func onConnect() {
        documentState.isConnected = true

        do {
            try loadThreads()

            try CXoneChat.shared.analytics.chatWindowOpen()
            try CXoneChat.shared.analytics.viewPage(title: "ThreadList", uri: "thread-view")
        } catch {
            error.logError()
            viewState.toError(title: "Ops!", message: error.localizedDescription)
        }
    }
}
```

### On Unexpected Disconnect
Callback to be called when the connection unexpectedly drops.
```swift
extension ThreadListPresenter: CXoneChatDelegate {

    func onUnexpectedDisconnect() {
        documentState.isConnected = false

        viewState.toError(title: "Connection Dropped", message: "Please sign in again.")
    }
}
```

### On Thread Load
Callback to be called when a thread has been loaded/recovered.
```swift
extension ThreadDetailViewController: CXoneChatDelegate {

    func onThreadLoad(_ thread: ChatThread) {
        DispatchQueue.main.async {
            self.hideLoading()

            self.updateThreadData()

            self.scrollToBottomIfNeeded()
        }
    }
}
```


### On Thread Archive
Callback to be called when a thread has been archived.
```swift
extension ThreadListPresenter: CXoneChatDelegate {

    func onThreadArchive() {
        fetchThreads()
    }
}
```

### On Threads Load
Callback to be called when all of the threads for the customer have loaded.
```swift
extension ThreadListPresenter: CXoneChatDelegate {

    func onThreadsLoad(_ threads: [ChatThread]) {
        fetchThreads()
    }
}
```

### On Thread Info Load
Callback to be called when thread info has loaded.
```swift
extension ThreadListPresenter: CXoneChatDelegate {

    func onThreadInfoLoad(_ thread: ChatThread) {
        fetchThreads()
    }
}
```

### On Thread Update
Callback to be called when the thread has been updates (thread name changed).
```swift
extension ThreadListPresenter: CXoneChatDelegate {

    func onThreadUpdate() {
        fetchThreads()
    }
}
```

### On Load More Messages
Callback to be called when a new page of message has been loaded.
```swift
extension ThreadDetailViewController: CXoneChatDelegate {

    func onLoadMoreMessages(_ messages: [Message]) {
        DispatchQueue.main.async {
            self.myView.refreshControl.endRefreshing()
        }

        updateThreadData()
    }
}
```

### On New Message
Callback to be called when a new message arrives.
```swift
extension ThreadDetailViewController: CXoneChatDelegate {

    func onNewMessage(_  message: Message) {
        if message.threadId == presenter.documentState.thread.id {
            DispatchQueue.main.async {
                self.updateThreadData()

                (self.inputAccessoryView as? InputBarAccessoryView)?.sendButton.stopAnimating()
                (self.inputAccessoryView as? InputBarAccessoryView)?.inputTextView.placeholder = "Aa"

                self.scrollToBottomIfNeeded()
            }
        } else {
            presenter.onMessageReceivedFromOtherThread(message)
        }
    }
}
```

### On Custom Plugin Message
Callback to be called when a custom plugin message is received.
```swift
extension ThreadDetailViewController: CXoneChatDelegate {

    func onCustomPluginMessage(_ messageData: [Any]) {
        Log.info("Plugin message received")

        viewState.toLoaded(documentState: documentState)
}
```

### On Agent Change
Callback to be called when the agent for the contact has changed.
```swift
extension ThreadDetailViewController: CXoneChatDelegate {
    
    func onAgentChange(_ agent: Agent, for  threadId: UUID) {
        presenter.documentState.thread.assignedAgent = agent

        if !CXoneChat.shared.connection.channelConfiguration.hasMultipleThreadsPerEndUser {
            DispatchQueue.main.async {
                self.navigationItem.title = agent.fullName.mapNonEmpty { $0 } ?? "No Name"
            }
        }
    }
}
```

### On Agent Read Message
Callback to be called when the agent has read a message.
```swift
extension ThreadDetailViewController: CXoneChatDelegate {

    func onAgentReadMessage(threadId: UUID) {
        updateThreadData()
    }
}
```

### On Agent Typing Started/Ended
Callback to be called when the agent has stopped typing.
```swift
extension ThreadDetailViewController: CXoneChatDelegate {

    func onAgentTyping(_ didEnd: Bool, id: UUID) {
        guard id == presenter.documentState.thread.id  else {
            Log.error("Did start typing in unknown thread.")
            return
        }
        guard timer == nil else {
            Log.error("Could not handle typing indicator because timer is not nil.")
            return
        }
		
        if didEnd {
            setTypingIndicatorViewHidden(true, performUpdates: nil)
        } else {
            setTypingIndicatorViewHidden(false) {
                DispatchQueue.main.async {
                    self.scrollToBottomIfNeeded()
                }
            }
        }
    }
}
```

### On Contact Custom Fields Set
Callback to be called when the custom fields are set for a contact.
```swift
func onContactCustomFieldsSet() {
    Log.message("Contact custom fields did set.")

    ...
}
```

### On Customer Custom Fields Set
Callback to be called when the custom fields are set for a customer.
```swift
func onCustomerCustomFieldsSet() {
    Log.message("Customer custom fields did set.")

    ...
}
```

### On Error
Callback to be called when an error occurs.
```swift
extension ThreadDetailViewController: CXoneChatDelegate {

    func onError(_  error: Error) {
        error.logError()

        DispatchQueue.main.async {
            self.hideLoading()

            self.myView.refreshControl.endRefreshing()
        }
    }
}
```

### On Token Refresh Failed
Callback to be called when refreshing the token has failed.
```swift
extension ThreadListPresenter: CXoneChatDelegate {

    func onTokenRefreshFailed() {
        CXoneChat.shared.customer.set(nil)

        navigation.navigateToLogin()
    }
}
```

### On Welcome Message Received
Callback to be called when a welcome message proactive action has been received.
```swift
func onWelcomeMessageReceived() {
    Log.message("Welcome message did receive.")
    ...
}
```

### On Proactive Popup Action
Callback to be called when a custom popup proactive action is received.
```swift
extension ThreadListPresenter: CXoneChatDelegate {

    func onProactivePopupAction(data: [String: Any], actionId: UUID) {
        navigation.showProactiveActionPopup(data, actionId)
    }
}
```
