---
name: fastapi-backend
description: FastAPI 백엔드 패턴 안내. 라우터·의존성·JWT 인증·에러 처리·SQLAlchemy 2·Pydantic v2·asyncpg 작성 시 사용.
---

# FastAPI 백엔드

## 프로젝트 구조
- 라우터: 기능별 모듈 분리 (예: `app/api/v1/`), `include_router(router, prefix="/v1/app")`
- 의존성: 별도 모듈로 분리 (예: `app/api/deps.py`) — `get_current_user`, `get_db` 등
- 모델/스키마/서비스: 레이어별 분리 (예: `app/models/`, `app/schemas/`, `app/services/`)

## 라우터

```python
router = APIRouter(prefix="/items", tags=["items"])

@router.get("/", response_model=ItemListOut, responses={401: {...}})
async def list_items(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    ...
    return ItemListOut(**data)
```

- `response_model=...` — Pydantic 스키마로 자동 직렬화
- `responses={401: {...}, 404: {...}}` — Swagger 문서화

## 의존성

- 인증: `user: User = Depends(get_current_user)`, `user_id: UUID = Depends(get_current_user_id)`
- DB: `db: AsyncSession = Depends(get_db)`
- Bearer: `HTTPBearer(auto_error=True)` → `HTTPAuthorizationCredentials`

## 인증 (JWT)

- `decode_access_token(token)` → payload 검증
- payload: `type=="access"`, `sub`=user_id (UUID)
- 401: `HTTPException(status_code=401, detail="invalid_or_expired_access_token")`

## 에러 응답

- `HTTPException` → 전역 핸들러로 `{ "error_code": "...", "message": "..." }` JSON 변환
- `detail`에 `error_code` 문자열 사용 (예: `user_not_found`, `invalid_token`)
- 4xx/5xx 모두 `error_code` + `message` 형태로 통일

## 설정·미들웨어

- `pydantic_settings.BaseSettings` + `.env`, `@lru_cache def get_settings()`
- `Field(alias="...", default=...)` 으로 환경변수 매핑
- CORS: `CORSMiddleware`, `allow_origins`, `allow_credentials=True`
- 레이트리밋: slowapi `@limiter.limit("10/minute")`
- lifespan: `@asynccontextmanager` for DB init, scheduler 등

## Pydantic v2

- `BaseModel`, `Field(description="...")`, `Field(default_factory=list)`
- `field_validator`, `model_validator`, `@classmethod`
- dict → 스키마: `SomeOut(**obj)`

## SQLAlchemy 2 (async)

- DB: `AsyncSession`, `asyncpg` / `postgresql+asyncpg`
- `select(Model).where(...)`, `insert(Model).values(...)`
- 결과: `r.scalar_one_or_none()`, `r.scalars().all()`
- UPSERT: `.on_conflict_do_nothing(index_elements=[...])`
- 삭제: `delete(Model).where(...)`

## 비동기·타입 힌트

- I/O 바운드 작업은 `async def` / `await`
- 반환/인자: `def f(x: str) -> int`, `list[str]`, `str | None` (3.10+)
- 타입 별칭: `type UserId = UUID`

## 기타

- docstring/주석: 한국어 사용
- 모델 등록용 import: `# noqa: F401` 허용
- `copy.deepcopy(obj)`로 내부 수정 시 원본 보호
