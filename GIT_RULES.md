# Git 규칙

이 프로젝트는 GitFlow 기반 브랜치 전략을 사용합니다.

## 브랜치 전략

- `main`: 운영 배포 이력만 유지
- `develop`: 다음 릴리스 통합 브랜치
- `feature/*`: 기능 개발 브랜치 (기준: `develop`)
- `release/*`: 릴리스 준비 브랜치 (기준: `develop`)
- `hotfix/*`: 긴급 수정 브랜치 (기준: `main`)

## 기본 작업 흐름

1. `develop`에서 `feature/*` 브랜치를 생성
2. 기능 개발 후 Pull Request로 `develop`에 병합
3. 배포 시점에 `release/*` 생성 후 안정화
4. 안정화 완료 후 `main` 병합 + 태그
5. 긴급 이슈는 `hotfix/*`로 처리 후 `main`, `develop`에 반영

## 커밋 메시지 규칙 (필수)

Conventional Commits 형식을 따릅니다.

```
<type>: <한글 설명>
<type>(<scope>): <한글 설명>
```

- `<type>`은 아래 중 하나만 사용합니다.
  - `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `release`
- 제목(첫 줄)에는 **한글이 최소 1자 이상** 포함되어야 합니다.
- `SwiftUI`, `MVVM`, `UIKit`, `iOS`, `API` 같은 기술 용어의 영문 표기는 허용합니다.
- 요약 1줄 + 필요 시 본문으로 작성합니다.

예시:

- `feat: SwiftUI MVVM 스킬 문서 추가`
- `docs: GitFlow 규칙 및 커밋 훅 설치 가이드 추가`
- `fix: 커밋 메시지 훅 검사 오류 수정`

## 훅 적용

저장소 루트에서 아래 명령으로 로컬 훅을 활성화합니다.

```bash
bash scripts/install-hooks.sh
```

적용되는 훅:

- `commit-msg`: Conventional Commits + 한글 규칙 검사
- `pre-commit`: GitFlow 브랜치명 검사
