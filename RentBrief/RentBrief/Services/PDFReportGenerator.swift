import PDFKit
import UIKit

final class PDFReportGenerator {

    func generate(report: MonthlyReport, template: ReportTemplate, brandConfig: BrandConfig) throws -> URL {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let contentWidth = pageWidth - margin * 2

        let pdfMetaData = [
            kCGPDFContextTitle: "Property Report - \(report.property.name)",
            kCGPDFContextCreator: "RentBrief",
            kCGPDFContextSubject: "\(report.period.start.monthYearString) Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            var y: CGFloat = margin

            y = drawHeader(y: y, margin: margin, contentWidth: contentWidth, report: report, brandConfig: brandConfig)
            y = drawKPISummary(y: y + 20, margin: margin, contentWidth: contentWidth, report: report)
            y = drawIncomeSection(y: y + 20, margin: margin, contentWidth: contentWidth, report: report)

            if template == .detailed || template == .detailedMaintenance || template == .fullPackage {
                y = drawExpenseBreakdown(y: y + 20, margin: margin, contentWidth: contentWidth, report: report)
            }

            if y > pageHeight - 150 {
                context.beginPage()
                y = margin
            }

            if template == .detailedMaintenance || template == .fullPackage {
                y = drawMaintenanceSection(y: y + 20, margin: margin, contentWidth: contentWidth, report: report)
            }

            if template == .fullPackage {
                if y > pageHeight - 200 {
                    context.beginPage()
                    y = margin
                }
                y = drawTenantSummary(y: y + 20, margin: margin, contentWidth: contentWidth, report: report)
            }

            if brandConfig.includeFooter {
                drawFooter(pageWidth: pageWidth, pageHeight: pageHeight, brandConfig: brandConfig)
            }
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "RentBrief_\(report.property.name.replacingOccurrences(of: " ", with: "_"))_\(report.period.start.monthYearString.replacingOccurrences(of: " ", with: "_")).pdf"
        let url = tempDir.appendingPathComponent(fileName)
        try data.write(to: url)
        return url
    }

    private func drawHeader(y: CGFloat, margin: CGFloat, contentWidth: CGFloat, report: MonthlyReport, brandConfig: BrandConfig) -> CGFloat {
        var currentY = y

        if !brandConfig.companyName.isEmpty {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor(red: 0.161, green: 0.475, blue: 1.0, alpha: 1.0)
            ]
            brandConfig.companyName.draw(at: CGPoint(x: margin, y: currentY), withAttributes: attrs)
            currentY += 24
        }

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        "Property Report".draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttrs)
        currentY += 32

