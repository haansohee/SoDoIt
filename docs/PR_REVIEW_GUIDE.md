# SoDoIt - PR 리뷰 가이드

이 문서는 SoDoIt 프로젝트의 PR(Pull Request) 리뷰 시 확인해야 할 항목들을 정리한 가이드입니다.

---

## 1. 아키텍처 준수

### 계층 분리 (MVVM + Repository)

- [ ] View에 비즈니스 로직이 포함되어 있지 않은가?
  - View는 UI 렌더링과 사용자 입력 전달만 담당해야 함
  - CoreData 직접 접근, 데이터 가공 로직은 ViewModel/Repository에 있어야 함
- [ ] ViewModel에서 SwiftUI 의존(`import SwiftUI`)을 사용하고 있지 않은가?
  - ViewModel은 `Foundation`, `CoreData`, `Observation`만 import 해야 함
- [ ] Repository를 거치지 않고 CoreData context를 직접 조작하고 있지 않은가?
  - 모든 CRUD는 `TodoRepository` 또는 `CategoryRepository`를 통해야 함

### 파일 배치

- [ ] 새 파일이 올바른 디렉토리에 위치하는가?
  - 공통 ViewModel → `ViewModels/Common/`
  - 공통 View → `Views/Common/`
  - 기능별 View/ViewModel → 해당 기능 폴더 (예: `Views/TodoList/`)
- [ ] 기존 공통 컴포넌트를 재사용할 수 있는데 새로 만들지 않았는가?
  - 폼 UI → `TodoFormBodyView` 재사용 가능한지 확인
  - 폼 ViewModel → `TodoFormViewModel` 상속 가능한지 확인

---

## 2. CoreData

### 데이터 모델 변경

- [ ] `.xcdatamodeld` 변경 시 마이그레이션 전략이 고려되었는가?
- [ ] 새 속성 추가 시 `Optional` 또는 기본값이 설정되어 있는가?
- [ ] NSManagedObject 서브클래스에 `wrapped*` 계산 프로퍼티로 안전한 언래핑이 적용되었는가?
- [ ] 관계(Relationship) 변경 시 삭제 규칙(Nullify/Cascade)이 적절한가?

### Context 안전성

- [ ] `save()` 호출이 `do-catch` 블록 안에 있는가?
- [ ] 저장 실패 시 `context.rollback()`이 호출되는가?
- [ ] `viewContext`를 메인 스레드 외에서 접근하고 있지 않은가?

### FRC (NSFetchedResultsController)

- [ ] `performFetch()` 실패가 처리되고 있는가?
- [ ] `controllerDidChangeContent` 델리게이트에서 올바른 FRC를 식별하고 있는가? (`===` 비교)
- [ ] `performFetch()` 후 결과를 직접 할당하는 중복이 없는가? (델리게이트가 처리하므로)
  - **예외:** predicate/sortDescriptors 변경 후 `performFetch()`를 다시 호출하는 경우, `controllerDidChangeContent`가 호출되지 않으므로 `fetchedObjects`를 직접 할당해야 함

---

## 3. 오류 처리

### Repository 계층

- [ ] 데이터 조작 메서드가 `throws`로 선언되어 있는가?
- [ ] 실패 시 `context.rollback()` 후 에러를 re-throw 하는가?
- [ ] `print()` 대신 `Logger`를 사용하고 있는가?

### ViewModel 계층

- [ ] Repository의 에러를 catch하고 있는가?
- [ ] 에러 상태를 UI에 전달할 수 있는 프로퍼티로 설정하는가?
- [ ] `TodoListError`처럼 Identifiable enum을 사용하여 에러 종류를 구분하는가?
- [ ] 실패 시 이전 상태로 롤백이 필요한 경우 처리되었는가? (예: `applyFilter` 실패 시 predicate 복원)

### View 계층

- [ ] `.alert` 수정자가 ViewModel의 에러 상태에 바인딩되어 있는가?
- [ ] 에러 메시지가 사용자 친화적인 한국어로 작성되어 있는가?
- [ ] 에러 alert 닫은 후 앱이 정상 상태로 돌아오는가?

---

## 4. SwiftUI View

### 상태 관리

