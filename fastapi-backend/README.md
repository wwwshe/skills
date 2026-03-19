# fastapi-backend

FastAPI 백엔드 패턴 Claude Code Skill.

async/await, Pydantic v2, SQLAlchemy 2, PostgreSQL 기반 백엔드 작성 패턴을 안내합니다.

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
FastAPI로 유저 CRUD API 만들어줘
SQLAlchemy 2 스타일로 쿼리 작성해줘
Pydantic v2로 요청/응답 스키마 정의해줘
pydantic_settings로 환경변수 설정 구성해줘
```

## 적용 스택

| 항목 | 기술 |
|------|------|
| 프레임워크 | [FastAPI](https://fastapi.tiangolo.com) |
| ORM | SQLAlchemy 2 (async) |
| DB | PostgreSQL + asyncpg |
| 스키마 | Pydantic v2 |
| 설정 | pydantic_settings + .env |
