import SwiftUI
import SwiftData
import PhotosUI

struct MaintenanceFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var property: Property?

    @State private var title = ""
    @State private var detail = ""
    @State private var status: MaintenanceStatus = .open
    @State private var cost: Double = 0
    @State private var vendorName = ""
    @State private var selectedProperty: Property?
    @State private var selectedBeforePhoto: PhotosPickerItem?
    @State private var beforePhotoData: Data?

    @Query private var properties: [Property]

    init(property: Property? = nil) {
        self.property = property
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Work Order") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $detail, axis: .vertical)
                        .lineLimit(3...6)
                    Picker("Status", selection: $status) {
                        ForEach(MaintenanceStatus.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                }

                Section("Cost") {
                    CurrencyTextField(value: $cost, label: "Repair Cost")
                    TextField("Vendor Name", text: $vendorName)
                }

                Section("Property") {
                    if let property {
                        Text(property.name)
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Property", selection: $selectedProperty) {
                            Text("Select Property").tag(nil as Property?)
                            ForEach(properties) { prop in
                                Text(prop.name).tag(prop as Property?)
                            }
                        }
                    }
                }

                Section("Photos") {
                    PhotosPicker(selection: $selectedBeforePhoto, matching: .images) {
                        Label("Add Before Photo", systemImage: "camera")
                    }
                    if beforePhotoData != nil {
                        Label("Photo attached", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(Color.incomeGreen)
                    }
                }
            }
            .navigationTitle("New Work Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveOrder() }
                        .disabled(title.isEmpty)
                }
            }
            .onChange(of: selectedBeforePhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        beforePhotoData = data
                    }
                }
            }
        }
    }

    private func saveOrder() {
        let order = MaintenanceOrder(title: title, detail: detail, cost: cost, vendorName: vendorName)
        order.status = status
        order.property = selectedProperty ?? property
        order.beforePhotoData = beforePhotoData
        modelContext.insert(order)
        try? modelContext.save()
        dismiss()
    }
}
