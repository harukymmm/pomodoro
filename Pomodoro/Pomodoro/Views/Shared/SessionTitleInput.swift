import SwiftUI

struct SessionTitleInput: View {
    @Binding var title: String
    let isEditable: Bool

    var body: some View {
        TextField("作業タイトル", text: $title)
            .textFieldStyle(.roundedBorder)
            .disabled(!isEditable)
            #if os(iOS)
            .textInputAutocapitalization(.never)
            #endif
    }
}
