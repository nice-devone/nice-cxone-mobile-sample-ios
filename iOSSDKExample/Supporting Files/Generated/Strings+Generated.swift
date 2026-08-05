// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Cart {
    /// Shopping Cart
    internal static let title = L10n.tr("Localizable", "cart.title", fallback: "Shopping Cart")
    internal enum Empty {
      /// Your cart is empty.
      internal static let title = L10n.tr("Localizable", "cart.empty.title", fallback: "Your cart is empty.")
    }
    internal enum Summary {
      /// Order Summary
      internal static let title = L10n.tr("Localizable", "cart.summary.title", fallback: "Order Summary")
      /// Total
      internal static let totalTitle = L10n.tr("Localizable", "cart.summary.total_title", fallback: "Total")
      internal enum Checkout {
        /// Checkout
        internal static let title = L10n.tr("Localizable", "cart.summary.checkout.title", fallback: "Checkout")
      }
      internal enum Shipping {
        /// Free
        internal static let free = L10n.tr("Localizable", "cart.summary.shipping.free", fallback: "Free")
        /// Shipping
        internal static let title = L10n.tr("Localizable", "cart.summary.shipping.title", fallback: "Shipping")
      }
      internal enum Vat {
        /// Included
        internal static let included = L10n.tr("Localizable", "cart.summary.vat.included", fallback: "Included")
        /// VAT
        internal static let title = L10n.tr("Localizable", "cart.summary.vat.title", fallback: "VAT")
      }
    }
  }
  internal enum Common {
    /// Add
    internal static let add = L10n.tr("Localizable", "common.add", fallback: "Add")
    /// Attention
    internal static let attention = L10n.tr("Localizable", "common.attention", fallback: "Attention")
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "common.cancel", fallback: "Cancel")
    /// Close
    internal static let close = L10n.tr("Localizable", "common.close", fallback: "Close")
    /// Confirm
    internal static let confirm = L10n.tr("Localizable", "common.confirm", fallback: "Confirm")
    /// Continue
    internal static let `continue` = L10n.tr("Localizable", "common.continue", fallback: "Continue")
    /// Disconnect
    internal static let disconnect = L10n.tr("Localizable", "common.disconnect", fallback: "Disconnect")
    /// Invalid e-mail
    internal static let invalidEmail = L10n.tr("Localizable", "common.invalid_email", fallback: "Invalid e-mail")
    /// Invalid number
    internal static let invalidNumber = L10n.tr("Localizable", "common.invalid_number", fallback: "Invalid number")
    /// OK
    internal static let ok = L10n.tr("Localizable", "common.ok", fallback: "OK")
    /// Required field
    internal static let requiredField = L10n.tr("Localizable", "common.required_field", fallback: "Required field")
    /// Search
    internal static let search = L10n.tr("Localizable", "common.search", fallback: "Search")
    /// Sign Out
    internal static let signOut = L10n.tr("Localizable", "common.sign_out", fallback: "Sign Out")
  }
  internal enum Configuration {
    /// Configurations
    internal static let configurationSelectionTitle = L10n.tr("Localizable", "configuration.configuration_selection_title", fallback: "Configurations")
    /// Environments
    internal static let environmentSelectionTitle = L10n.tr("Localizable", "configuration.environment_selection_title", fallback: "Environments")
    /// Fetching configurations...
    internal static let loadingTitle = L10n.tr("Localizable", "configuration.loading_title", fallback: "Fetching configurations...")
    /// Configuration
    internal static let title = L10n.tr("Localizable", "configuration.title", fallback: "Configuration")
    internal enum Custom {
      /// Use a custom configuration
      internal static let buttonTitle = L10n.tr("Localizable", "configuration.custom.button_title", fallback: "Use a custom configuration")
      /// Configuration
      internal static let configurationLabel = L10n.tr("Localizable", "configuration.custom.configuration_label", fallback: "Configuration")
    }
    internal enum Default {
      /// Brand ID
      internal static let brandIdPlaceholder = L10n.tr("Localizable", "configuration.default.brand_id_placeholder", fallback: "Brand ID")
      /// Use a default configuration
      internal static let buttonTitle = L10n.tr("Localizable", "configuration.default.button_title", fallback: "Use a default configuration")
      /// Channel ID
      internal static let channelIdPlaceholder = L10n.tr("Localizable", "configuration.default.channel_id_placeholder", fallback: "Channel ID")
      /// Environment
      internal static let environmentLabel = L10n.tr("Localizable", "configuration.default.environment_label", fallback: "Environment")
      internal enum MissingFields {
        /// Please provide a value for all fields.
        internal static let message = L10n.tr("Localizable", "configuration.default.missing_fields.message", fallback: "Please provide a value for all fields.")
        /// All Fields Required
        internal static let title = L10n.tr("Localizable", "configuration.default.missing_fields.title", fallback: "All Fields Required")
      }
    }
    internal enum UserDetails {
      /// Setting this property can simulate OAuth behaviour. Conversations are associated with the user based on the ID.
      internal static let customerIdDescription = L10n.tr("Localizable", "configuration.user_details.customer_id_description", fallback: "Setting this property can simulate OAuth behaviour. Conversations are associated with the user based on the ID.")
      /// Customer ID
      internal static let customerIdPlaceholder = L10n.tr("Localizable", "configuration.user_details.customer_id_placeholder", fallback: "Customer ID")
    }
  }
  internal enum Debug {
    internal enum Logs {
      /// Remove Logs
      internal static let remove = L10n.tr("Localizable", "debug.logs.remove", fallback: "Remove Logs")
      /// Share Logs
      internal static let share = L10n.tr("Localizable", "debug.logs.share", fallback: "Share Logs")
      /// Options
      internal static let title = L10n.tr("Localizable", "debug.logs.title", fallback: "Options")
    }
  }
  internal enum Error {
    internal enum Generic {
      /// Something went wrong. Try it again later or contact the CXone Mobile team.
      internal static let message = L10n.tr("Localizable", "error.generic.message", fallback: "Something went wrong. Try it again later or contact the CXone Mobile team.")
      /// Oops!
      internal static let title = L10n.tr("Localizable", "error.generic.title", fallback: "Oops!")
    }
    internal enum UnsupportedSdkVersion {
      /// The SDK version you are using is not supported. Please update to a supported version to continue.
      internal static let message = L10n.tr("Localizable", "error.unsupported_sdk_version.message", fallback: "The SDK version you are using is not supported. Please update to a supported version to continue.")
    }
  }
  internal enum FileLoader {
    /// Take from Camera
    internal static let camera = L10n.tr("Localizable", "file_loader.camera", fallback: "Take from Camera")
    /// Choose from File Manager
    internal static let fileManager = L10n.tr("Localizable", "file_loader.file_manager", fallback: "Choose from File Manager")
    /// Image from Library
    internal static let imageFromLibrary = L10n.tr("Localizable", "file_loader.image_from_library", fallback: "Image from Library")
    /// Remove
    internal static let remove = L10n.tr("Localizable", "file_loader.remove", fallback: "Remove")
    /// Choose your Image
    internal static let title = L10n.tr("Localizable", "file_loader.title", fallback: "Choose your Image")
  }
  internal enum Form {
    /// %@ is required
    internal static func requiredField(_ p1: Any) -> String {
      return L10n.tr("Localizable", "form.required_field", String(describing: p1), fallback: "%@ is required")
    }
  }
  internal enum Login {
    /// Login
    internal static let title = L10n.tr("Localizable", "login.title", fallback: "Login")
    internal enum ConfigurationFetchFailed {
      /// Unable to load channel configuration for brand ID "%1$d" and channel ID "%2$@"
      internal static func message(_ p1: Int, _ p2: Any) -> String {
        return L10n.tr("Localizable", "login.configuration_fetch_failed.message", p1, String(describing: p2), fallback: "Unable to load channel configuration for brand ID \"%1$d\" and channel ID \"%2$@\"")
      }
    }
    internal enum Guest {
      /// Continue as guest
      internal static let buttonTitle = L10n.tr("Localizable", "login.guest.button_title", fallback: "Continue as guest")
      /// OR
      internal static let dividerTitle = L10n.tr("Localizable", "login.guest.divider_title", fallback: "OR")
      internal enum UserDetails {
        /// First Name
        internal static let firstName = L10n.tr("Localizable", "login.guest.user_details.first_name", fallback: "First Name")
        /// John
        internal static let firstNamePlaceholder = L10n.tr("Localizable", "login.guest.user_details.first_name_placeholder", fallback: "John")
        /// Last Name
        internal static let lastName = L10n.tr("Localizable", "login.guest.user_details.last_name", fallback: "Last Name")
        /// Doe
        internal static let lastNamePlaceholder = L10n.tr("Localizable", "login.guest.user_details.last_name_placeholder", fallback: "Doe")
      }
    }
    internal enum Oauth {
      /// Available OAuth providers
      internal static let availableProvidersTitle = L10n.tr("Localizable", "login.oauth.available_providers_title", fallback: "Available OAuth providers")
      /// Sign in with Google
      internal static let buttonTitle = L10n.tr("Localizable", "login.oauth.button_title", fallback: "Sign in with Google")
      internal enum Disabled {
        /// OAuth login is disabled. Please use guest login or update channel configuration.
        internal static let description = L10n.tr("Localizable", "login.oauth.disabled.description", fallback: "OAuth login is disabled. Please use guest login or update channel configuration.")
      }
      internal enum Flow {
        internal enum Explicit {
          /// Explicit PKCE
          internal static let title = L10n.tr("Localizable", "login.oauth.flow.explicit.title", fallback: "Explicit PKCE")
        }
        internal enum Implicit {
          /// Implicit JWT
          internal static let title = L10n.tr("Localizable", "login.oauth.flow.implicit.title", fallback: "Implicit JWT")
        }
      }
      internal enum FlowSelection {
        /// Login
        internal static let confirm = L10n.tr("Localizable", "login.oauth.flow_selection.confirm", fallback: "Login")
        /// Select the Google Sign-In flow to use for authentication
        internal static let message = L10n.tr("Localizable", "login.oauth.flow_selection.message", fallback: "Select the Google Sign-In flow to use for authentication")
        /// Sign in with Google
        internal static let title = L10n.tr("Localizable", "login.oauth.flow_selection.title", fallback: "Sign in with Google")
      }
    }
    internal enum Repeat {
      /// Repeat
      internal static let buttonTitle = L10n.tr("Localizable", "login.repeat.button_title", fallback: "Repeat")
    }
    internal enum UnavailableOauth {
      /// There are no authenticators available. Try it again later or contact the CXone Mobile team.
      internal static let message = L10n.tr("Localizable", "login.unavailable_oauth.message", fallback: "There are no authenticators available. Try it again later or contact the CXone Mobile team.")
    }
  }
  internal enum Payment {
    /// Card Holder Name
    internal static let cardHolderNameTitle = L10n.tr("Localizable", "payment.card_holder_name_title", fallback: "Card Holder Name")
    /// Card Number
    internal static let cardNumberTitle = L10n.tr("Localizable", "payment.card_number_title", fallback: "Card Number")
    /// CCV
    internal static let ccvTitle = L10n.tr("Localizable", "payment.ccv_title", fallback: "CCV")
    /// Pay Now
    internal static let confirmationButtonTitle = L10n.tr("Localizable", "payment.confirmation_button_title", fallback: "Pay Now")
    /// Payment
    internal static let title = L10n.tr("Localizable", "payment.title", fallback: "Payment")
    /// Total
    internal static let totalAmountTitle = L10n.tr("Localizable", "payment.total_amount_title", fallback: "Total")
    /// Valid Until
    internal static let validUntilTitle = L10n.tr("Localizable", "payment.valid_until_title", fallback: "Valid Until")
  }
  internal enum ProductDetail {
    /// Description
    internal static let description = L10n.tr("Localizable", "product_detail.description", fallback: "Description")
    internal enum AddToCart {
      /// Add to Cart
      internal static let title = L10n.tr("Localizable", "product_detail.add_to_cart.title", fallback: "Add to Cart")
    }
  }
  internal enum PurchaseDone {
    /// Back to Store
    internal static let backToStore = L10n.tr("Localizable", "purchase_done.back_to_store", fallback: "Back to Store")
    /// Your order has been paid.
    internal static let message = L10n.tr("Localizable", "purchase_done.message", fallback: "Your order has been paid.")
  }
  internal enum Settings {
    /// Settings
    internal static let title = L10n.tr("Localizable", "settings.title", fallback: "Settings")
    internal enum Build {
      /// Branch Name
      internal static let branchName = L10n.tr("Localizable", "settings.build.branch_name", fallback: "Branch Name")
      /// Tag
      internal static let branchTag = L10n.tr("Localizable", "settings.build.branch_tag", fallback: "Tag")
      /// Build Number
      internal static let buildNumber = L10n.tr("Localizable", "settings.build.build_number", fallback: "Build Number")
      /// Commit Hash
      internal static let commitHash = L10n.tr("Localizable", "settings.build.commit_hash", fallback: "Commit Hash")
      /// Build
      internal static let title = L10n.tr("Localizable", "settings.build.title", fallback: "Build")
    }
    internal enum Logs {
      /// Logs
      internal static let title = L10n.tr("Localizable", "settings.logs.title", fallback: "Logs")
      internal enum Open {
        /// Open
        internal static let button = L10n.tr("Localizable", "settings.logs.open.button", fallback: "Open")
        /// Open application logs
        internal static let label = L10n.tr("Localizable", "settings.logs.open.label", fallback: "Open application logs")
      }
      internal enum Remove {
        /// Remove
        internal static let button = L10n.tr("Localizable", "settings.logs.remove.button", fallback: "Remove")
        /// Remove logs
        internal static let label = L10n.tr("Localizable", "settings.logs.remove.label", fallback: "Remove logs")
        /// You are about to remove logs. Are you sure?
        internal static let message = L10n.tr("Localizable", "settings.logs.remove.message", fallback: "You are about to remove logs. Are you sure?")
      }
    }
    internal enum Module {
      /// Version
      internal static let version = L10n.tr("Localizable", "settings.module.version", fallback: "Version")
    }
    internal enum Sdk {
      /// Brand ID
      internal static let brandId = L10n.tr("Localizable", "settings.sdk.brand_id", fallback: "Brand ID")
      /// Channel ID
      internal static let channelId = L10n.tr("Localizable", "settings.sdk.channel_id", fallback: "Channel ID")
      /// Channel Name
      internal static let channelName = L10n.tr("Localizable", "settings.sdk.channel_name", fallback: "Channel Name")
      /// Customer
      internal static let currentCustomer = L10n.tr("Localizable", "settings.sdk.current_customer", fallback: "Customer")
      /// Environment
      internal static let environment = L10n.tr("Localizable", "settings.sdk.environment", fallback: "Environment")
      /// SDK
      internal static let title = L10n.tr("Localizable", "settings.sdk.title", fallback: "SDK")
    }
    internal enum Theme {
      /// This section allows you to customize the appearance of the chat conversation. If a text field is left blank, the default value for that color will be used.
      internal static let info = L10n.tr("Localizable", "settings.theme.info", fallback: "This section allows you to customize the appearance of the chat conversation. If a text field is left blank, the default value for that color will be used.")
      /// Theme
      internal static let title = L10n.tr("Localizable", "settings.theme.title", fallback: "Theme")
      internal enum Alert {
        internal enum ResetToDefault {
          /// Are you sure you want to reset all theme colors to their default values? This action cannot be undone.
          internal static let text = L10n.tr("Localizable", "settings.theme.alert.reset_to_default.text", fallback: "Are you sure you want to reset all theme colors to their default values? This action cannot be undone.")
          /// Reset to Defaults
          internal static let title = L10n.tr("Localizable", "settings.theme.alert.reset_to_default.title", fallback: "Reset to Defaults")
        }
      }
      internal enum Background {
        /// Background
        internal static let title = L10n.tr("Localizable", "settings.theme.background.title", fallback: "Background")
        internal enum Default {
          /// Background Default
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.background.default.placeholder", fallback: "Background Default")
        }
        internal enum Inverse {
          /// Background Inverse
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.background.inverse.placeholder", fallback: "Background Inverse")
        }
        internal enum Surface {
          /// Surface
          internal static let title = L10n.tr("Localizable", "settings.theme.background.surface.title", fallback: "Surface")
          internal enum Container {
            /// Background Surface Container
            internal static let placeholder = L10n.tr("Localizable", "settings.theme.background.surface.container.placeholder", fallback: "Background Surface Container")
          }
          internal enum Default {
            /// Background Surface Default
            internal static let placeholder = L10n.tr("Localizable", "settings.theme.background.surface.default.placeholder", fallback: "Background Surface Default")
          }
          internal enum Emphasis {
            /// Background Surface Emphasis
            internal static let placeholder = L10n.tr("Localizable", "settings.theme.background.surface.emphasis.placeholder", fallback: "Background Surface Emphasis")
          }
          internal enum Subtle {
            /// Background Surface Subtle
            internal static let placeholder = L10n.tr("Localizable", "settings.theme.background.surface.subtle.placeholder", fallback: "Background Surface Subtle")
          }
          internal enum Variant {
            /// Background Surface Variant
            internal static let placeholder = L10n.tr("Localizable", "settings.theme.background.surface.variant.placeholder", fallback: "Background Surface Variant")
          }
        }
      }
      internal enum Border {
        /// Border
        internal static let title = L10n.tr("Localizable", "settings.theme.border.title", fallback: "Border")
        internal enum Default {
          /// Border Default
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.border.default.placeholder", fallback: "Border Default")
        }
        internal enum Subtle {
          /// Border Subtle
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.border.subtle.placeholder", fallback: "Border Subtle")
        }
      }
      internal enum Brand {
        /// Brand
        internal static let title = L10n.tr("Localizable", "settings.theme.brand.title", fallback: "Brand")
        internal enum OnPrimary {
          /// Brand On Primary
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.brand.onPrimary.placeholder", fallback: "Brand On Primary")
        }
        internal enum OnPrimaryContainer {
          /// Brand On Primary Container
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.brand.onPrimaryContainer.placeholder", fallback: "Brand On Primary Container")
        }
        internal enum OnSecondary {
          /// Brand On Secondary
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.brand.onSecondary.placeholder", fallback: "Brand On Secondary")
        }
        internal enum OnSecondaryContainer {
          /// Brand On Secondary Container
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.brand.onSecondaryContainer.placeholder", fallback: "Brand On Secondary Container")
        }
        internal enum Primary {
          /// Brand Primary
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.brand.primary.placeholder", fallback: "Brand Primary")
        }
        internal enum PrimaryContainer {
          /// Brand Primary Container
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.brand.primaryContainer.placeholder", fallback: "Brand Primary Container")
        }
        internal enum Secondary {
          /// Brand Secondary
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.brand.secondary.placeholder", fallback: "Brand Secondary")
        }
        internal enum SecondaryContainer {
          /// Brand Secondary Container
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.brand.secondaryContainer.placeholder", fallback: "Brand Secondary Container")
        }
      }
      internal enum Content {
        /// Content
        internal static let title = L10n.tr("Localizable", "settings.theme.content.title", fallback: "Content")
        internal enum Inverse {
          /// Content Inverse
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.content.inverse.placeholder", fallback: "Content Inverse")
        }
        internal enum Primary {
          /// Content Primary
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.content.primary.placeholder", fallback: "Content Primary")
        }
        internal enum Secondary {
          /// Content Secondary
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.content.secondary.placeholder", fallback: "Content Secondary")
        }
        internal enum Tertiary {
          /// Content Tertiary
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.content.tertiary.placeholder", fallback: "Content Tertiary")
        }
      }
      internal enum NoColor {
        /// Color cannot be left blank. The UI will set the default color for the respective element(s).
        internal static let alertMessage = L10n.tr("Localizable", "settings.theme.no_color.alertMessage", fallback: "Color cannot be left blank. The UI will set the default color for the respective element(s).")
        /// Invalid color
        internal static let error = L10n.tr("Localizable", "settings.theme.no_color.error", fallback: "Invalid color")
        /// Enter Color
        internal static let placeholder = L10n.tr("Localizable", "settings.theme.no_color.placeholder", fallback: "Enter Color")
      }
      internal enum ResetToDefault {
        /// Reset
        internal static let title = L10n.tr("Localizable", "settings.theme.reset_to_default.title", fallback: "Reset")
      }
      internal enum Status {
        /// Status
        internal static let title = L10n.tr("Localizable", "settings.theme.status.title", fallback: "Status")
        internal enum Error {
          /// Status Error
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.status.error.placeholder", fallback: "Status Error")
        }
        internal enum ErrorContainer {
          /// Status Error Container
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.status.error_container.placeholder", fallback: "Status Error Container")
        }
        internal enum OnError {
          /// Status On Error
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.status.on_error.placeholder", fallback: "Status On Error")
        }
        internal enum OnErrorContainer {
          /// Status On Error Container
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.status.on_error_container.placeholder", fallback: "Status On Error Container")
        }
        internal enum OnSuccess {
          /// Status On Success
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.status.on_success.placeholder", fallback: "Status On Success")
        }
        internal enum OnSuccessContainer {
          /// Status On Success Container
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.status.on_success_container.placeholder", fallback: "Status On Success Container")
        }
        internal enum OnWarning {
          /// Status On Warning
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.status.on_warning.placeholder", fallback: "Status On Warning")
        }
        internal enum OnWarningContainer {
          /// Status On Warning Container
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.status.on_warning_container.placeholder", fallback: "Status On Warning Container")
        }
        internal enum Success {
          /// Status Success
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.status.success.placeholder", fallback: "Status Success")
        }
        internal enum SuccessContainer {
          /// Status Success Container
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.status.success_container.placeholder", fallback: "Status Success Container")
        }
        internal enum Warning {
          /// Status Warning
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.status.warning.placeholder", fallback: "Status Warning")
        }
        internal enum WarningContainer {
          /// Status Warning Container
          internal static let placeholder = L10n.tr("Localizable", "settings.theme.status.warning_container.placeholder", fallback: "Status Warning Container")
        }
      }
    }
    internal enum Ui {
      /// UI
      internal static let title = L10n.tr("Localizable", "settings.ui.title", fallback: "UI")
      internal enum ChatAdditionalContactCustomFields {
        /// Additional Contact Fields
        internal static let title = L10n.tr("Localizable", "settings.ui.chat_additional_contact_custom_fields.title", fallback: "Additional Contact Fields")
      }
      internal enum ChatAdditionalCustomFields {
        /// key
        internal static let keyLabel = L10n.tr("Localizable", "settings.ui.chat_additional_custom_fields.key_label", fallback: "key")
        /// Insert key
        internal static let keyPlaceholder = L10n.tr("Localizable", "settings.ui.chat_additional_custom_fields.key_placeholder", fallback: "Insert key")
        /// Delete
        internal static let rowDelete = L10n.tr("Localizable", "settings.ui.chat_additional_custom_fields.row_delete", fallback: "Delete")
        /// value
        internal static let valueLabel = L10n.tr("Localizable", "settings.ui.chat_additional_custom_fields.value_label", fallback: "value")
        /// Insert value
        internal static let valuePlaceholder = L10n.tr("Localizable", "settings.ui.chat_additional_custom_fields.value_placeholder", fallback: "Insert value")
      }
      internal enum ChatAdditionalCustomerCustomFields {
        /// Additional Customer Fields
        internal static let title = L10n.tr("Localizable", "settings.ui.chat_additional_customer_custom_fields.title", fallback: "Additional Customer Fields")
      }
      internal enum ChatPresentationStyle {
        /// Full-screen
        internal static let optionFullscreen = L10n.tr("Localizable", "settings.ui.chat_presentation_style.option_fullscreen", fallback: "Full-screen")
        /// Modal
        internal static let optionModal = L10n.tr("Localizable", "settings.ui.chat_presentation_style.option_modal", fallback: "Modal")
        /// Chat Presentation Style
        internal static let title = L10n.tr("Localizable", "settings.ui.chat_presentation_style.title", fallback: "Chat Presentation Style")
      }
    }
  }
  internal enum Store {
    /// NICE Store
    internal static let title = L10n.tr("Localizable", "store.title", fallback: "NICE Store")
    internal enum Signout {
      /// You are about to sign out from selected channel. Do you want to proceed?
      internal static let message = L10n.tr("Localizable", "store.signout.message", fallback: "You are about to sign out from selected channel. Do you want to proceed?")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
