---
name: swiftui-mvvm
description: SwiftUI MVVM에서 @Observable/ObservableObject 선택, @StateObject/@ObservedObject/@EnvironmentObject 사용 기준, .task/.refreshable와 취소 처리, @MainActor 상태 갱신 규칙 설계 시 사용.
---

# SwiftUI MVVM Guide

## 목적

SwiftUI + MVVM에서 상태 소유권, 생명주기, 비동기 경계를 일관되게 설계한다.

- `@StateObject`/`@ObservedObject`를 잘못 선택해 ViewModel이 재생성되는 문제
- `.task` 중복 실행으로 네트워크 요청이 과도하게 발생하는 문제
- MainActor 경계 누락으로 UI 상태 갱신이 불안정한 문제
- 화면 이탈 후 늦게 도착한 응답이 상태를 덮어쓰는 문제

## 기본 원칙

- ViewModel의 UI 상태 갱신은 `@MainActor`에서 수행
- 비즈니스/IO는 `async`/`await` 우선
- ViewModel의 상태 소유권을 먼저 정의한 뒤 프로퍼티 래퍼를 선택
- SwiftUI 생명주기에 맞춰 task 취소와 재실행을 명시적으로 설계

## 프로퍼티 래퍼 선택 기준

1. View가 ViewModel을 "생성/소유"하면 `@StateObject`(ObservableObject) 또는 `@State`(@Observable) 사용
2. 상위에서 주입받아 "참조만" 하면 `@ObservedObject` 사용
3. 앱 전역 공유 상태는 `@EnvironmentObject` 사용
4. iOS 17+ 전용이면 `@Observable` 우선 검토, 하위 버전 호환 필요 시 `ObservableObject` 유지

## 권장 패턴 (ObservableObject)

```swift
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var profile: Profile?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    func load(userID: String) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            profile = try await service.fetchProfile(userID: userID)
            errorMessage = nil
        } catch {
            errorMessage = "프로필을 불러오지 못했습니다."
        }
    }
}

struct ProfileView: View {
    let userID: String
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        content
            .task(id: userID) {
                await viewModel.load(userID: userID)
            }
            .refreshable {
                await viewModel.load(userID: userID)
            }
    }

    @ViewBuilder
    private var content: some View {
        // ...
        Text("Profile")
    }
}
```

## 권장 패턴 (@Observable, iOS 17+)

```swift
@Observable
@MainActor
final class ProfileViewModel {
    var profile: Profile?
    var isLoading = false

    func load(userID: String) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        profile = try? await service.fetchProfile(userID: userID)
    }
}

struct ProfileView: View {
    let userID: String
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        Text(viewModel.profile?.name ?? "-")
            .task(id: userID) {
                await viewModel.load(userID: userID)
            }
    }
}
```

## 취소·중복 요청 규칙

- `task(id:)`를 우선 사용해 파라미터 변경 시 이전 작업을 자동 취소
- 사용자 반복 입력(검색 등)은 debounce/throttle 정책을 별도 정의
- 최신 요청만 유효해야 하면 요청 토큰/버전 비교로 late response 무시
- 화면 이탈 시 장기 작업이 남지 않도록 cancellation 대응

## 안티패턴

```swift
// BAD: View body 계산 중 직접 비동기 호출
var body: some View {
    Text("...")
    // await viewModel.load()  // 불가
}

// BAD: 소유 View에서 @ObservedObject 사용해 재생성 이슈 유발
@ObservedObject var viewModel = ProfileViewModel()

// BAD: MainActor 경계 없이 UI 상태 변경
final class ProfileViewModel: ObservableObject {
    @Published var title = ""
    func load() async { title = "done" } // 스레드 경계 불명확
}
```

## 리뷰 체크리스트

- ViewModel 상태 소유권과 래퍼 선택이 일치하는가
- `.task` 실행 조건이 명확하고 중복 호출이 제어되는가
- `@MainActor` 경계가 일관되게 적용되었는가
- `isLoading`/error 상태가 성공·실패·취소에 대해 모두 정리되는가

## 관련 skill

- UIKit MVVM + Combine 바인딩: `swift-combine-uikit-mvvm`
- UIKit 중심 async 경계: `swift-concurrency-mvvm`
