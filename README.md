# iOS News App (SwiftUI + MVVM)

A production-style iOS News app built with **SwiftUI** and **MVVM**, featuring **async/await networking**, **REST API integration**, **pagination**, **disk-backed caching**, and clean **state management**.  
Built as a portfolio project to demonstrate scalable architecture, resilient data handling, and polished SwiftUI UX patterns.

**Data source credit:** https://newsapi.org/

---

## Portfolio Summary

This project demonstrates:

- Protocol-based **dependency injection** for infrastructure concerns
- **Offline-first fallback** (restore cached content when first-page fetch fails)
- Reusable **JSON disk storage** for cache, bookmarks, and recent history
- Structured logging and **error mapping** for user-friendly messaging
- Clear View ↔ ViewModel boundaries with testable components

---

## Features

- **Top Headlines** feed with pull-to-refresh and infinite scrolling
- **Explore** with category filters and search
- **Article detail** in a WebKit-powered view
- **Bookmarks** with persistent storage
- **Recently viewed (MRU)** history with max-item trimming
- **Settings** actions to clear cache, bookmarks, and history

---

## Skills Demonstrated

- SwiftUI composition with **tab-based navigation**
- MVVM with clear **View / ViewModel** responsibility boundaries
- Pragmatic **dependency injection** with concrete feature resources
- async/await networking with **pagination state management**
- Disk persistence (JSON) for cache, bookmarks, and recent history
- Error mapping from low-level failures → **UI-safe messages**
- Structured logging with environment-based provider selection
- Reusable UI components and consistent **empty/loading/error** states

---

## Architecture Overview

This project keeps **protocols for shared infrastructure** and uses **concrete feature resources** where extra abstraction does not add value.

### Protocols (in `Dependencies/`)
- `NetworkService` (protocol)
- `LoggerService` (protocol)
- Storage protocols:
  - `StorageService` (protocol entry point)
  - plus **separate protocols per store** (NewsCache / Bookmarks / RecentHistory)

### Implementations (by folder)
- `NetworkService/HTTPUtility` → `NetworkService` implementation
- `NewsService/NewsResource` → concrete news data source (uses `NetworkService`)
- `LoggerService/OSLoggerService`, `LoggerService/RemoteLoggerService` → `LoggerService` implementations
- `StorageService/JSONNewsCacheStore`, `JSONBookmarksStore`, `JSONRecentHistoryStore` → store implementations

`AppDependencies` wires everything and injects ViewModels.

---

## Flows

### Data flow (News)
`View <--> ViewModel <-> NewsResource -> NetworkService (protocol) -> HTTPUtility`

### Logging flow
`View <--> ViewModel <-> LoggerService (protocol) -> OSLoggerService / RemoteLoggerService`

### Cache / Storage flow
`View <--> ViewModel <-> (NewsCacheStore / BookmarksStore / RecentHistoryStore protocols) -> JSON*Store -> JSONDiskStore`

---

## Tech Stack

- Swift 6
- SwiftUI
- Combine (observable state)
- Swift Concurrency (async/await)
- WebKit (article detail)
- Kingfisher `8.6.2` (remote image loading/caching)
- `os.Logger` (structured local logging)

---

## Key Behaviors Implemented

- Pagination with deduplication and load-more thresholds
- Cache save on successful fetch + cache fallback on first-page fetch failure
- MRU recent-history behavior with max-item trimming
- Bookmark toggle with persistent storage
- Search + category filtering in Explore
- Unified empty/loading/error UX states with retry pathways

---

## Screenshots

Check [Screenshots](Screenshots)

