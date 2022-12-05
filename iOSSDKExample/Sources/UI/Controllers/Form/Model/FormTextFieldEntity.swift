import CXoneChatSDK
import Foundation


struct FormTextFieldEntity {
    let type: TextFieldType
    let placeholder: String
    let customField: (key: String, value: String)
}
