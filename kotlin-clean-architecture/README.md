# kotlin-clean-architecture

Kotlin/Android 클린 아키텍처 패턴 Claude Code Skill.

feature-first 3계층 구조(data/domain/presentation)와 MVVM, Hilt DI를 안내합니다.

## 설치

```bash
# 이 스킬만 설치
npx skills add https://github.com/wwwshe/skills/tree/main/kotlin-clean-architecture

# 전체 스킬 한 번에 설치
npx skills add wwwshe/skills
```

## 사용법

Claude Code에서 자연어로 요청:

```
Kotlin 클린 아키텍처로 유저 프로필 기능 만들어줘
UseCase 패턴 예시 보여줘
Repository 인터페이스 어떻게 구성해?
```

## 계층 구조

```
feature_name/
├── data/           # DTO, DataSource, Repository 구현체
├── domain/         # Entity, UseCase, Repository 인터페이스
└── presentation/   # ViewModel, UI (Compose/View)
```

## 적용 스택

- UI: Jetpack Compose (또는 View)
- 상태관리: StateFlow / SharedFlow
- DI: Hilt
- 비동기: Coroutines / suspend
