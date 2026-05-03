# RentBrief - iOS Development Guide

## Executive Summary

RentBrief is a mobile-first property management reporting app designed for small property management companies and self-managing landlords in the US market. It transforms the painful 12+ hour monthly owner reporting process into a 5-minute workflow with professional PDF reports, customizable templates, and real-time dashboards.

**Target Audience**: Small PM companies (1-10 people, 10-50 units) and self-managing landlords (3-20 properties)

**Key Differentiators**:
- 97% cheaper than AppFolio ($9.99/mo vs $298+/mo)
- Native iOS experience vs web-wrapped competitors
- 4 customizable report templates vs fixed-format competitors
- Offline-first architecture with all data stored locally
- Brand customization for small PMs who cannot customize in enterprise tools

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| AppFolio | Full PM suite, AI automation, owner portal | $298+/mo, 50 unit minimum, limited report customization, enterprise-focused | 97% cheaper, no minimums, customizable reports, mobile-native |
| Buildium | Owner dashboard, rent collection, work orders | $50-249/mo, limited mobile reporting, web-first design, no brand customization | Mobile-first, brand customization, offline capable, simpler pricing |
| Landlord Studio | Free tier, receipt scanning, Schedule E reports | Basic reporting, no portfolio view, limited templates, no brand customization | 4 report templates, portfolio view, brand customization, professional PDFs |
| Proply | AI bookkeeping, tax reporting, expense tracking | iPhone only, no owner reports, no maintenance tracking, no PDF generation | Full owner reports, maintenance tracking, iPad support, PDF generation |
| Landlordy | PDF reports, CSV export, widget support | Basic UI, no dashboard charts, no brand customization, limited templates | Swift Charts dashboard, brand customization, modern SwiftUI, 4 templates |

## Apple Design Guidelines Compliance

- **HIG Layout**: Adaptive layouts for iPhone and iPad using SwiftUI size classes
- **Navigation**: Tab-based navigation following iOS patterns (Dashboard, Properties, Records, Reports)
- **Typography**: SF Pro system fonts with Dynamic Type support
- **Colors**: Semantic colors with automatic dark mode support
- **Haptics**: UIImpactFeedbackGenerator for key interactions
- **Accessibility**: VoiceOver labels on all interactive elements, minimum 44pt touch targets
- **Privacy**: All data stored locally on device, no server data collection
- **App Store Review**: Financial data app - ensure no misleading claims, clear subscription terms

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), UIKit (PDF generation via Core Graphics)
- **Data**: SwiftData (iOS 17+) for local persistence
- **Charts**: Swift Charts framework for dashboard visualizations
- **PDF**: Core Graphics + PDFKit for report generation and preview
- **Networking**: URLSession for feedback submission only
- **Image**: PhotosUI for maintenance photo capture
- **IAP**: StoreKit 2 for subscription management
- **Sharing**: ShareLink for PDF/CSV export
- **Widgets**: WidgetKit for home screen KPI cards

## Module Structure

```
RentBrief/
├── RentBriefApp.swift
├── Models/
│   ├── Property.swift
│   ├── Transaction.swift
│   ├── MaintenanceOrder.swift
│   ├── Tenant.swift
│   ├── Enums.swift
│   └── MonthlyReport.swift
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── KPICardView.swift
│   │   └── MonthPickerView.swift
│   ├── Properties/
│   │   ├── PropertyListView.swift
│   │   ├── PropertyDetailView.swift
│   │   └── PropertyFormView.swift
│   ├── Records/
│   │   ├── TransactionListView.swift
│   │   ├── TransactionFormView.swift
│   │   ├── MaintenanceListView.swift
│   │   └── MaintenanceFormView.swift
│   ├── Reports/
│   │   ├── ReportGeneratorView.swift
│   │   ├── ReportPreviewView.swift
│   │   └── TemplatePickerView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── BrandingConfigView.swift
│   │   ├── PaywallView.swift
│   │   └── ContactSupportView.swift
│   └── Components/
│       ├── StatusBadge.swift
│       ├── CurrencyTextField.swift
│       └── EmptyStateView.swift
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── PropertyListViewModel.swift
│   ├── TransactionListViewModel.swift
│   ├── ReportGeneratorViewModel.swift
│   └── PurchaseManager.swift
├── Services/
│   ├── ReportGenerator.swift
│   ├── PDFReportGenerator.swift
│   ├── CSVExporter.swift
│   └── FeedbackService.swift
└── Extensions/
    ├── Color+Theme.swift
    ├── Date+Extensions.swift
    └── Double+Currency.swift
```