- [ ] ViewModel이 `@State`로 선언되어 있는가? (`@Observable` 클래스이므로)
- [ ] `@Bindable`이 필요한 곳에 올바르게 사용되었는가? (하위 View에서 바인딩 필요 시)
- [ ] `@Environment(\.dismiss)`가 적절히 사용되었는가?

### UI 일관성

- [ ] 모든 UI 텍스트가 한국어인가?
- [ ] 기존 화면들과 시각적 스타일이 일관되는가?
  - Section 헤더 스타일
  - 버튼 배치 (취소: `.cancellationAction`, 확인: `.confirmationAction`)
  - 스와이프 액션 색상 (완료: 녹색, 삭제: 빨강)
- [ ] `NavigationStack` / `.navigationBarTitleDisplayMode(.inline)` 등 네비게이션 패턴이 기존과 일치하는가?

### 성능

- [ ] `ForEach` 내부에서 불필요한 계산이나 뷰 생성이 없는가?
- [ ] 무거운 뷰가 `@ViewBuilder` 또는 별도 컴포넌트로 분리되어 있는가?

---

## 5. 코드 중복

- [ ] 기존 공통 컴포넌트와 중복되는 코드가 있는가?
  - `TodoFormBodyView`: 폼 섹션 (제목, 메모, 마감일, 우선순위, 카테고리)
  - `TodoFormViewModel`: FRC 설정, formState, 에러 프로퍼티
- [ ] 새로운 중복이 발생했다면 공통 추출이 가능한가?
- [ ] 상속(`TodoFormViewModel`)과 컴포지션 중 적절한 방식을 선택했는가?

---

## 6. Git 컨벤션

### 브랜치

- [ ] `feature/*` 브랜치에서 작업하고 있는가? (main 직접 커밋 금지)
- [ ] 브랜치명이 기능을 명확히 설명하는가?

### 커밋

- [ ] 커밋 메시지가 컨벤션을 따르는가?
  - `feat:` 새로운 기능
  - `fix:` 버그 수정
  - `refactor:` 리팩토링
  - `docs:` 문서
- [ ] 커밋 단위가 적절한가? (하나의 커밋 = 하나의 논리적 변경)

### PR

- [ ] PR 제목이 변경 내용을 간결하게 설명하는가?
- [ ] PR 설명에 "왜" 이 변경이 필요한지 작성되어 있는가?
- [ ] 관련 이슈가 있다면 링크되어 있는가?

---

## 7. 리뷰 우선순위

PR 리뷰 시 다음 순서로 확인하면 효율적입니다.

| 순서 | 항목 | 이유 |
|------|------|------|
| 1 | **빌드 성공 여부** | 기본 전제 조건 |
| 2 | **아키텍처 준수** | 구조적 문제는 나중에 고치기 어려움 |
| 3 | **CoreData 안전성** | 데이터 손실/불일치는 치명적 |
| 4 | **오류 처리** | 사용자 경험에 직접 영향 |
| 5 | **코드 중복** | 유지보수성에 영향 |
| 6 | **UI 일관성** | 사용자 경험 품질 |
| 7 | **Git 컨벤션** | 협업 품질 |

---

## 8. 리뷰 코멘트 작성 팁

### 심각도 표시

코멘트에 심각도를 명시하면 작성자가 우선순위를 판단하기 쉽습니다.

- **[필수]**: 반드시 수정해야 머지 가능 (버그, 데이터 손실 위험, 아키텍처 위반)
- **[권장]**: 수정을 강하게 권장하지만 블로커는 아님 (오류 처리 누락, 코드 중복)
- **[제안]**: 개선 아이디어 (네이밍, 코드 스타일, 성능 최적화)
- **[질문]**: 의도를 확인하고 싶은 부분

### 예시

```
[필수] save() 실패 시 context.rollback()이 빠져 있습니다.
데이터 불일치가 발생할 수 있으므로 추가해주세요.

[권장] 이 로직은 TodoFormViewModel의 기존 FRC 설정과 중복됩니다.
상속을 활용하면 코드를 줄일 수 있습니다.

[제안] 이 변수명을 `filteredCategory`보다 `activeFilter`로 하면
필터 바의 컨텍스트와 더 잘 맞을 것 같습니다.

[질문] 여기서 performFetch() 후 직접 할당하는 이유가 있나요?
델리게이트가 처리하지 않나요?
```
