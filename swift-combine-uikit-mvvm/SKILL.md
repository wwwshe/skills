---
name: swift-combine-uikit-mvvm
description: UIKit MVVM에서 Combine 바인딩, @Published, PassthroughSubject, ObservableObject 역할, sink/cancellables 패턴. UI 상태는 @Published, 화면 이동/토스트/Alert 같은 일회성 이벤트는 PassthroughSubject. SwiftUI vs UIKit ObservableObject 차이, Combine 바인딩 설계 시 사용.
---

# Combine · UIKit MVVM Guide

## ObservableObject — 핵심 구분

핵심 구분:

- `ObservableObject`는 `objectWillChange`를 노출하는 **Combine 프로토콜**이다.
- **SwiftUI**에서 `@ObservedObject` / `@StateObject`와 연결되면 View가 **자동으로 다시 그려진다**.
- **UIKit**에서는 이 자동 갱신이 **없다**. ViewController가 `sink`로 **수동 구독**해야 한다.

> View 자동 갱신 관점의 `ObservableObject` 사용처는 SwiftUI이고, UIKit에서는 `sink` 수동 구독이 필요하다.

UIKit에서는 ObservableObject 채택이 필수는 아니다.
ViewController는 @Published의 Publisher($property)를 직접 구독할 수 있다.

## 역할 분리

| 계층 | 도구 | 용도 |
|------|------|------|
| ViewModel 로직 | `async`/`await` | API, 캐시, I/O |
| ViewModel → View (상태) | `@Published` + `sink` | 화면에 남는 UI 상태 (제목, 로딩, 목록 등) |
| ViewModel → View (이벤트) | `PassthroughSubject` + `sink` | 화면 이동, 토스트, Alert 등 **일회성** 액션 |
| SwiftUI View | `@ObservedObject` | 자동 갱신 |

## 상태 vs 일회성 이벤트

ViewModel 출력을 두 종류로 나눈다.

| 종류 | 도구 | 예시 | ViewController 처리 |
|------|------|------|---------------------|
| **UI 상태** | `@Published` | `title`, `isLoading`, `items` | 라벨·인디케이터·테이블 갱신 |
| **일회성 이벤트** | `PassthroughSubject` | `showToast`, `showAlert`, `navigateToDetail` | 토스트 표시, Alert present, push/present |

- `@Published`는 현재 상태(State)를 표현한다. 새로운 구독자는 현재 상태 값을 즉시 전달받을 수 있으므로 토스트처럼 한 번만 소비되어야 하는 이벤트에는 적합하지 않다.
- `PassthroughSubject`는 **이벤트 스트림**이다. `send()`할 때만 전달되고 이전 값을 보관하지 않는다.
- 이벤트 Subject는 기본적으로 `let`으로 노출한다. 단, 외부에서 `send()`를 막아야 할 정도로 규모가 커지거나 모듈 경계가 생기면 `private Subject + AnyPublisher`로 감싼다.
```swift
// 상태
@Published private(set) var title: String = ""

// 일회성 이벤트
let showToast = PassthroughSubject<String, Never>()
let navigateToDetail = PassthroughSubject<Item, Never>()
```

## UIKit MVVM 권장 패턴

```swift
@MainActor
final class ExampleViewModel {
    @Published private(set) var title: String = ""
    @Published private(set) var isLoading = false

    let showToast = PassthroughSubject<String, Never>()

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            title = try await api.fetchTitle()
        } catch {
            showToast.send("불러오기에 실패했습니다.")
        }
    }
}


final class ExampleViewController: UIViewController {
    private let viewModel: ExampleViewModel
    private var cancellables = Set<AnyCancellable>()

    private func bindViewModel() {
        viewModel.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.activityIndicator.isHidden = !isLoading
            }
            .store(in: &cancellables)

        viewModel.showToast
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showToast(message)
            }
            .store(in: &cancellables)
    }
}
```

## 규칙

1. **UI 상태**는 `@Published private(set)`로만 노출한다.
2. **일회성 이벤트**(토스트, Alert, 화면 이동)는 `PassthroughSubject`로 분리한다. `@Published`에 넣지 않는다.
3. ViewController는 `bindViewModel()` 한곳에서 `@Published`와 Subject 구독을 모은다.
4. `sink` 클로저에 `[weak self]` 사용.
5. 네트워크/도메인 로직은 `Publisher` 체인 대신 `async`/`await`. 에러 시 `showToast.send(...)` 등으로 View에 위임.
6. UIKit 바인딩에서는 `receive(on: DispatchQueue.main)`를 명시적으로 유지한다. (`@MainActor`와 중복 가능하지만 의도를 드러내기 위해 허용)

## Combine을 쓰는 이유 (UIKit)

- UIKit에는 SwiftUI의 `@Observable` / `@ObservedObject` 자동 갱신이 없다.
- `@Published` 변경을 ViewController가 구독해야 한다.
- delegate/closure도 가능하지만, 상태 프로퍼티가 많을수록 `sink` + `cancellables`가 정리하기 쉽다.
- RxSwift 경험이 있으면 Hot observable + 구독 해제 개념과 유사하다.

## 안티패턴

```swift
// BAD: API를 Publisher 체인으로
api.fetchContacts()
    .flatMap { ... }
    .sink { ... }

// BAD: UIKit인데 ObservableObject만 conform하고 sink 없이 기대
// → UI는 갱신되지 않음

// BAD: ViewController가 ViewModel 상태를 직접 폴링

// BAD: 토스트/Alert를 @Published로
@Published var toastMessage: String?  // 구독 시 이전 메시지가 재전달될 수 있음

// GOOD: 일회성 이벤트는 Subject
let showToast = PassthroughSubject<String, Never>()
```

## SwiftUI vs UIKit 요약

| | SwiftUI | UIKit MVVM |
|---|---|---|
| ViewModel | `ObservableObject` + `@Published` | `@Published`(상태) + `PassthroughSubject`(이벤트) |
| View 연결 | `@ObservedObject` / `@StateObject` | `$property.sink` + `subject.sink` |
| 갱신 | 자동 | 수동 |
| 구독 해제 | 프레임워크 | `AnyCancellable` |

## 관련 skill

- 비동기 경계·Task·@MainActor: `swift-concurrency-mvvm`