* [01_news_landing_page_light.png](Screenshots/01_news_landing_page_light.png) — News landing page (Light)
* [02_news_detailview_webpage_light_.png](Screenshots/02_news_detailview_webpage_light_.png) — Article detail (WebView) (Light)
* [03_news_detailview_share_options_light.png](Screenshots/03_news_detailview_share_options_light.png) — Share options (Light)
* [04_news_explore_sports_light.png](Screenshots/04_news_explore_sports_light.png) — Explore: Sports (Light)
* [05_news_explore_sports_search_light.png](Screenshots/05_news_explore_sports_search_light.png) — Explore: Sports search (Light)
* [06_bookmarks_light.png](Screenshots/06_bookmarks_light.png) — Bookmarks (Light)
* [07_recent_history_light.png](Screenshots/07_recent_history_light.png) — Recent history (Light)
* [08_settings_light.png](Screenshots/08_settings_light.png) — Settings (Light)
* [9_news_landing_page_dark.png](Screenshots/9_news_landing_page_dark.png) — News landing page (Dark)
* [10_news_explore_tech_dark.png](Screenshots/10_news_explore_tech_dark.png) — Explore: Tech (Dark)
* [11_recent_history_dark.png](Screenshots/11_recent_history_dark.png) — Recent history (Dark)
* [12_settings_dark.png](Screenshots/12_settings_dark.png) — Settings (Dark)

---

## Demo Video (Screen Recording)

[Watch on YouTube](https://www.youtube.com/watch?v=Qhq0Y1JGW4M)
---

## Project Structure

```text
NewsApp-SwiftUI-MVVM-Combine/
├── Dependencies/
│   ├── AppDependencies.swift
│   ├── AppDependencies+Environment.swift
│   ├── LoggerService.swift          # protocol
│   ├── NetworkService.swift         # protocol
│   └── StorageService.swift         # protocol(s) / store protocols entry point
│
├── ErrorMappers/
│   ├── NavigationErrorMapper.swift
│   └── NetworkErrorMapper.swift
│
├── Extensions/
│   └── Alert+Extension.swift
│
├── LoggerService/
│   ├── OSLoggerService.swift        # LoggerService implementation
│   └── RemoteLoggerService.swift    # placeholder implementation
│
├── Model/
│   ├── Article.swift
│   ├── ArticleDisplayFormatter.swift
│   ├── ArticlePage.swift
│   ├── ExploreCategory.swift
│   └── Source.swift
│
├── NetworkService/
│   ├── APIConstants.swift
│   ├── APIRequest.swift
│   ├── HTTPUtility.swift            # NetworkService implementation
│   ├── NetworkLogger.swift
│   ├── NewsAPIKey.swift
│   └── (other networking helpers)
│
├── NewsService/
│   └── NewsResource.swift           # concrete news data source
│
├── StorageService/
│   ├── JSONDiskStore.swift
│   ├── JSONNewsCacheStore.swift
│   ├── JSONBookmarksStore.swift
│   ├── JSONRecentHistoryStore.swift
│   └── MRUList.swift
│
├── View/
│   ├── NewsView.swift
│   ├── ExploreView.swift
│   ├── BookmarksView.swift
│   ├── SettingsView.swift
│   ├── NewsDetailView.swift
│   ├── NewsDetailScene.swift
│   ├── NewsViewListItem.swift
│   ├── CategoryChips.swift
│   ├── ImageBuilderView.swift
│   └── EmptyStateView.swift
│
├── ViewModel/
│   ├── NewsViewModels/
│   │   ├── NewsPaginationState.swift
│   │   └── NewsViewModel.swift
│   ├── ExploreViewModel.swift
│   ├── BookmarksViewModel.swift
│   ├── NewsDetailViewModel.swift
│   └── SettingsViewModel.swift
│
└── Secrets/
    └── APIKey (local-only; do not commit)
```

---

## Getting Started

### Prerequisites
- A NewsAPI key (newsapi.org)

### Setup
1. Open `NewsApp-SwiftUI-MVVM-Combine.xcodeproj` in Xcode.
2. Select target `NewsApp-SwiftUI-MVVM-Combine`.
3. Add a **User-Defined** build setting:
   - Key: `API_KEY`
   - Value: your NewsAPI key
4. Ensure `Info.plist` reads the key via `$(API_KEY)`.
5. Build and run the scheme `iOS-News-App-SwiftUI`.

> Note: Keep API keys out of git. If you use a `Secrets/` file locally, ensure it’s gitignored.

---

## Notes

- Logging provider switches by runtime environment:
  - `DEBUG` → `OSLoggerService`
  - `RELEASE` → `RemoteLoggerService` placeholder (extension point)
- No test target is currently included (planned: ViewModel + service tests)

---

## License

MIT License. See [LICENSE](LICENSE).
