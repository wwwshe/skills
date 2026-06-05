# swiftui-mvvm

SwiftUI MVVM 패턴을 정리한 Claude Code Skill.

`@Observable`/`ObservableObject` 선택, `@StateObject`/`@ObservedObject`/`@EnvironmentObject` 기준, `.task`/`.refreshable` 비동기 경계를 실무적으로 안내합니다.

## 설치

```bash
# 이 스킬만 설치
npx skills add https://github.com/wwwshe/skills/tree/main/swiftui-mvvm

# 전체 스킬 한 번에 설치
npx skills add wwwshe/skills
```

## 사용법

Claude Code에서 자연어로 요청:

```
SwiftUI MVVM에서 StateObject랑 ObservedObject 언제 써?
iOS 17 기준 @Observable로 ViewModel 패턴 잡아줘
.task(id:)와 refreshable 중복 호출 방지 구조 알려줘
SwiftUI 화면에서 취소 가능한 로딩 패턴 만들어줘
```

## 다루는 주제

- 상태 소유권과 프로퍼티 래퍼 선택 기준
- ViewModel `@MainActor` 경계와 UI 상태 업데이트
- `.task(id:)`, `.refreshable` 기반 비동기 로딩 패턴
- 취소(Cancellation), 중복 요청, late response 방지
- SwiftUI에서의 MVVM 안티패턴과 리뷰 체크리스트

## 관련 스킬

- [swift-combine-uikit-mvvm](../swift-combine-uikit-mvvm): UIKit MVVM + Combine 바인딩
- [swift-concurrency-mvvm](../swift-concurrency-mvvm): UIKit MVVM + Swift Concurrency 경계
