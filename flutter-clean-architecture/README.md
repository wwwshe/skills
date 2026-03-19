# flutter-clean-architecture

Flutter 클린 아키텍처 패턴 Claude Code Skill.

feature-first 3계층 구조(data/domain/presentation)와 Riverpod 기반 상태관리를 안내합니다.

## 설치

```bash
# 이 스킬만 설치
npx skills add https://github.com/wwwshe/skills/tree/main/flutter-clean-architecture

# 전체 스킬 한 번에 설치
npx skills add wwwshe/skills
```

## 사용법

Claude Code에서 자연어로 요청:

```
Flutter 클린 아키텍처로 로그인 기능 만들어줘
새 feature 추가할 때 폴더 구조 어떻게 해?
Repository 패턴 예시 보여줘
```

## 계층 구조

```
lib/features/feature_name/
├── data/           # DataSource, Model, Repository 구현체
├── domain/         # Entity, UseCase/Service, Repository 인터페이스
└── presentation/   # Riverpod Provider, Screen, Widget
```

## 적용 스택

- 상태관리: [Riverpod](https://riverpod.dev)
- 직렬화: freezed / json_serializable (선택)
- DI: 생성자 주입 또는 Riverpod Provider
