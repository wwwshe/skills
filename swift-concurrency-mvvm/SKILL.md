---
name: swift-concurrency-mvvm
description: Swift Concurrency 경계 설정, @MainActor, Task 배치, UIKit MVVM async API 설계. ViewModel, @MainActor, Task, async await, Combine 바인딩, isLoading 처리 시 사용.
---

# Swift Concurrency MVVM Guide

## 목적

UIKit + MVVM에서 Swift Concurrency를 일관되게 적용하고 다음 실수를 방지한다.

- `@MainActor` 클래스 안에서 `Task { @MainActor in }` 중복
- sync 함수 바깥 `defer` + 내부 `Task`로 `isLoading`이 조기 해제되는 구조
- async 경계 위치(ViewController vs ViewModel) 혼선
- 테스트에서 `await`로 제어하기 어려운 공개 API

## 기본 원칙

- 비동기는 `async`/`await` 우선
- UI 상태 갱신은 `@MainActor`에서만
- 네트워크/IO를 수행하는 공개 API는 기본적으로 `async`로 선언
- Combine은 View↔ViewModel 바인딩 보조로만 사용

Combine·`ObservableObject` 상세: `swift-combine-uikit-mvvm` skill 참고. **View 자동 갱신은 SwiftUI 전용**, UIKit은 `sink` 수동.

## 규칙

1. `@MainActor` 타입 안에서는 `Task { @MainActor in ... }`를 쓰지 않는다.
2. 네트워크/IO 공개 메서드는 기본적으로 `async`로 선언한다.
3. UIKit sync 진입점(`viewDidLoad`, `@objc`, 버튼 탭)에서만 `Task { await ... }`로 async 경계를 만든다.
4. `isLoading` 같은 상태 플래그는 async 본문 내부에서 `defer`로 정리한다.
5. 도메인 비동기 흐름은 Publisher 체인 대신 `async`/`await`를 우선한다.

## 권장 패턴 (기본)

```swift
@MainActor
final class ExampleViewModel {
    @Published private(set) var isLoading = false

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        // await network
    }
}

// ViewController
Task { await viewModel.load() }
```

## 허용 패턴 (예외)

sync 공개 API + 내부 `Task` 패턴은 허용하되 아래를 지킨다.

- `defer { isLoading = false }`는 `Task` 클로저 **안**에 둔다.
- 같은 프로젝트 내 ViewModel에서 패턴을 혼용하지 말고 통일한다.

## 안티패턴

```swift
// BAD: @MainActor 중복
Task { @MainActor in
    await fetch()
}

// BAD: defer가 Task 시작 전에 실행됨
func load() {
    isLoading = true
    defer { isLoading = false }
    Task { await fetch() }
}
```

## 테스트 가이드

- async 공개 API는 테스트에서 `await`로 직접 호출한다.
- `Task.sleep` 기반 대기는 최소화하고, 스텁/지연 주입으로 결정론적 검증을 우선한다.

