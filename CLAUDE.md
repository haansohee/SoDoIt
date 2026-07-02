# CLAUDE.md

이 파일은 Claude Code(claude.ai/code)가 이 저장소에서 작업할 때 참고하는 가이드입니다.
**이 파일은 항상 한국어로 작성한다.**

## 빌드 및 실행

```bash
# 빌드 (사용 가능한 시뮬레이터는 `xcrun simctl list devices available`로 확인)
xcodebuild -project SoDoIt.xcodeproj -scheme SoDoIt \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# 클린 빌드
xcodebuild -project SoDoIt.xcodeproj -scheme SoDoIt clean build \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

외부 의존성 없음 — Apple 프레임워크만 사용 (SwiftUI, CoreData, Combine, WidgetKit, Swift Charts, UserNotifications, Observation).

## 아키텍처

**MVVM + Repository + CoreData** 기반 SwiftUI 선언형 UI.

- `SoDoIt/Models/` — CoreData 엔티티 (`TodoItem`, `Category`), `Priority`·`SmartFilter`·`SortOption` enum, 위젯 공유 모델(`WidgetTodoItem`), `.xcdatamodeld`
- `SoDoIt/Services/Manager/` — `CoreDataManager`(NSPersistentContainer 래퍼)·`NotificationManager`·`WidgetDataManager` 싱글톤
- `SoDoIt/Services/Repository/` — `TodoRepository`·`CategoryRepository`·`StatisticsRepository` (CoreData CRUD 캡슐화, `throws` + `context.rollback()`)
- `SoDoIt/ViewModels/` — `@Observable` ViewModel. 추가/수정 화면은 `TodoFormViewModel` 공통 기반 클래스를 상속
- `SoDoIt/Views/` — 기능별(TodoList/AddTodo/EditTodo/Category/Stats/Settings/Common)로 구성된 SwiftUI 뷰
- `SoDoIt/Extensions/` — 공용 Swift 익스텐션 (`Color+Hex`, `Font+Pretendard` 등)
- `SoDoItWidget/` — WidgetKit 홈 화면 위젯 (App Group으로 앱과 데이터 공유)

**오류 처리:** Repository `throws` → ViewModel `catch`에서 `Logger`(OSLog) 기록 → View `.alert(item:)`로 한글 메시지 표시

**CoreData 모델:**
- `TodoItem` ↔ `Category` (다대일, optional, 삭제 시 Nullify)
- NSManagedObject 서브클래스는 `wrapped*` 계산 프로퍼티로 안전한 언래핑 처리
- `CoreDataManager.shared` (프로덕션), `.preview` (SwiftUI 프리뷰용 인메모리 저장소)
- `SoDoItApp`에서 `.environment(\.managedObjectContext, ...)`로 viewContext 주입

**Priority enum** — `TodoItem.priority`(Int16)에 매핑: `.high`(0), `.medium`(1), `.low`(2)

## Git 전략 (Git Flow)

```
main ← 프로덕션 (.gitignore만 관리)
├── develop ← 통합 브랜치
├── release ← 릴리스 후보
└── feature/* ← 기능 브랜치 (develop에서 분기)
```

커밋 컨벤션: `feat:`, `fix:`, `refactor:`, `docs:` 접두사 사용.

## 프로젝트 설정

- **Bundle ID**: `sso.SoDoIt` (위젯: `sso.SoDoIt.SoDoItWidget`)
- **Swift**: 6.0, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
- **최소 iOS**: 26.2
- **지원 기기**: iPhone 전용 (`TARGETED_DEVICE_FAMILY = 1`)
- **Xcode**: 26.2, `PBXFileSystemSynchronizedRootGroup` 사용 (파일 자동 동기화, pbxproj 수동 편집 불필요)
- **언어**: 한국어 (UI 문자열 한국어)
