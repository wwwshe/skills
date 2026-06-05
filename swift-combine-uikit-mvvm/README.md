# swift-combine-uikit-mvvm

UIKit MVVM에서 Combine 바인딩을 정리하는 Claude Code Skill.

`@Published`, `PassthroughSubject`, `sink`, `AnyCancellable` 중심의 상태·이벤트 전달 패턴과 SwiftUI/ UIKit의 `ObservableObject` 차이를 명확히 안내합니다.

## 설치

```bash
# 이 스킬만 설치
npx skills add https://github.com/wwwshe/skills/tree/main/swift-combine-uikit-mvvm

# 전체 스킬 한 번에 설치
npx skills add wwwshe/skills
```

## 사용법

Claude Code에서 자연어로 요청:

```
UIKit MVVM에서 Combine 바인딩 구조 잡아줘
ObservableObject를 UIKit에서 어떻게 써야 해?
sink와 cancellables 패턴 예시 보여줘
Publisher 체인을 async/await + @Published 구조로 바꿔줘
```

## 핵심 가이드

- UIKit은 SwiftUI처럼 `ObservableObject` 자동 UI 갱신이 없음
- ViewController에서 `$property.sink`로 수동 구독 필요
- **UI 상태**는 `@Published private(set)` (제목, 로딩, 목록 등)
- **일회성 이벤트**는 `PassthroughSubject` (토스트, Alert, 화면 이동)
- 구독은 `bindViewModel()`에 모으고 `AnyCancellable`로 수명 관리
- 도메인/네트워크 로직은 `Publisher` 체인보다 `async`/`await` 우선

## 관련 스킬

- [swift-concurrency-mvvm](../swift-concurrency-mvvm): async 경계, `@MainActor`, `Task` 배치
