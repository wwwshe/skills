# swift-concurrency-mvvm

UIKit MVVM에서 Swift Concurrency 적용 경계를 정리하는 Claude Code Skill.

`@MainActor`, `Task`, `async/await`, `isLoading` 상태 처리에서 자주 생기는 실수를 줄이고, 테스트 가능한 비동기 API 패턴을 안내합니다.

## 설치

```bash
# 이 스킬만 설치
npx skills add https://github.com/wwwshe/skills/tree/main/swift-concurrency-mvvm

# 전체 스킬 한 번에 설치
npx skills add wwwshe/skills
```

## 사용법

Claude Code에서 자연어로 요청:

```
UIKit MVVM에서 async 경계 어디에 두는 게 좋아?
@MainActor ViewModel에서 Task 패턴 정리해줘
isLoading이 빨리 false 되는 버그 패턴 고쳐줘
테스트 가능한 async ViewModel API로 바꿔줘
```

## 핵심 가이드

- `@MainActor` 타입 안에서 `Task { @MainActor in ... }` 중복 사용 금지
- 네트워크/IO 공개 메서드는 기본적으로 `async` 선언
- UIKit sync 진입점(`viewDidLoad`, 버튼 액션)에서만 `Task { await ... }`로 경계 생성
- 상태 플래그(`isLoading`)는 async 본문 내부 `defer`로 정리
- 도메인 비동기 흐름은 Publisher 체인보다 `async`/`await` 우선

## 관련 스킬

- [swift-combine-uikit-mvvm](../swift-combine-uikit-mvvm): UIKit MVVM에서 Combine 바인딩 패턴
