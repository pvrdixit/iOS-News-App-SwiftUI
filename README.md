# iOS News App (SwiftUI + MVVM)

A production-style iOS News app built with **SwiftUI** and **MVVM**, featuring **async/await networking**, **REST API integration**, **pagination**, **disk-backed caching**, and clean **state management**.  
Built as a portfolio project to demonstrate scalable architecture, resilient data handling, and polished SwiftUI UX patterns.

**Data source credit:** https://newsapi.org/

---

## Portfolio Summary

This project demonstrates:

- Protocol-based **dependency injection** and service abstraction
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
- Protocol-oriented **dependency injection**
- async/await networking with **pagination state management**
- Disk persistence (JSON) for cache, bookmarks, and recent history
- Error mapping from low-level failures → **UI-safe messages**
- Structured logging with environment-based provider selection
- Reusable UI components and consistent **empty/loading/error** states

---

## Architecture Overview (Protocols + Implementations)

This project is protocol-driven. Core domains expose **protocols** and concrete implementations live in their feature folders.

### Protocols (in `Dependencies/`)
- `NetworkService` (protocol)
- `LoggerService` (protocol)
- `NewsService` (protocol)
- Storage protocols:
  - `StorageService` (protocol entry point)
  - plus **separate protocols per store** (NewsCache / Bookmarks / RecentHistory)

### Implementations (by folder)
- `NetworkService/HTTPUtility` → `NetworkService` implementation
- `NewsService/NewsResource` → `NewsService` implementation (uses `NetworkService`)
- `LoggerService/OSLoggerService`, `LoggerService/RemoteLoggerService` → `LoggerService` implementations
- `StorageService/JSONNewsCacheStore`, `JSONBookmarksStore`, `JSONRecentHistoryStore` → store implementations

`AppDependencies` wires everything and injects ViewModels.

---

## Flows

### Data flow (News)
`View <--> ViewModel <-> NewsResource (NewsService impl) <-> NetworkService (protocol) -> HTTPUtility`

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
- [01_launch_light.png](Screenshots/01_launch_light.png) — Launch (Light)
- [02_news_list_light.png](Screenshots/02_news_list_light.png) — Headlines list (Light)
- [03_news_detail_light.png](Screenshots/03_news_detail_light.png) — Article detail (Light)
- [04_news_explore_sports_light.png](Screenshots/04_news_explore_sports_light.png) — Explore: category (Light)
- [05_news_search_light.png](Screenshots/05_news_search_light.png) — Explore: search (Light)
- [06_bookmarks_blank_light.png](Screenshots/06_bookmarks_blank_light.png) — Bookmarks empty (Light)
- [07_bookmarks_saved_light.png](Screenshots/07_bookmarks_saved_light.png) — Bookmarks saved (Light)
- [08_recent_history_light.png](Screenshots/08_recent_history_light.png) — Recent history (Light)
- [09_settings_light.png](Screenshots/09_settings_light.png) — Settings (Light)
- [10_settings_confirm_prompt_light.png](Screenshots/10_settings_confirm_prompt_light.png) — Settings confirmation prompt (Light)
- [11_error_propagation_light.png](Screenshots/11_error_propagation_light.png) — Error state (Light)
- [12_pull_to_refresh_loading_light.png](Screenshots/12_pull_to_refresh_loading_light.png) — Pull-to-refresh loading (Light)
- [13_news_list_dark.png](Screenshots/13_news_list_dark.png) — Headlines list (Dark)
- [14_news_detail_dark.png](Screenshots/14_news_detail_dark.png) — Article detail (Dark)
- [15_news_explore_dark.png](Screenshots/15_news_explore_dark.png) — Explore (Dark)
- [16_bookmarks_saved_dark.png](Screenshots/16_bookmarks_saved_dark.png) — Bookmarks saved (Dark)
- [17_settings_dark.png](Screenshots/17_settings_dark.png) — Settings (Dark)

---

## Project Structure

```text
NewsApp-SwiftUI-MVVM-Combine/
├── Dependencies/
│   ├── AppDependencies.swift
│   ├── AppDependencies+Environment.swift
│   ├── LoggerService.swift          # protocol
│   ├── NetworkService.swift         # protocol
│   ├── NewsService.swift            # protocol
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
│   ├── ExploreCategory.swift
│   ├── Headlines.swift
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
│   └── NewsResource.swift           # NewsService implementation
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
