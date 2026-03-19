# fastapi-backend

FastAPI 백엔드 패턴 Claude Code Skill.

라우터·의존성·JWT 인증·에러 처리부터 SQLAlchemy 2·Pydantic v2·asyncpg까지 FastAPI 백엔드 전반을 안내합니다.

## 설치

```bash
# 이 스킬만 설치
npx skills add https://github.com/wwwshe/skills/tree/main/fastapi-backend

# 전체 스킬 한 번에 설치
npx skills add wwwshe/skills
```

## 사용법

Claude Code에서 자연어로 요청:

```
FastAPI 라우터 구조 잡아줘
JWT 인증 의존성 만들어줘
SQLAlchemy 2 스타일로 쿼리 작성해줘
Pydantic v2로 요청/응답 스키마 정의해줘
에러 응답 형식 통일하는 전역 핸들러 만들어줘
```

## 적용 스택

| 항목 | 기술 |
|------|------|
| 프레임워크 | [FastAPI](https://fastapi.tiangolo.com) |
| ORM | SQLAlchemy 2 (async) |
| DB | PostgreSQL + asyncpg |
| 스키마 | Pydantic v2 |
| 인증 | JWT (Bearer) |
| 설정 | pydantic_settings + .env |
