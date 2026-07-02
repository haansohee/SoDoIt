<div align="center">

<!-- TODO: 프로젝트 앱아이콘/로고 이미지 추가 -->
<!-- <img src="./docs/images/app_icon.png" width="120" /> -->

# 소두잇 (SoDoIt)

**오늘 할 일, 소소하게 그리고 확실하게 — 우선순위부터 통계까지 한 앱에서.**

![Swift](https://img.shields.io/badge/Swift-6.0-orange?logo=swift)
![iOS](https://img.shields.io/badge/iOS-26.2+-blue?logo=apple)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-lightgrey)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-brightgreen)
![Dependencies](https://img.shields.io/badge/Dependencies-Apple_Only-success)
![License](https://img.shields.io/badge/License-MIT-yellow)

<!-- TODO: App Store 출시 시 다운로드 배지/버튼 추가 -->
<!-- [![App Store](https://img.shields.io/badge/App_Store-Download-black?logo=app-store)](https://apps.apple.com/) -->

</div>

---

## 📑 목차

- [프로젝트 소개](#-프로젝트-소개)
- [주요 기능](#-주요-기능)
- [기술 스택](#-기술-스택)
- [아키텍처](#-아키텍처)
- [데이터 모델](#-데이터-모델)
- [폴더 구조](#-폴더-구조)
- [기술적 고민 / 트러블 슈팅](#-기술적-고민--트러블-슈팅)
- [컨벤션](#-컨벤션)
- [라이브러리 의존성](#-라이브러리-의존성)

---

## 📖 프로젝트 소개

### 배경 및 동기
할 일 앱은 많지만, 대부분은 **너무 무겁거나(협업·프로젝트 관리 기능 과잉) 너무 가벼워서(단순 체크리스트)** 개인의 하루를 관리하기에 애매합니다.
정작 필요한 것은 "오늘 무엇을 먼저 해야 하는가"를 빠르게 정리하고, 마감을 놓치지 않으며, 내가 얼마나 해냈는지 되돌아보는 **가벼우면서도 충분한** 도구입니다.

**소두잇(SoDoIt)** 은 이런 고민에서 시작된 프로젝트입니다.
우선순위·마감일·카테고리로 할 일을 정리하고, 마감 알림으로 놓치지 않으며, 통계 화면과 홈 화면 위젯으로 진행 상황을 한눈에 확인할 수 있는 **개인용 할 일 관리 앱**입니다.
외부 라이브러리 없이 **Apple 프레임워크만으로** 구축하여, 최신 SwiftUI·CoreData 생태계를 온전히 학습하고 활용하는 것을 목표로 삼았습니다.

### 핵심 가치
- ⚡️ **Focus** — 우선순위와 스마트 필터로 "지금 할 일"에 집중
- 🗂 **Organize** — 커스텀 색상·아이콘 카테고리로 할 일을 체계적으로 분류
- 📈 **Reflect** — 통계와 위젯으로 성취를 시각화하고 동기 부여

---

## ✨ 주요 기능

> <!-- TODO: 각 기능별 스크린샷 이미지 추가 필요 -->
> 📸 스크린샷은 추후 `docs/screenshots/` 경로에 추가 예정입니다.

| 기능 | 설명 |
| --- | --- |
| **✅ 할 일 관리** | 할 일 생성·조회·수정·삭제(CRUD), 스와이프로 완료/미완료 토글 |
| **🚩 우선순위** | 높음 / 보통 / 낮음 3단계, 우선순위 색상 표시 및 정렬 |
| **⏰ 마감일 & 알림** | 날짜·시간 지정, 마감 임박·초과 시각적 표시, 로컬 푸시 알림 |
| **🗂 카테고리** | 커스텀 색상·SF Symbol 아이콘 카테고리로 분류·필터링 |
| **🔎 스마트 필터** | 전체 / 오늘 / 예정 / 완료 기준 빠른 필터링 및 정렬 옵션 |
| **📊 통계** | 완료율·주간 완료 추이·우선순위 분포를 Swift Charts로 시각화 |
| **📱 홈 화면 위젯** | WidgetKit 기반, 앱을 열지 않고도 오늘 할 일 확인 |
| **⚙️ 설정** | 알림·표시 옵션 등 앱 환경 설정 |

<!-- TODO: 기능별 스크린샷 예시
<div align="center">
  <img src="./docs/screenshots/list.png" width="200" />
  <img src="./docs/screenshots/stats.png" width="200" />
  <img src="./docs/screenshots/widget.png" width="200" />
</div>
-->

---

## 🛠 기술 스택

| 카테고리 | 사용 기술 |
| --- | --- |
| **Language** | Swift 6.0 |
| **Minimum iOS** | iOS 26.2 |
| **UI** | SwiftUI (선언형 UI) |
| **Architecture** | MVVM + Repository Pattern |
| **State Management** | `@Observable` (Observation 프레임워크) |
| **Persistence** | CoreData (`NSPersistentContainer`) |
| **Widget** | WidgetKit + App Group 공유 저장소 |
| **Charts** | Swift Charts |
| **Notification** | UserNotifications (로컬 알림) |
| **Concurrency** | `MainActor` 기본 격리 (`SWIFT_DEFAULT_ACTOR_ISOLATION`) |
| **Dependency Manager** | 외부 의존성 없음 (Apple 프레임워크만 사용) |
| **지원 기기** | iPhone (Portrait) |
| **Xcode** | 26.2 |

---

## 🏛 아키텍처

<!-- TODO: 아키텍처 다이어그램 이미지 추가 -->
<!-- <img src="./docs/architecture.png" width="700" /> -->

본 프로젝트는 **MVVM(Model-View-ViewModel)** 패턴에 **Repository 패턴**을 결합하여, 데이터 접근 로직과 UI 로직을 명확히 분리했습니다.

### 레이어별 역할

```
┌─────────────────────────────────────────────────┐
│  View Layer (SwiftUI)                            │
│  TodoListView · AddTodoView · EditTodoView       │
│  StatsView · SettingsView · CategoryListView     │
├─────────────────────────────────────────────────┤
│  ViewModel Layer (@Observable)                   │
│  TodoListViewModel · TodoFormViewModel(공통 기반)  │
│  StatsViewModel · SettingsViewModel · ...        │
├─────────────────────────────────────────────────┤
│  Service Layer (Repository Pattern)              │
│  TodoRepository · CategoryRepository             │
│  StatisticsRepository                            │
│  CoreDataManager · NotificationManager           │
│  WidgetDataManager (싱글톤)                        │
├─────────────────────────────────────────────────┤
│  Data Layer (CoreData)                           │
│  TodoItem · Category 엔티티                        │
└─────────────────────────────────────────────────┘
```

- **View**: SwiftUI 선언형 뷰. 사용자 입력을 `ViewModel`에 전달하고, `@Observable` 상태 변화를 자동으로 반영합니다.
- **ViewModel**: `@Observable`로 상태를 노출하며, `Repository`를 통해 데이터를 읽고 씁니다. 폼 화면은 `TodoFormViewModel` 공통 기반 클래스를 상속해 추가/수정 로직을 재사용합니다.
- **Service**: `Repository`가 CoreData CRUD를 캡슐화하고, `throws` + `context.rollback()`으로 데이터 일관성을 보장합니다. `CoreDataManager`·`NotificationManager`·`WidgetDataManager`가 각각 저장소·알림·위젯 동기화를 담당합니다.
- **Data**: `TodoItem`·`Category` 엔티티. `NSManagedObject` 서브클래스는 `wrapped*` 계산 프로퍼티로 안전한 옵셔널 언래핑을 제공합니다.

### 오류 처리 전략
모든 데이터 작업에 일관된 3단계 오류 처리를 적용합니다.

1. **Repository**: `throws` + 실패 시 `context.rollback()`으로 데이터 일관성 보장
2. **ViewModel**: `catch`에서 에러 상태로 전환 + `Logger`(OSLog)로 기록
3. **View**: `.alert(item:)` 수정자로 사용자에게 한글 오류 메시지 표시

### 선택 이유
- **SwiftUI + @Observable + CoreData** 조합으로, 별도 반응형 라이브러리 없이도 데이터 변경이 UI에 자동 반영되는 선언형 흐름을 구성했습니다.
- **Repository 패턴**으로 CoreData 접근을 한 곳에 모아, ViewModel은 저장소 구현을 모른 채 도메인 로직에만 집중할 수 있습니다.
- **외부 의존성 제로** 원칙으로, Apple 최신 프레임워크(Observation, Swift Charts, WidgetKit)를 온전히 학습·활용합니다.

---

## 🗃 데이터 모델

### TodoItem

| 속성 | 타입 | 설명 |
| --- | --- | --- |
| `id` | UUID | 고유 식별자 (자동 생성) |
| `title` | String | 할 일 제목 (필수) |
| `memo` | String? | 메모 |
| `dueDate` | Date? | 마감일 |
| `priority` | Int16 | 우선순위 (0=높음, 1=보통, 2=낮음) |
| `isCompleted` | Bool | 완료 여부 |
| `completedAt` | Date? | 완료 시각 |
| `createdAt` | Date | 생성일 (자동 생성) |
| `category` | Category? | 소속 카테고리 (다대일) |

### Category

| 속성 | 타입 | 설명 |
| --- | --- | --- |
| `id` | UUID | 고유 식별자 (자동 생성) |
| `name` | String | 카테고리 이름 (필수) |
| `colorHex` | String | 색상 Hex 코드 (기본: `#007AFF`) |
| `iconName` | String | SF Symbol 아이콘명 (기본: `folder.fill`) |
| `createdAt` | Date | 생성일 (자동 생성) |
| `todoItems` | NSSet? | 소속된 할 일들 (일대다) |

**관계**: `TodoItem` ↔ `Category` (다대일, optional, 삭제 시 Nullify)

---

## 📂 폴더 구조

```
SoDoIt/
├── SoDoItApp.swift          # 앱 진입점, viewContext 주입
├── ContentView.swift
│
├── Models/                  # CoreData 엔티티 · 도메인 열거형
│   ├── TodoItem / Category  # NSManagedObject 서브클래스
│   ├── Priority             # 우선순위 enum
│   ├── SmartFilter          # 전체/오늘/예정/완료 필터
│   ├── SortOption           # 정렬 기준
│   ├── WidgetTodoItem       # 위젯 공유용 모델
│   └── SoDoIt.xcdatamodeld  # CoreData 모델
│
├── Services/
│   ├── Manager/             # CoreDataManager, NotificationManager, WidgetDataManager
│   └── Repository/          # TodoRepository, CategoryRepository, StatisticsRepository
│
├── ViewModels/
│   ├── Common/              # TodoFormViewModel (공통 기반 클래스)
│   ├── TodoList/ · AddTodo/ · EditTodo/
│   ├── Category/            # CategoryListViewModel, AddCategoryViewModel
│   ├── Stats/ · Settings/
│
├── Views/
│   ├── MainTabView.swift    # 탭 기반 루트 뷰
│   ├── Common/              # TodoFormBodyView, ChipButton, EmptyStateView
│   ├── TodoList/            # TodoListView, TodoRowView, SmartFilterBar, CategoryFilterBar
│   ├── AddTodo/ · EditTodo/
│   ├── Category/            # CategoryListView, AddCategoryView, Components/
│   ├── Stats/               # StatsView, Components/ (차트)
│   └── Settings/            # SettingsView
│
├── Extensions/              # Color+Hex, Font+Pretendard, View+DismissKeyboard, AppAnimation
├── Resources/Fonts/         # Pretendard Custom Font
└── Assets.xcassets/         # 앱 아이콘, AccentColor

SoDoItWidget/                # 홈 화면 위젯 (WidgetKit)
├── SoDoItWidgetBundle.swift
├── TodoListWidget.swift
├── TodoWidgetProvider.swift
├── TodoWidgetEntryView.swift
└── WidgetTodoItem.swift
```

---

## 🔍 기술적 고민 / 트러블 슈팅

### 1. 추가/수정 화면의 폼 로직 중복

#### 문제 상황
할 일 **추가(AddTodo)** 와 **수정(EditTodo)** 화면은 입력 필드(제목·메모·마감일·우선순위·카테고리)가 사실상 동일했습니다.
두 화면을 각각 구현하면서 검증·바인딩 로직이 양쪽에 중복되어, 필드를 하나 추가할 때마다 **두 곳을 동시에 수정**해야 하는 유지보수 부담이 생겼습니다.

#### 해결 방법
1. `TodoFormViewModel` **공통 기반 클래스**를 두어 폼 상태와 검증 로직을 한곳에 모으고, `AddTodoViewModel`·`EditTodoViewModel`이 이를 상속하도록 설계했습니다.
2. UI는 `TodoFormBodyView` **공통 뷰**로 분리해, 추가/수정 화면이 동일한 폼 UI를 공유하도록 했습니다.
3. 저장 시점의 동작(신규 삽입 vs 기존 업데이트)만 각 서브클래스에서 오버라이드했습니다.

#### 결과
- 폼 필드 추가·검증 규칙 변경이 **단일 지점 수정**으로 반영되어 유지보수 비용이 크게 줄었습니다.
- 추가/수정 화면의 UI·동작 일관성이 자연스럽게 보장되었습니다.

---

### 2. 앱과 위젯 간 데이터 공유

#### 문제 상황
홈 화면 위젯이 "오늘 할 일"을 표시해야 하지만, **위젯 확장(Extension)은 앱 본체와 별도의 프로세스·샌드박스**에서 동작하므로 앱의 CoreData 저장소에 직접 접근할 수 없었습니다.
그 결과 앱에서 할 일을 완료해도 위젯이 갱신되지 않는 문제가 있었습니다.

#### 해결 방법
1. **App Group**을 구성해 앱과 위젯이 공유하는 저장 공간을 마련했습니다.
2. `WidgetDataManager`가 위젯 표시에 필요한 데이터를 경량 모델(`WidgetTodoItem`)로 직렬화해 공유 저장소에 기록하도록 했습니다.
3. 할 일에 변경이 생기면 `WidgetCenter`로 타임라인 리로드를 요청해, **앱의 변경이 위젯에 즉시 반영**되도록 했습니다.

#### 결과
- 앱을 열지 않고도 홈 화면에서 오늘 할 일을 확인할 수 있게 되었습니다.
- 앱과 위젯 사이의 데이터 정합성이 유지되어, 완료 처리 후 위젯이 실시간으로 갱신됩니다.

---

## 📐 컨벤션

### Git Flow / Branch 전략
**Git Flow** 기반으로 운영합니다.

```
main         ← 프로덕션 릴리스 (.gitignore 관리)
 ├─ develop  ← 통합 개발 브랜치
 ├─ release  ← 릴리스 후보
 └─ feature/{기능명}   # develop에서 분기하는 기능 브랜치
```

- 모든 기능 작업은 `develop`에서 브랜치를 분기하여 PR로 병합합니다.
- `main`은 릴리스 태그와 동기화됩니다.

### Commit 메시지 규칙
타입 prefix를 사용합니다.

```
<type>: <간단한 설명>
```

| Prefix | 용도 |
| --- | --- |
| `feat:` | 신규 기능 추가 |
| `fix:` | 버그 수정 |
| `refactor:` | 리팩토링 |
| `docs:` | 문서 수정 |

### 코드 컨벤션
- **네이밍**: Swift API Design Guidelines 준수 (UpperCamelCase / lowerCamelCase)
- **동시성**: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` 기본 격리
- **CoreData**: `NSManagedObject` 접근 시 `wrapped*` 계산 프로퍼티로 안전하게 언래핑
- **상태 관리**: ViewModel은 `@Observable`로 선언, View는 상태를 구독만 함
- **오류 처리**: Repository `throws` → ViewModel `Logger` 기록 → View `.alert` 표시
- **프리뷰**: `CoreDataManager.preview`(인메모리 저장소)로 SwiftUI 프리뷰 지원

---

## 📦 라이브러리 의존성

**외부 의존성이 없습니다.** 모든 기능은 Apple이 제공하는 프레임워크만으로 구현되었습니다.

| 프레임워크 | 사용 목적 |
| --- | --- |
| **SwiftUI** | 선언형 UI 구성 |
| **Observation** | `@Observable` 기반 상태 관리 |
| **CoreData** | 로컬 영구 저장소 |
| **WidgetKit** | 홈 화면 위젯 |
| **Swift Charts** | 통계 화면 차트 시각화 |
| **UserNotifications** | 마감일 로컬 알림 |
| **Combine** | 이벤트 스트림 처리 |
| **OSLog** | 구조화된 로깅 |

> 커스텀 폰트로 **Pretendard**를 번들에 포함하여 사용합니다.

### 빌드 방법

```bash
# 빌드 (사용 가능한 시뮬레이터는 `xcrun simctl list devices available`로 확인)
xcodebuild -project SoDoIt.xcodeproj -scheme SoDoIt \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

---

<div align="center">

Made with ❤️ by <a href="https://github.com/haansohee">haansohee</a>

</div>