## Implementation Flow

1. Set up SwiftData models (Property, Transaction, MaintenanceOrder, Tenant, Enums)
2. Create theme extensions (Color+Theme, Date+Extensions, Double+Currency)
3. Build main TabView navigation with 4 tabs
4. Implement Dashboard with KPI cards and Swift Charts
5. Build Property CRUD (list, detail, form views)
6. Build Transaction CRUD with category management
7. Build Maintenance Order CRUD with photo capture
8. Implement Tenant management within Property detail
9. Build Report Generator with template selection
10. Implement PDF generation with Core Graphics
11. Build Report Preview with PDFKit
12. Implement CSV export functionality
13. Build Settings with brand customization
14. Implement StoreKit 2 subscription (PurchaseManager + Paywall)
15. Add Contact Support with backend integration
16. Generate policy pages (support, privacy, terms)
17. Test on iPhone and iPad simulators
18. Push to GitHub and deploy policy pages

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary Blue: #2979FF (trust, professional, finance)
  - Dark Blue: #1565C0 (emphasis, buttons)
  - Light Blue: #E3F2FD (backgrounds, cards)
  - Green: #00C853 (income, positive metrics)
  - Red: #FF1744 (expenses, warnings)
  - Orange: #FF9100 (pending, reminders)
  - Gray: #78909C (secondary text)
  - Background Light: #F5F7FA
  - Background Dark: #121212
  - Card Light: #FFFFFF
  - Card Dark: #1E1E1E

- **Typography**:
  - Large Title: SF Pro Display 28pt Bold
  - Page Title: SF Pro Display 22pt Semibold
  - Section Title: SF Pro Display 17pt Semibold
  - Body: SF Pro Text 15pt Regular
  - Caption: SF Pro Text 13pt Regular
  - KPI Numbers: SF Mono 24-32pt Bold
  - Labels: SF Pro Text 11pt Medium

- **Layout**:
  - Bottom Tab navigation with 4 tabs: Dashboard, Properties, Records, Reports
  - KPI cards in 2-column grid on Dashboard
  - ScrollView content max width 720pt on iPad
  - Card-based list items with 12pt corner radius
  - 16pt horizontal padding, 12pt vertical spacing

- **Animations**:
  - Page transitions: iOS native slide (0.35s)
  - KPI number changes: content transition animation (0.5s)
  - Chart loading: bottom-to-top growth (0.6s)
  - Report generation: progress indicator (1-3s)
  - Card tap: slight scale + shadow (0.2s)
  - Delete: slide + fade out (0.3s)

## Code Generation Rules

- Architecture: MVVM + SwiftData, Views contain no business logic
- Data flow: View -> ViewModel -> Model -> SwiftData
- Async: async/await + @MainActor
- Error handling: Result type with localized error descriptions
- Localization: String(localized:) for all user-visible strings
- Privacy: All data stored locally, no cloud sync by default
- Accessibility: VoiceOver support, Dynamic Type
- Minimum version: iOS 17.0 (SwiftData stable)
- Naming: UpperCamelCase for types, lowerCamelCase for functions/variables
- File organization: Group by feature (Models/Views/ViewModels/Services)
- No comments in code unless asked
- All SwiftData attributes must be optional or have default values
- All SwiftData relationships must have inverse relationships
- iPad: Never use .tabViewStyle(.sidebarAdaptable), always add .frame(maxWidth: 720).frame(maxWidth: .infinity) for main ScrollView content

## Build & Deployment Checklist

- [ ] Bundle ID: com.zzoutuo.RentBrief
- [ ] Deployment Target: iOS 17.0
- [ ] App Icon generated and configured
- [ ] SwiftData models compile without errors
- [ ] StoreKit 2 subscription configured
- [ ] PDF generation works on iPhone and iPad
- [ ] Policy pages deployed to GitHub Pages
- [ ] Tested on iPhone XS Max simulator
- [ ] Tested on iPad Pro 13-inch (M4) simulator
- [ ] No API keys or secrets in source code
- [ ] App Store metadata prepared (keytext.md)
