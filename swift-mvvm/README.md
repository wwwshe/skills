# swift-mvvm

Swift/iOS MVVM 패턴 Claude Code Skill.

Model·View·ViewModel 구조와 Combine/@Published 바인딩, 의존성 주입 패턴을 안내합니다.

## 설치

```bash
# 이 스킬만 설치
npx skills add https://github.com/wwwshe/skills/tree/main/swift-mvvm

# 전체 스킬 한 번에 설치
npx skills add wwwshe/skills
```

## 사용법

Claude Code에서 자연어로 요청:

```
Swift MVVM으로 유저 프로필 화면 만들어줘
ViewModel에서 async/await로 API 호출하는 예시 보여줘
SwiftUI + ObservableObject 바인딩 어떻게 해?
DIContainer 패턴으로 의존성 주입 구성해줘
```

## 구조

```
FeatureName/
├── Model/      # 도메인 모델, DTO
├── View/       # SwiftUI View 또는 UIKit ViewController
├── ViewModel/  # 상태·로직, 사용자 액션 처리
└── Service/    # API, DB, 비즈니스 로직 (선택)
```

## 적용 스택

- UI: SwiftUI (ObservableObject / @Observable) 또는 UIKit
- 바인딩: Combine / @Published
- 비동기: async/await
- DI: 수동 주입 / DIContainer
