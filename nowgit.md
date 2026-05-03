# Git Repositories

## Main App (iOS Application + Policy Pages)

| Item | Value |
|------|-------|
| **Repository Name** | RentBrief |
| **Git URL** | git@github.com:asunnyboy861/RentBrief.git |
| **Repo URL** | https://github.com/asunnyboy861/RentBrief |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | Enabled (from /docs folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/RentBrief/ | Active |
| Support | https://asunnyboy861.github.io/RentBrief/support.html | Active |
| Privacy Policy | https://asunnyboy861.github.io/RentBrief/privacy.html | Active |
| Terms of Use | https://asunnyboy861.github.io/RentBrief/terms.html | Active |

Note: Terms of Use required for IAP subscription apps.

## Repository Structure

```
RentBrief/
├── RentBrief/                           # iOS App Source Code
│   ├── RentBrief.xcodeproj/            # Xcode Project
│   ├── RentBrief/                      # Swift Source Files
│   │   ├── Views/
│   │   ├── Models/
│   │   ├── ViewModels/
│   │   ├── Services/
│   │   ├── Extensions/
│   │   └── Components/
├── docs/                               # Policy Pages for GitHub Pages
│   ├── index.html                      # Landing Page
│   ├── support.html                    # Support Page
│   ├── privacy.html                    # Privacy Policy
│   └── terms.html                      # Terms of Use
├── .github/workflows/
│   └── deploy.yml                      # GitHub Pages deployment
├── us.md                               # English Development Guide
├── keytext.md                          # App Store Metadata
├── capabilities.md                     # Capabilities Configuration
├── icon.md                             # App Icon Details
├── price.md                            # Pricing Configuration
└── nowgit.md                           # This File
```