        let subtitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.darkGray
        ]
        "\(report.property.name) - \(report.period.start.monthYearString)".draw(at: CGPoint(x: margin, y: currentY), withAttributes: subtitleAttrs)
        currentY += 20
        report.property.fullAddress.draw(at: CGPoint(x: margin, y: currentY), withAttributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.gray])
        currentY += 20

        let path = UIBezierPath()
        path.move(to: CGPoint(x: margin, y: currentY))
        path.addLine(to: CGPoint(x: margin + contentWidth, y: currentY))
        path.lineWidth = 1.0
        UIColor.lightGray.setStroke()
        path.stroke()
        currentY += 10

        return currentY
    }

    private func drawKPISummary(y: CGFloat, margin: CGFloat, contentWidth: CGFloat, report: MonthlyReport) -> CGFloat {
        var currentY = y

        let sectionAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        "Key Performance Indicators".draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttrs)
        currentY += 24

        let kpiWidth = contentWidth / 2 - 10
        let kpis: [(String, String, UIColor)] = [
            ("Total Income", report.totalIncome.currencyString, UIColor(red: 0.0, green: 0.784, blue: 0.325, alpha: 1.0)),
            ("Total Expenses", report.totalExpenses.currencyString, UIColor(red: 1.0, green: 0.09, blue: 0.267, alpha: 1.0)),
            ("Net Income", report.netIncome.currencyString, UIColor(red: 0.161, green: 0.475, blue: 1.0, alpha: 1.0)),
            ("Occupancy", report.occupancyRate.percentString, UIColor(red: 1.0, green: 0.569, blue: 0.0, alpha: 1.0))
        ]

        for (index, kpi) in kpis.enumerated() {
            let col = index % 2
            let row = index / 2
            let x = margin + CGFloat(col) * (kpiWidth + 20)
            let kpiY = currentY + CGFloat(row) * 55

            let rect = CGRect(x: x, y: kpiY, width: kpiWidth, height: 45)
            let bgPath = UIBezierPath(roundedRect: rect, cornerRadius: 8)
            UIColor(red: 0.961, green: 0.969, blue: 0.98, alpha: 1.0).setFill()
            bgPath.fill()

            let labelAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: UIColor.gray]
            kpi.0.draw(at: CGPoint(x: x + 10, y: kpiY + 6), withAttributes: labelAttrs)

            let valueAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold), .foregroundColor: kpi.2]
            kpi.1.draw(at: CGPoint(x: x + 10, y: kpiY + 22), withAttributes: valueAttrs)
        }

        currentY += 120
        return currentY
    }

    private func drawIncomeSection(y: CGFloat, margin: CGFloat, contentWidth: CGFloat, report: MonthlyReport) -> CGFloat {
        var currentY = y

        let sectionAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16, weight: .semibold), .foregroundColor: UIColor.black]
        "Income Summary".draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttrs)
        currentY += 24

        let headerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: UIColor.gray]
        let valueAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.black]

        "Category".draw(at: CGPoint(x: margin, y: currentY), withAttributes: headerAttrs)
        "Amount".draw(at: CGPoint(x: margin + contentWidth - 100, y: currentY), withAttributes: headerAttrs)
        currentY += 18

        for income in report.income {
            income.category.rawValue.draw(at: CGPoint(x: margin, y: currentY), withAttributes: valueAttrs)
            income.amount.currencyString.draw(at: CGPoint(x: margin + contentWidth - 100, y: currentY), withAttributes: valueAttrs)
            currentY += 16
        }

        let totalAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13, weight: .bold), .foregroundColor: UIColor(red: 0.0, green: 0.784, blue: 0.325, alpha: 1.0)]
        "Total Income".draw(at: CGPoint(x: margin, y: currentY + 4), withAttributes: totalAttrs)
        report.totalIncome.currencyString.draw(at: CGPoint(x: margin + contentWidth - 100, y: currentY + 4), withAttributes: totalAttrs)
        currentY += 24

        return currentY
    }

    private func drawExpenseBreakdown(y: CGFloat, margin: CGFloat, contentWidth: CGFloat, report: MonthlyReport) -> CGFloat {
        var currentY = y

        let sectionAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16, weight: .semibold), .foregroundColor: UIColor.black]
        "Expense Breakdown".draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttrs)
        currentY += 24

        let headerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: UIColor.gray]
        let valueAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.black]

        "Category".draw(at: CGPoint(x: margin, y: currentY), withAttributes: headerAttrs)
        "Amount".draw(at: CGPoint(x: margin + contentWidth - 100, y: currentY), withAttributes: headerAttrs)
        currentY += 18

        for (category, amount) in report.expensesByCategory.sorted(by: { $0.value > $1.value }) {
            category.rawValue.draw(at: CGPoint(x: margin, y: currentY), withAttributes: valueAttrs)
            amount.currencyString.draw(at: CGPoint(x: margin + contentWidth - 100, y: currentY), withAttributes: valueAttrs)
            currentY += 16
        }

        let totalAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13, weight: .bold), .foregroundColor: UIColor(red: 1.0, green: 0.09, blue: 0.267, alpha: 1.0)]
        "Total Expenses".draw(at: CGPoint(x: margin, y: currentY + 4), withAttributes: totalAttrs)
        report.totalExpenses.currencyString.draw(at: CGPoint(x: margin + contentWidth - 100, y: currentY + 4), withAttributes: totalAttrs)
        currentY += 24

        return currentY
    }

    private func drawMaintenanceSection(y: CGFloat, margin: CGFloat, contentWidth: CGFloat, report: MonthlyReport) -> CGFloat {
        var currentY = y

        let sectionAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16, weight: .semibold), .foregroundColor: UIColor.black]
        "Maintenance Orders".draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttrs)
        currentY += 24

        if report.maintenanceOrders.isEmpty {
            let emptyAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.gray]
            "No maintenance orders this period".draw(at: CGPoint(x: margin, y: currentY), withAttributes: emptyAttrs)
            currentY += 20
        } else {
            for order in report.maintenanceOrders {
                let titleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13, weight: .medium), .foregroundColor: UIColor.black]
                order.title.draw(at: CGPoint(x: margin, y: currentY), withAttributes: titleAttrs)
                currentY += 16

                let detailAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.gray]
                "\(order.status.rawValue) • \(order.cost.currencyString)".draw(at: CGPoint(x: margin + 10, y: currentY), withAttributes: detailAttrs)
                currentY += 18
            }
        }

        return currentY
    }

    private func drawTenantSummary(y: CGFloat, margin: CGFloat, contentWidth: CGFloat, report: MonthlyReport) -> CGFloat {
        var currentY = y

        let sectionAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16, weight: .semibold), .foregroundColor: UIColor.black]
        "Tenant Summary".draw(at: CGPoint(x: margin, y: currentY), withAttributes: sectionAttrs)
        currentY += 24

        let headerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: UIColor.gray]
        "Tenant".draw(at: CGPoint(x: margin, y: currentY), withAttributes: headerAttrs)
        "Status".draw(at: CGPoint(x: margin + contentWidth - 100, y: currentY), withAttributes: headerAttrs)
        currentY += 18

        let valueAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.black]
        for tenant in report.tenants {
            tenant.name.draw(at: CGPoint(x: margin, y: currentY), withAttributes: valueAttrs)
            tenant.paymentStatus.rawValue.draw(at: CGPoint(x: margin + contentWidth - 100, y: currentY), withAttributes: valueAttrs)
            currentY += 16
        }

        return currentY
    }

    private func drawFooter(pageWidth: CGFloat, pageHeight: CGFloat, brandConfig: BrandConfig) {
        let footerY = pageHeight - 30
        let footerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9), .foregroundColor: UIColor.gray]

        let footerText = brandConfig.footerText.isEmpty ? "Generated by RentBrief" : brandConfig.footerText
        footerText.draw(at: CGPoint(x: 50, y: footerY), withAttributes: footerAttrs)

        let dateText = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        dateText.draw(at: CGPoint(x: pageWidth - 200, y: footerY), withAttributes: footerAttrs)
    }
}
