import SwiftUI
import SwiftData

struct PropertyFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var propertyType: PropertyType = .residential
    @State private var units: Int = 1
    @State private var monthlyRent: Double = 0
    @State private var managementFeePercent: Double = 10
    @State private var ownerName = ""
    @State private var ownerEmail = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Property Info") {
                    TextField("Property Name", text: $name)
                    TextField("Address", text: $address)
                    HStack {
                        TextField("City", text: $city)
                        TextField("State", text: $state)
                            .frame(width: 60)
                        TextField("ZIP", text: $zipCode)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                    }
                    Picker("Type", selection: $propertyType) {
                        ForEach(PropertyType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    Stepper("Units: \(units)", value: $units, in: 1...100)
                }

                Section("Financial") {
                    CurrencyTextField(value: $monthlyRent, label: "Monthly Rent")
                    Stepper("Mgmt Fee: \(managementFeePercent, specifier: "%.0f")%", value: $managementFeePercent, in: 0...50, step: 0.5)
                }

                Section("Owner") {
                    TextField("Owner Name", text: $ownerName)
                    TextField("Owner Email", text: $ownerEmail)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                }
            }
            .navigationTitle("New Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveProperty() }
                        .disabled(name.isEmpty || address.isEmpty)
                }
            }
        }
    }

    private func saveProperty() {
        let property = Property(name: name, address: address, city: city, state: state, zipCode: zipCode, propertyType: propertyType)
        property.units = units
        property.monthlyRent = monthlyRent
        property.managementFeePercent = managementFeePercent
        property.ownerName = ownerName
        property.ownerEmail = ownerEmail
        modelContext.insert(property)
        try? modelContext.save()
        dismiss()
    }
}
