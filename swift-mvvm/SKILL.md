---
name: swift-mvvm
description: Swift/iOS MVVM 패턴 안내. Model·View·ViewModel 구조, 바인딩(Combine/@Published), 서비스/저장소 연동 시 사용.
---

# Swift MVVM

## 구조

```
FeatureName/
├── Model/          # 도메인 모델, DTO
├── View/           # SwiftUI View 또는 UIKit ViewController
├── ViewModel/      # 뷰 상태·로직, 입력 처리
└── Service/        # (선택) API, DB, 비즈니스 로직
```

### 의존성 방향
- **View** → ViewModel만 참조 (Model 직접 참조 최소화)
- **ViewModel** → Model, Service(또는 Repository) 사용
- **Model**은 다른 계층에 의존하지 않음

---

## Model

순수 데이터. `Codable`로 직렬화 시 DTO와 동일하게 두거나, 화면용 모델만 둘 수 있음.

```swift
struct User: Equatable {
    let id: String
    let name: String
}

// API 응답이 다르면 DTO로 변환
struct UserDTO: Codable {
    let id: String
    let name: String

    var toModel: User {
        User(id: id, name: name)
    }
}
```

---

## ViewModel

뷰 상태와 사용자 액션 처리. `ObservableObject` + `@Published` 또는 `@Observable`(iOS 17+) 사용.

### ObservableObject + @Published (Combine)

```swift
@MainActor
final class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var error: Error?
    @Published var isLoading = false

    private let userService: UserServiceProtocol

    init(userService: UserServiceProtocol) {
        self.userService = userService
    }

    func loadUser(id: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            user = try await userService.fetchUser(id: id)
        } catch {
            self.error = error
        }
    }
}
```

### @Observable (iOS 17+)

```swift
@Observable
@MainActor
final class UserViewModel {
    var user: User?
    var error: Error?
    var isLoading = false

    private let userService: UserServiceProtocol

    init(userService: UserServiceProtocol) {
        self.userService = userService
    }

    func loadUser(id: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            user = try await userService.fetchUser(id: id)
        } catch {
            self.error = error
        }
    }
}
```

---

## View

ViewModel만 주입하고, 상태는 바인딩으로 반영.

### SwiftUI (ObservableObject)

```swift
struct UserView: View {
    @StateObject private var viewModel: UserViewModel

    var body: some View {
        Group {
            if viewModel.isLoading { ProgressView() }
            else if let user = viewModel.user { Text(user.name) }
            else if let error = viewModel.error { Text(error.localizedDescription) }
        }
        .task { await viewModel.loadUser(id: userId) }
    }
}
```

### SwiftUI (@Observable)

```swift
struct UserView: View {
    @State private var viewModel: UserViewModel

    var body: some View {
        // @Observable이면 @State만으로 자동 구독
        // ...
        .task { await viewModel.loadUser(id: userId) }
    }
}
```

### UIKit

```swift
final class UserViewController: UIViewController {
    private let viewModel: UserViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewModel.loadUser(id: userId)
    }

    private func bindViewModel() {
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.updateUI(user: user)
            }
            .store(in: &cancellables)
    }
}
```

---

## Service (선택)

API·DB 접근. ViewModel은 이 레이어만 의존하도록 하면 테스트·교체가 쉬움.

```swift
protocol UserServiceProtocol {
    func fetchUser(id: String) async throws -> User
}

final class UserService: UserServiceProtocol {
    private let apiClient: APIClient

    func fetchUser(id: String) async throws -> User {
        let dto: UserDTO = try await apiClient.request(.user(id))
        return dto.toModel
    }
}
```

---

## 의존성 주입

- **수동 주입**: App/SceneDelegate에서 Service 생성 후 ViewModel에 주입
- **Container**: 한 곳에서 Service·ViewModel 팩토리 관리

```swift
final class DIContainer {
    lazy var userService: UserServiceProtocol = UserService(apiClient: apiClient)
    func makeUserViewModel() -> UserViewModel {
        UserViewModel(userService: userService)
    }
}
```

---

## 네이밍

- 파일: `PascalCase.swift` (타입명과 동일)
- ViewModel: `XxxViewModel`
- Service: `XxxServiceProtocol` (프로토콜), `XxxService` (구현체)
- View: `XxxView` (SwiftUI), `XxxViewController` (UIKit)
