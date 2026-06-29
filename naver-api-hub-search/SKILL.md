---
name: naver-api-hub-search
description: NAVER API HUB 검색 스킬. 네이버 클라우드 NAVER API HUB로 블로그·뉴스·지역·웹·이미지 등 검색 및 검색어 트렌드 조회. "네이버 API HUB", "네이버 검색 API", "블로그 검색", "검색어 트렌드" 요청에 활성화.
argument-hint: "[검색종류?] [검색키워드] [정렬?] [건수?]"
---

# NAVER API HUB 검색

사용자가 네이버 검색(블로그·뉴스·지역 등) 또는 검색어 트렌드를 요청하면 [NAVER API HUB](https://guide.ncloud-docs.com/docs/apihub-overview) 공식 API를 호출한다. **웹 스크래핑은 하지 않는다.**

> 구(舊) `developers.naver.com` 검색 Open API와 엔드포인트·콘솔이 다르다. 이 스킬은 **NAVER API HUB**(`naverapihub.apigw.ntruss.com`) 기준이다.

## 사전 준비: Client ID·Secret 확인

아래 순서로 자격 증명을 확인한다:

1. 환경변수 `NAVER_API_HUB_CLIENT_ID`, `NAVER_API_HUB_CLIENT_SECRET` 확인
2. 없으면 사용자에게 요청:

```
NAVER API HUB 검색 API는 Client ID·Client Secret이 필요합니다.

1. 네이버 클라우드 플랫폼 콘솔 접속
2. Menu > All Services > Application Services > NAVER API HUB > Application
3. [Application 등록] → 사용할 API(검색·검색어 트렌드 등) 선택 → 등록
4. Application > [인증 정보]에서 Client ID / Client Secret 확인
   (가이드: https://guide.ncloud-docs.com/docs/apihub-overview)

발급된 키를 아래 중 하나로 설정해 주세요.

[방법 A] Claude Code — ~/.claude/settings.json (권장)
  "env": {
    "NAVER_API_HUB_CLIENT_ID": "발급_Client_ID",
    "NAVER_API_HUB_CLIENT_SECRET": "발급_Client_Secret"
  }
  → 저장 후 Claude Code를 재시작합니다.

[방법 B] Cursor — 통합 터미널에 환경변수 넣기
  사용자 settings.json에 추가합니다. (macOS 경로 예: ~/Library/Application Support/Cursor/User/settings.json)
  OS에 맞는 키만 사용: macOS → terminal.integrated.env.osx, Windows → terminal.integrated.env.windows, Linux → terminal.integrated.env.linux

  {
    "terminal.integrated.env.osx": {
      "NAVER_API_HUB_CLIENT_ID": "발급_Client_ID",
      "NAVER_API_HUB_CLIENT_SECRET": "발급_Client_Secret"
    }
  }

  → Cursor를 재시작한 뒤 **새 터미널**을 열어야 적용됩니다.

[방법 C] 에이전트 셸 — ~/.zshenv 또는 ~/.zshrc
  export NAVER_API_HUB_CLIENT_ID='발급_Client_ID'
  export NAVER_API_HUB_CLIENT_SECRET='발급_Client_Secret'

  설정 후 에이전트 Shell에서 길이만 확인(값 노출 금지):
  echo ${#NAVER_API_HUB_CLIENT_ID}

[방법 D] 대화 중 직접 전달
  "Client ID는 xxx, Secret은 yyy" 처럼 알려주시면 해당 대화에서만 사용합니다.
```

> HTTP 헤더명은 `X-NCP-APIGW-API-KEY-ID`(Client ID), `X-NCP-APIGW-API-KEY`(Client Secret)이다.  
> 검색 API 일일 호출 한도·이용 약관은 [NAVER API HUB 개요](https://api.ncloud-docs.com/docs/naver-api-hub-overview.md)를 따른다.

## 공통 설정

| 항목 | 값 |
|------|-----|
| Base URL | `https://naverapihub.apigw.ntruss.com` |
| 인증 헤더 | `X-NCP-APIGW-API-KEY-ID`, `X-NCP-APIGW-API-KEY` |
| GET 검색 | `Content-Type` 불필요 |
| POST(트렌드·쇼핑인사이트) | `Content-Type: application/json` |

## 입력 파싱

`$ARGUMENTS` 또는 사용자 메시지에서 추출:

| 항목 | 예시 | 기본값 |
|------|------|--------|
| 검색 종류 | 블로그, 뉴스, 지역, 웹, 이미지, 트렌드 | 문맥상 가장 맞는 종류(애매하면 **블로그**) |
| 검색어 | 커피, 정자동 카페 | (필수, 트렌드는 keywordGroups로 변환) |
| 정렬 | 정확도(`sim`), 최신(`date`), 지역은 `comment` | API 기본값 |
| 표시 건수 | 5, 10, 20 | `10` (종류별 상한 참고) |
| 시작 위치 | 2페이지 | `start=1` |

### 검색 종류 → API 경로

| 사용자 표현 | 메서드 | URI | 비고 |
|------------|--------|-----|------|
| 블로그, blog | GET | `/search/v1/blog` | `display` 1~100 |
| 뉴스, news | GET | `/search/v1/news` | `display` 1~100 |
| 웹, 웹문서, webkr | GET | `/search/v1/webkr` | `display` 1~100 |
| 이미지, image | GET | `/search/v1/image` | `display` 1~100 |
| 지식iN, kin | GET | `/search/v1/kin` | `display` 1~100 |
| 카페, 카페글, cafe | GET | `/search/v1/cafearticle` | `display` 1~100 |
| 백과, encyc | GET | `/search/v1/encyc` | `display` 1~100 |
| 지역, 맛집, local | GET | `/search/v1/local` | **`display` 1~5만** |
| 성인 판별 | GET | `/search/v1/adult` | `query`만 |
| 오타 변환 | GET | `/search/v1/errata` | `query`만 |
| 검색어 트렌드, trend | POST | `/search-trend/v1/search` | JSON 바디 |

상세 필드·응답은 필요 시 `https://api.ncloud-docs.com/docs/naver-api-hub-search-{종류}.md` 또는 [API 인덱스](https://api.ncloud-docs.com/llms.txt)에서 해당 페이지를 읽는다.

### 정렬 — 자연어 매핑 (GET 검색)

| 사용자 표현 | `sort` |
|------------|--------|
| 정확도순, 관련순, 기본 | `sim` |
| 최신순, 날짜순 | `date` |
| 지역 + 리뷰 많은 순 | `comment` (local 전용) |

### 검색어 트렌드 — 기본 바디

사용자가 기간·키워드를 주지 않으면 **최근 3개월·월간·키워드 1그룹**으로 호출한다.

- `startDate` / `endDate`: `yyyy-mm-dd` (2016-01-01 이후)
- `timeUnit`: `date` | `week` | `month`
- `keywordGroups`: 최대 5그룹, 그룹당 `keywords` 최대 20개

## API 호출

**Bash + curl + jq**로 호출한다. 한글·공백은 `--data-urlencode`(GET) 또는 JSON 파일/heredoc(POST)로 전달한다.

### GET 검색 (공통 패턴)

`{path}`를 위 표의 URI로 치환한다.

```bash
curl -s -G "https://naverapihub.apigw.ntruss.com{path}" \
  --data-urlencode "query={검색어}" \
  --data-urlencode "display={표시건수}" \
  --data-urlencode "start={시작위치}" \
  --data-urlencode "sort={sim|date|comment}" \
  --data-urlencode "format=json" \
  -H "X-NCP-APIGW-API-KEY-ID: ${NAVER_API_HUB_CLIENT_ID}" \
  -H "X-NCP-APIGW-API-KEY: ${NAVER_API_HUB_CLIENT_SECRET}" \
  | jq '{
    lastBuildDate,
    total,
    start,
    display,
    items: [.items[]? | .]
  }'
```

`sort`는 해당 API가 지원하는 값만 넣는다(지역 외에는 `sim`/`date`).

### 블로그 검색 예시

```bash
curl -s -G "https://naverapihub.apigw.ntruss.com/search/v1/blog" \
  --data-urlencode "query=커피" \
  --data-urlencode "display=10" \
  --data-urlencode "start=1" \
  --data-urlencode "sort=date" \
  --data-urlencode "format=json" \
  -H "X-NCP-APIGW-API-KEY-ID: ${NAVER_API_HUB_CLIENT_ID}" \
  -H "X-NCP-APIGW-API-KEY: ${NAVER_API_HUB_CLIENT_SECRET}" \
  | jq '.items |= map(.title |= gsub("<[^>]*>"; "")) | .items |= map(.description |= gsub("<[^>]*>"; ""))'
```

### 검색어 트렌드 (POST)

```bash
curl -s -X POST "https://naverapihub.apigw.ntruss.com/search-trend/v1/search" \
  -H "X-NCP-APIGW-API-KEY-ID: ${NAVER_API_HUB_CLIENT_ID}" \
  -H "X-NCP-APIGW-API-KEY: ${NAVER_API_HUB_CLIENT_SECRET}" \
  -H "Content-Type: application/json" \
  -d '{
    "startDate": "{시작일}",
    "endDate": "{종료일}",
    "timeUnit": "month",
    "keywordGroups": [
      { "groupName": "{주제어}", "keywords": ["{키워드1}", "{키워드2}"] }
    ]
  }' | jq .
```

### 오류 처리

| HTTP | 의미 | 조치 |
|------|------|------|
| 401 | 인증 실패 | Client ID/Secret·Application API 권한 확인 |
| 403 | 허용되지 않는 호출 | HTTPS·헤더명·인코딩 확인 |
| 429 | 한도 초과 | 일일 쿼터·Application에서 API 선택 여부 확인 |
| `errorCode` SE02~SE04 | 파라미터 오류 | `display`/`start`/`sort` 범위 확인 |
| `error.errorCode` 200 | 게이트웨이 인증 실패 | 헤더 누락·오타 |

`errorMessage` / `error.message` / `errMsg`가 있으면 사용자에게 요약해 전달한다.

## 결과 출력 형식 (GET 검색)

```
## "{검색어}" 네이버 {종류} 검색 (NAVER API HUB)

전체 약 {total}건 · 표시 {display}건 · 정렬: {sort} · 출처: NAVER API HUB 검색 API

---

### 1. {제목(HTML 태그 제거)}

- 요약: {description 일부}
- 링크: [바로가기]({link})
- (종류별 필드: bloggername, pubDate, address, category 등)

---

### 2. ...
```

### 종류별 표시 필드

| 종류 | 주요 필드 |
|------|-----------|
| blog | title, link, description, bloggername, postdate |
| news | title, originallink, link, description, pubDate |
| local | title, category, address, roadAddress, link |
| image | title, link, thumbnail, sizeheight, sizewidth |
| webkr | title, link, description |

### 검색어 트렌드 출력

```
## 검색어 트렌드: {주제어들}

기간: {startDate} ~ {endDate} · 단위: {timeUnit}

| 주제어 | 기간 | 상대 검색량(ratio) |
|--------|------|-------------------|
| ... | ... | ... |
```

`ratio`는 해당 구간 내 최대값을 100으로 한 상대값임을 한 줄로 안내한다.

## 쇼핑 인사이트 (참고)

쇼핑 클릭 트렌드는 같은 Base URL·인증으로 **POST** `/shopping-insight/v1/...` 계열 API를 쓴다. 사용자가 "쇼핑 인사이트", "쇼핑 트렌드"를 요청하면 [쇼핑 인사이트 API 목록](https://api.ncloud-docs.com/docs/naver-api-hub-overview.md)에서 해당 엔드포인트 문서를 읽고 동일한 헤더·JSON 패턴으로 호출한다.

## 주의

- `developers.naver.com` 쇼핑 검색 API(`openapi.naver.com`)와 **별도 서비스**다. 쇼핑 **상품** 검색은 `naver-shopping-search` 스킬을 쓴다.
- 키를 스킬 파일·로그·커밋에 하드코딩하지 않는다.
- API 응답 데이터의 재가공·DB 적재는 [NAVER API HUB 이용 정책](https://guide.ncloud-docs.com/docs/apihub-overview)을 확인한다.
- 지역 검색 `display` 상한은 **5**이다. 다른 검색은 최대 100.

## 추가 제안 (결과 제공 후)

```
다른 방식으로 볼까요?
- 검색 종류 변경 → "뉴스로", "지역 맛집으로"
- 최신순 → sort=date
- 다음 페이지 → start = 이전 start + display
- 검색어 트렌드 → "지난 6개월 트렌드 보여줘"
- 쇼핑 상품 검색 → naver-shopping-search 스킬(별도 API)
```
