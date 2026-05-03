import Foundation

struct CSVExporter {
    static func exportTransactions(_ transactions: [Transaction]) -> URL? {
        var csv = "Date,Property,Category,Type,Description,Vendor,Amount\n"

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for t in transactions {
            let date = formatter.string(from: t.date)
            let property = t.property?.name ?? "N/A"
            let category = t.category.rawValue
            let type = t.transactionType.rawValue
            let desc = t.note.replacingOccurrences(of: ",", with: ";")
            let vendor = t.vendorName.replacingOccurrences(of: ",", with: ";")
            let amount = String(format: "%.2f", t.amount)
            csv += "\(date),\(property),\(category),\(type),\(desc),\(vendor),\(amount)\n"
        }

        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent("RentBrief_Transactions_\(formatter.string(from: Date())).csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}
