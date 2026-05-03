import SwiftUI

struct MonthPickerView: View {
    @Binding var selectedMonth: Date

    var body: some View {
        HStack {
            Button {
                withAnimation { selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth }
            } label: {
                Image(systemName: "chevron.left")
            }

            Text(selectedMonth.monthYearString)
                .font(.headline)
                .frame(minWidth: 140)

            Button {
                withAnimation { selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.primary)
    }
}
