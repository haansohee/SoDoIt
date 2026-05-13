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

외부 의존성 없음 — Apple 프레임워크만 사용 (SwiftUI, CoreData, Combine).

## 아키텍처

**MVVM + CoreData** 기반 SwiftUI 선언형 UI.

- `SoDoIt/Models/` — CoreData 엔티티 (`TodoItem`, `Category`), `Priority` enum, `.xcdatamodeld`
- `SoDoIt/Services/` — `CoreDataManager` 싱글톤 (`NSPersistentContainer` 래퍼)
- `SoDoIt/Extensions/` — 공용 Swift 익스텐션
- ViewModels (예정) — `@Published` 프로퍼티, Combine 파이프라인
- Views (예정) — 기능별로 구성된 SwiftUI 뷰

**CoreData 모델:**
- `TodoItem` ↔ `Category` (다대일, optional, 삭제 시 Nullify)
- NSManagedObject 서브클래스는 `wrapped*` 계산 프로퍼티로 안전한 언래핑 처리
- `CoreDataManager.shared` (프로덕션), `.preview` (SwiftUI 프리뷰용 인메모리 저장소)
- `SoDoItApp`에서 `.environment(\.managedObjectContext, ...)`로 viewContext 주입

**Priority enum** — `TodoItem.priority`(Int16)에 매핑: `.high`(0), `.medium`(1), `.low`(2)

## Git 전략 (Git Flow)

```
main ← 프로덕션 (release에서 머지로만 갱신, App Store 출시 버전과 일치)
├── develop ← 통합 브랜치 (feature가 머지되는 곳)
├── release ← 릴리스 후보 (develop에서 머지, QA 완료 후 main으로 승격)
├── feature/* ← 기능 브랜치 (develop에서 분기)
├── fix/* ← 버그 수정 브랜치 (develop에서 분기)
└── hotfix/* ← 긴급 수정 (main에서 분기 → main·develop 양쪽 머지)
```

v1.0(2026-05) 출시를 기점으로 main은 production 상태를 반영하도록 변경됨.
이전에는 `.gitignore`만 관리했으나 표준 Git Flow에 맞춰 release → main 머지로 갱신.

커밋 컨벤션: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:` 접두사 사용.
릴리스 시점에는 main에 `v{X.Y.Z}` 태그 부여.

## 프로젝트 설정

- **Bundle ID**: `sso.SoDoIt`
- **Swift**: 5.0, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
- **지원 기기**: iPhone + iPad
- **Xcode**: 26.2, `PBXFileSystemSynchronizedRootGroup` 사용 (파일 자동 동기화, pbxproj 수동 편집 불필요)
- **언어**: 한국어 (UI 문자열 한국어)
