import SwiftUI
import SwiftData

struct PropertyListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = PropertyListViewModel()
    @State private var showingAddForm = false

    var body: some View {
        Group {
            if viewModel.filteredProperties.isEmpty {
                EmptyStateView(icon: "building.2", title: "No Properties", subtitle: "Add your first property to get started")
            } else {
                List {
                    ForEach(viewModel.filteredProperties) { property in
                        NavigationLink(destination: PropertyDetailView(property: property)) {
                            propertyRow(property)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteProperty(viewModel.filteredProperties[index], modelContext: modelContext)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search properties")
        .navigationTitle("Properties")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddForm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddForm) {
            PropertyFormView()
        }
        .onAppear { viewModel.loadProperties(modelContext: modelContext) }
        .onChange(of: viewModel.searchText) { _, _ in }
    }

    private func propertyRow(_ property: Property) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(property.name)
                    .font(.headline)
                Spacer()
                StatusBadge(text: property.propertyType.rawValue, color: .primaryBlue)
            }
            Text(property.fullAddress)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 16) {
                Label("\(property.units) units", systemImage: "door.left.hand.open")
                Label(property.monthlyRent.currencyString, systemImage: "dollarsign.circle")
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
