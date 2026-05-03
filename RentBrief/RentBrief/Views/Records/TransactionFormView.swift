import SwiftUI
import SwiftData

struct TransactionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var property: Property?

    @State private var amount: Double = 0
    @State private var category: TransactionCategory = .rentIncome
    @State private var transactionType: TransactionType = .income
    @State private var note = ""
    @State private var vendorName = ""
    @State private var date = Date()
    @State private var selectedProperty: Property?

    @Query private var properties: [Property]

    init(property: Property? = nil) {
        self.property = property
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Type") {
                    Picker("Type", selection: $transactionType) {
                        Text("Income").tag(TransactionType.income)
                        Text("Expense").tag(TransactionType.expense)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: transactionType) { _, newValue in
                        if newValue == .income {
                            category = .rentIncome
                        } else {
                            category = .maintenance
                        }
                    }
                }

                Section("Details") {
                    CurrencyTextField(value: $amount, label: "Amount")
                    Picker("Category", selection: $category) {
                        let filtered = TransactionCategory.allCases.filter { $0.isIncome == (transactionType == .income) }
                        ForEach(filtered, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    TextField("Description", text: $note)
                    if transactionType == .expense {
                        TextField("Vendor Name", text: $vendorName)
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
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
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTransaction() }
                        .disabled(amount <= 0 || note.isEmpty)
                }
            }
        }
    }

    private func saveTransaction() {
        let transaction = Transaction(amount: amount, category: category, transactionType: transactionType, note: note, vendorName: vendorName, date: date)
        transaction.property = selectedProperty ?? property
        modelContext.insert(transaction)
        try? modelContext.save()
        dismiss()
    }
}
