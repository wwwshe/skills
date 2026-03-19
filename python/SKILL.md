---
name: python
description: Python 비동기·타입힌트·Pydantic·SQLAlchemy 2 패턴 안내. Use when writing Python code, async/await, type hints, Pydantic schemas, or SQLAlchemy queries.
---

# Python

## 비동기
- `async def`, `await` 사용. I/O 바운드 작업은 비동기로.
- `asyncio.get_running_loop()`, `asyncio.create_task()`
- DB: `AsyncSession`, `asyncpg` / `postgresql+asyncpg`

## 타입 힌트
- 반환/인자: `def f(x: str) -> int`, `list[str]`, `dict[str, Any]`
- Optional: `str | None` (3.10+)
- 타입 별칭: `type UserId = UUID`

## Pydantic
- `BaseModel`, `Field(description="...")`, `Field(default_factory=list)`
- v2: `field_validator`, `model_validator`, `@classmethod`
- dict → 스키마: `SomeOut(**obj)`, 언패킹으로 생성
- 설정: `pydantic_settings.BaseSettings`, `@lru_cache def get_settings()`

## SQLAlchemy 2 스타일
- `select(Model).where(...)`, `insert(Model).values(...)`
- 결과: `r.scalar_one_or_none()`, `r.scalars().all()`
- UPSERT: `.on_conflict_do_nothing(index_elements=[...])`
- 삭제: `delete(Model).where(...)`

## 날짜·시간
- 타임존: `ZoneInfo("Asia/Seoul")`, `datetime.now(KST)`
- 문자열: `strftime("%Y-%m-%d")`, `strptime(s, "%Y-%m-%d")`

## 설정
- `pydantic_settings` + `.env`, `get_settings()` with `lru_cache`
- `Field(alias="...", default=...)`로 환경변수 매핑

## 기타
- docstring/주석: 한국어 사용
- 모델 등록용 import: `# noqa: F401` 허용
- `copy.deepcopy(obj)`로 내부 수정 시 원본 보호
