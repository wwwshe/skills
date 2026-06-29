# naver-api-hub-search

네이버 클라우드 **NAVER API HUB** 공식 검색 API로 블로그·뉴스·지역·웹·이미지 등을 조회하고 검색어 트렌드를 조회하는 에이전트 스킬입니다.

> 구 `developers.naver.com` 검색 API가 아닌, Ncloud 콘솔 **NAVER API HUB** 기준입니다.

## 설치

```bash
# 이 스킬만 설치
npx skills add https://github.com/wwwshe/skills/tree/main/naver-api-hub-search

# 전체 스킬 한 번에 설치
npx skills add wwwshe/skills
```

## 사전 준비: NAVER API HUB Application

1. [네이버 클라우드 플랫폼](https://www.ncloud.com/) 콘솔 로그인
2. **Menu** > **All Services** > **Application Services** > **NAVER API HUB** > **Application**
3. **[Application 등록]** → 사용할 API(검색, 검색어 트렌드 등) 선택
4. **[인증 정보]**에서 Client ID / Client Secret 발급

가이드: [NAVER API HUB 개요](https://guide.ncloud-docs.com/docs/apihub-overview)

### 환경변수

| 변수 | 설명 |
|------|------|
| `NAVER_API_HUB_CLIENT_ID` | Client ID (`X-NCP-APIGW-API-KEY-ID`) |
| `NAVER_API_HUB_CLIENT_SECRET` | Client Secret (`X-NCP-APIGW-API-KEY`) |

#### Claude Code

`~/.claude/settings.json`:

```json
{
  "env": {
    "NAVER_API_HUB_CLIENT_ID": "발급_Client_ID",
    "NAVER_API_HUB_CLIENT_SECRET": "발급_Client_Secret"
  }
}
```

#### Cursor

사용자 `settings.json`에 `terminal.integrated.env.osx`(또는 windows/linux)로 설정 후 Cursor 재시작·새 터미널.

#### 대화에서만

에이전트에게 Client ID/Secret을 알려 주면 해당 대화에서만 사용합니다.

## 사용법

```
네이버 블로그에서 커피 검색해줘
뉴스에서 반도체 최신순 20개
정자동 카페 지역 검색
검색어 트렌드로 아이폰 vs 갤럭시 지난 6개월
```

## 지원 API (요약)

| 종류 | 엔드포인트 |
|------|------------|
| 블로그 | `GET /search/v1/blog` |
| 뉴스 | `GET /search/v1/news` |
| 웹 | `GET /search/v1/webkr` |
| 이미지 | `GET /search/v1/image` |
| 지식iN | `GET /search/v1/kin` |
| 카페글 | `GET /search/v1/cafearticle` |
| 백과 | `GET /search/v1/encyc` |
| 지역 | `GET /search/v1/local` (display 최대 5) |
| 검색어 트렌드 | `POST /search-trend/v1/search` |

Base URL: `https://naverapihub.apigw.ntruss.com`

## 관련 스킬

- **쇼핑 상품 검색**: [naver-shopping-search](../naver-shopping-search) (`developers.naver.com` 쇼핑 API)

## 문서

- [NAVER API HUB 사용 가이드](https://guide.ncloud-docs.com/docs/apihub-overview)
- [NAVER API HUB API 개요](https://api.ncloud-docs.com/docs/naver-api-hub-overview.md)
- [검색 예제](https://api.ncloud-docs.com/docs/naver-api-hub-search-examples.md)
