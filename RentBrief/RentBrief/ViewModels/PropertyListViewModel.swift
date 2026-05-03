import SwiftUI
import SwiftData

@MainActor
@Observable
final class PropertyListViewModel {
    var properties: [Property] = []
    var searchText: String = ""

    var filteredProperties: [Property] {
        if searchText.isEmpty { return properties }
        return properties.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText) ||
            $0.city.localizedCaseInsensitiveContains(searchText)
        }
    }

    func loadProperties(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Property>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        properties = (try? modelContext.fetch(descriptor)) ?? []
    }

    func deleteProperty(_ property: Property, modelContext: ModelContext) {
        modelContext.delete(property)
        try? modelContext.save()
        loadProperties(modelContext: modelContext)
    }
}
