# iOS News App (SwiftUI + MVVM + Clean Architecture)

A production-style iOS News app built with **SwiftUI**, **MVVM**, and a lightweight **Clean Architecture** split, featuring **multiple remote news providers**, **async/await networking**, **provider-agnostic pagination**, **disk-backed caching**, provider-aware **region/language selection**, and clean **UI state management**.

Built as a portfolio project to demonstrate scalable architecture, resilient data handling, and a setup where **new providers can be added or removed without rewriting the presentation layer**.

**Data source credit:**
- [NewsAPI.org](https://newsapi.org/)
- [NewsData.io](https://newsdata.io/)
- [GNews](https://gnews.io/)

---

## Portfolio Summary

This project demonstrates:

- Designing a **scalable MVVM + Clean Architecture** structure with a clear split between `App`, `Presentation`, `Domain`, `Data`, and `Core`
- Building a **multi-source news platform** where providers can be swapped with minimal impact on the UI layer
- Normalizing different API contracts behind **provider-agnostic domain models** such as `HeadlinesQuery`, `HeadlinesPage`, and `HeadlinesRepository`
- Handling **pagination, caching, and persistence** in a reusable way rather than baking source-specific logic into screens
- Supporting **provider-aware runtime preferences** for NewsData and GNews country/language selection with cache invalidation and feed refresh
- Mapping infrastructure failures into **domain-safe errors** before they reach the presentation layer
- Using **lightweight dependency composition** with `AppDI`, `AppRouter`, and provider factories instead of heavy container frameworks

---

## Features

- **Top Headlines** feed with pull-to-refresh and infinite scrolling
- **Explore** with category filters and search
- **Article detail** in a WebKit-powered view
- **Bookmarks** with persistent storage
- **Recently viewed (MRU)** history with max-item trimming
- **Cached headlines fallback** when first-page fetch fails
- **Settings** actions to clear cache, bookmarks, and history
- **Provider-aware region & language selection**
- **Searchable selection list** for NewsData country and language changes
- **Automatic cache clear + feed refresh** when NewsData country/language changes
- **Switchable provider architecture** supporting:
  - `NewsAPI`
  - `NewsData`
  - `GNews`

---

## Skills Demonstrated

- Architecting a SwiftUI app with a clean **tab-based shell**, reusable scenes, and screen-focused ViewModels
- Applying **MVVM** in a practical way with thin Views, explicit UI state, and async view-model driven flows
- Designing a lightweight **Clean Architecture** setup that keeps Domain contracts stable while Data handles provider-specific work
- Building **provider abstraction layers** so NewsAPI, NewsData, and GNews can plug into the same app-facing repository flow
- Implementing **async/await networking**, normalized pagination, duplicate filtering, and resilient fetch behavior
- Creating **JSON-backed persistence** for cache, bookmarks, and recent history with shared disk storage utilities
- Handling **runtime configuration and provider-specific preferences** without rewriting the feed screens
- Mapping low-level failures into **domain errors** and then into UI-safe presentation messages
- Adding structured logging with environment-aware logger selection for easier debugging and future production monitoring
- Maintaining consistent **loading, empty, error, detail, and settings flows** across the app

---

## Architecture Overview

This project uses a **lightweight** interpretation of Clean Architecture:

- protocols are used where they protect a boundary or make composition easier
- concrete types are used where more abstraction would only add noise

### Layer Responsibilities

#### App

Responsible for:

- app bootstrap
- dependency composition
- root navigation
- provider selection
- runtime configuration

Key files:

- `App/NewsApp_SwiftUI.swift`
- `App/AppRouter.swift`
- `App/AppDI.swift`
- `App/AppConfiguration.swift`
- `App/HeadlinesDataSourceFactory.swift`
- `App/NewsProviderID.swift`
- `App/ExploreCategoriesProvider.swift`

#### Presentation

Responsible for:

- SwiftUI rendering
- screen state
- user interaction handling
- view-specific formatting and UI helpers

Key folders:

- `Presentation/Home/`
- `Presentation/Explore/`
- `Presentation/Bookmarks/`
- `Presentation/Settings/`
- `Presentation/NewsDetail/`
- `Presentation/Shared/`

#### Domain

Responsible for:

- app-facing entities
- repository contracts
- provider-agnostic query / response models
- domain-level errors

Key folders:

- `Domain/Entities/`
- `Domain/Repositories/`
- `Domain/Errors/`

#### Data

Responsible for:

- repository implementations
- provider DTO decoding
- provider adapters
- mapping DTOs into domain entities
- local persistence
- infrastructure -> domain error translation

Key folders:

- `Data/DTOs/`
- `Data/Remote/`
- `Data/Mappers/`
- `Data/Repositories/`
- `Data/Local/`

#### Core

Responsible for:

- shared networking primitives
- logging services
- MRU utility
- common extensions

Key folders:

- `Core/Network/`
- `Core/Utils/`
- `Core/Extensions/`

---

## Flows

### Remote Headlines Flow

```text
View
  <--> ViewModel
  <--> HeadlinesRepository (protocol)
  <--> HeadlinesRepositoryImpl
  <--> RemoteHeadlinesDataSource
  <--> NetworkService
  <--> HTTPUtility
```

### Provider Selection Flow

```text
AppDI
  -> selected NewsProviderID
  -> HeadlinesDataSourceFactory
  -> NewsAPIHeadlinesDataSource / NewsDataHeadlinesDataSource / GNewsHeadlinesDataSource
  -> HeadlinesRepositoryImpl
```

### Local Storage Flow

```text
View
  <--> ViewModel
  <--> BookmarkRepository / RecentHistoryRepository / NewsCacheRepository
  <--> JSON*Store
  <--> JSONDiskStore
```

### Provider Preference Flow

```text
SettingsView
  <--> SettingsViewModel
  <--> preference storage
  <--> NewsCacheRepository
  -> refresh Home / Explore after preference change
```

---

## Multi-Source Provider Architecture

This is the main architectural upgrade from the older version of the project.

The app no longer lets the UI layer know about:

- provider base URLs
- provider DTOs
- provider-specific pagination styles
- provider-specific query formats

Instead:

- `RemoteHeadlinesDataSource` defines the provider adapter contract
- `NewsAPIHeadlinesDataSource` handles NewsAPI requests and page-number pagination
- `NewsDataHeadlinesDataSource` handles NewsData requests and token-based pagination
- `GNewsHeadlinesDataSource` handles GNews requests and page-number pagination
- `NewsDataHeadlinesDataSource` and `GNewsHeadlinesDataSource` apply provider-specific country/language preferences
- `HeadlinesRepositoryImpl` normalizes the selected provider into one domain contract
- `HeadlinesQuery` and `HeadlinesPage` are the only models the Presentation layer cares about

That means the UI always works with:

```swift
try await headlinesRepository.fetchTopHeadlines(query)
```

and never has to care which API produced the headlines.

### Why this makes provider swapping easy

To add a new provider, the architecture already gives you a predictable path:

1. Add provider DTOs in `Data/DTOs/`
2. Add provider-to-domain mappers in `Data/Mappers/`
3. Add a new `RemoteHeadlinesDataSource` implementation in `Data/Remote/`
4. Add the provider case in `App/NewsProviderID.swift`
5. Wire it in `App/HeadlinesDataSourceFactory.swift`

The rest of the app can stay unchanged.

That also means removing a provider is a localized change rather than a rewrite across screens.

---

## Tech Stack

- Swift 6
- SwiftUI
- Combine (observable presentation state)
- Swift Concurrency (`async/await`)
- WebKit (article detail)
- Kingfisher `8.8.0` (remote image loading / caching)
- `os.Logger` style structured logging

---

## Key Behaviors Implemented

- Pagination with incoming-page deduplication
- Provider-specific pagination normalized behind one repository contract
- Cache save on successful fetch + cache fallback on failed first-page fetch
- MRU recent-history behavior with max-item trimming
- Bookmark toggle with persistent storage
- Search + category filtering in Explore
- Provider-specific category availability resolved outside the UI layer
- NewsData duplicate filtering before article mapping
- NewsData country/language preference changes clear cache and reload feeds
- Infrastructure errors translated into domain `AppError` values before reaching Presentation

---

## Project Structure

```text
NewsApp-SwiftUI/
├── App/
│   ├── AppConfiguration.swift
│   ├── AppDI.swift
│   ├── AppRouter.swift
│   ├── ExploreCategoriesProvider.swift
│   ├── HeadlinesDataSourceFactory.swift
│   ├── NewsApp_SwiftUI.swift
│   └── NewsProviderID.swift
│
├── Core/
│   ├── Extensions/
│   │   └── Alert+Extension.swift
│   ├── Network/
│   │   ├── APIRequest.swift
│   │   ├── HTTPUtility.swift
│   │   └── NetworkService.swift
│   └── Utils/
│       ├── LoggerService.swift
│       ├── MRUList.swift
│       ├── OSLoggerService.swift
│       └── RemoteLoggerService.swift
│
├── Data/
│   ├── DTOs/
│   │   ├── NewsAPITopHeadlinesDTO.swift
│   │   └── NewsDataLatestDTO.swift
│   ├── Local/
│   │   ├── JSONBookmarksStore.swift
│   │   ├── JSONDiskStore.swift
│   │   ├── JSONNewsCacheStore.swift
│   │   ├── JSONRecentHistoryStore.swift
│   ├── Mappers/
│   │   ├── InfrastructureErrorMapper.swift
│   │   ├── NewsAPIArticleMapper.swift
│   │   └── NewsDataArticleMapper.swift
│   ├── Remote/
│   │   ├── NewsAPIHeadlinesDataSource.swift
│   │   ├── NewsDataHeadlinesDataSource.swift
│   │   ├── NewsDataPreferences.swift
│   │   └── RemoteHeadlinesDataSource.swift
│   └── Repositories/
│       └── HeadlinesRepositoryImpl.swift
│
├── Domain/
│   ├── Entities/
│   │   └── Article.swift
│   ├── Errors/
│   │   └── AppError.swift
│   └── Repositories/
│       ├── HeadlinesRepository.swift
│       └── StorageRepositories.swift
│
├── Presentation/
│   ├── Bookmarks/
│   ├── Explore/
│   ├── Home/
│   ├── NewsDetail/
│   ├── Settings/
│   │   └── SelectListView.swift
│   └── Shared/
│
├── Resources/
│   ├── Assets.xcassets
│   ├── Info.plist
│   └── Launch Screen.storyboard
│
├── Screenshots/
├── README.md
```

---

## Getting Started

### Prerequisites

- A NewsAPI key from [newsapi.org](https://newsapi.org/)
- A NewsData key from [newsdata.io](https://newsdata.io/)
- A GNews key from [gnews.io](https://gnews.io/)

### Setup

1. Open `NewsApp-SwiftUI.xcodeproj` in Xcode.
2. Add your runtime config through `Info.plist`, xcconfig, or build settings.
3. Configure these keys:
   - `NEWS_API_KEY`
   - `NEWSDATA_API_KEY`
   - `GNEWS_API_KEY`
   - `NEWS_COUNTRY_CODE`
   - `NEWS_LANGUAGE_CODE`
4. Build and run the scheme `iOS-News-App-SwiftUI`.

`NEWS_COUNTRY_CODE` and `NEWS_LANGUAGE_CODE` act as startup defaults. When `NewsData` or `GNews` is the active source, the user can override them in Settings at runtime.

### Switching the active provider

The active provider is selected in `App/NewsApp_SwiftUI.swift`:

```swift
appDI = AppDI(
    selectedNewsProvider: .newsData
)
```

Change it to:

- `.newsAPI`
- `.newsData`
- `.gNews`

without changing screen code or ViewModel code.

> Note: Keep API keys out of git. Local xcconfig/secrets files should stay uncommitted.

---

## Screenshots

Check [Screenshots](Screenshots)

- [01_news_landing_page_light.png](Screenshots/01_news_landing_page_light.png) — News landing page (Light)
- [02_news_detailview_webpage_light_.png](Screenshots/02_news_detailview_webpage_light_.png) — Article detail (WebView) (Light)
- [03_news_detailview_share_options_light.png](Screenshots/03_news_detailview_share_options_light.png) — Share options (Light)
- [04_news_explore_sports_light.png](Screenshots/04_news_explore_sports_light.png) — Explore: Sports (Light)
- [05_news_explore_sports_search_light.png](Screenshots/05_news_explore_sports_search_light.png) — Explore: Sports search (Light)
- [06_bookmarks_light.png](Screenshots/06_bookmarks_light.png) — Bookmarks (Light)
- [07_recent_history_light.png](Screenshots/07_recent_history_light.png) — Recent history (Light)
- [08_settings_light.png](Screenshots/08_settings_light.png) — Settings (Light)
- [9_news_landing_page_dark.png](Screenshots/9_news_landing_page_dark.png) — News landing page (Dark)
- [10_news_explore_tech_dark.png](Screenshots/10_news_explore_tech_dark.png) — Explore: Tech (Dark)
- [11_recent_history_dark.png](Screenshots/11_recent_history_dark.png) — Recent history (Dark)
- [12_settings_dark.png](Screenshots/12_settings_dark.png) — Settings (Dark)

---

## Demo Video (Screen Recording)

[Watch on YouTube](https://www.youtube.com/watch?v=Qhq0Y1JGW4M)

---

## Notes

- `DEBUG` uses `OSLoggerService`
- `RELEASE` uses `RemoteLoggerService` as the remote logging extension point

---

## License

MIT License. See [LICENSE](LICENSE).
