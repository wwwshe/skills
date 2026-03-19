---
name: job-posting-search-kr
description: 한국 채용공고 검색 스킬. "iOS 개발자 채용 찾아줘", "백엔드 신입 공고 알려줘", "프론트엔드 서울 채용" 같은 요청에 활성화. 원티드·점핏 API와 링크드인 HTML 파싱으로 실시간 공고를 가져온다.
argument-hint: "[직무키워드] [경력?] [지역?]"
---

# 한국 채용공고 검색

사용자가 채용공고 검색을 요청하면 원티드·점핏·링크드인 세 곳을 동시에 조회해 결과를 합쳐서 보여준다.

## 입력 파싱

`$ARGUMENTS` 또는 사용자 메시지에서 추출:

| 항목 | 예시 |
|------|------|
| 직무키워드 | iOS, 백엔드, 프론트엔드, 데이터엔지니어, 풀스택 |
| 경력 | 신입(`years=0`), 1년(`years=1`), 3년(`years=3`), 전체(`years=-1`) |
| 지역 | 서울(`seoul`), 경기(`gyeonggi`), 부산(`busan`), 전체(`all`) |

경력/지역 언급이 없으면 전체(`years=-1`, `locations=all`)로 검색한다.

## API 호출

**Bash tool + curl + jq 로 호출한다. 회사명·포지션명은 jq가 추출한 값을 그대로 사용한다.**

세 플랫폼 호출은 병렬로 실행한다 (단일 Bash 블록에서 `&` + `wait` 사용).

### 1. 원티드 (wanted.co.kr)

#### 공고 목록 조회

```bash
curl -s "https://www.wanted.co.kr/api/v4/jobs?country=kr&query={키워드}&job_sort=job.latest_order&years={경력}&locations={지역}&limit=10&offset=0" \
  -H "User-Agent: Mozilla/5.0" \
  | jq '.data[] | {id, position, company_name: .company.name, company_id: .company.id, location: .address.location, due_time, annual_from, annual_to}'
```

추출 필드:
- `id` → URL: `https://www.wanted.co.kr/wd/{id}`
- `position` — 포지션명
- `company_name` — 회사명
- `company_id` — 인원수 조회에 사용
- `location` — 지역
- `due_time` — 마감일 (null이면 상시)
- `annual_from` / `annual_to` — 연봉 (**천만원 단위**). `annual_to`가 100이면 "협의". 출력: `{annual_from}천만~{annual_to}천만원`

#### 인원수 조회 (공고별 병렬 호출)

```bash
curl -s "https://www.wanted.co.kr/api/v4/companies/{company_id}" \
  -H "User-Agent: Mozilla/5.0" \
  | jq '.company.company_tags[] | select(.kind_title == "COMPANY_MANAGEMENT" and (.title | test("명$"))) | .title'
```

결과가 없으면 "미공개"로 표시한다.

### 2. 점핏 (jumpit.co.kr)

```bash
curl -s "https://jumpit-api.saramin.co.kr/api/positions?keyword={키워드}&page=1&sort=latest" \
  -H "User-Agent: Mozilla/5.0" \
  | jq '.result | {totalCount, positions: [.positions[] | {id, title, companyName, locations, closedAt, minCareer, maxCareer, techStacks}]}'
```

추출 필드:
- `title` — 포지션명 (HTML 태그 포함될 수 있음 → `sed 's/<[^>]*>//g'` 또는 jq `gsub` 으로 strip)
- `companyName` — 회사명
- `locations[]` — 지역 (문자열 배열)
- `id` → URL: `https://www.jumpit.co.kr/position/{id}`
- `closedAt` — 마감일
- `minCareer` / `maxCareer` — 경력 (년)
- `techStacks[]` — 기술스택 (문자열 배열)

**클라이언트 사이드 필터링 필수**: 점핏 API의 키워드 매칭이 넓어서 무관한 공고가 섞임.
응답을 받은 뒤 아래 조건으로 필터링한다:
- 포지션명(HTML 제거 후)에 키워드가 포함되거나
- `techStacks[]`에 검색 키워드 관련 기술이 포함된 것만 표시
- 예) "iOS" 검색 시 → title 또는 techStacks에 iOS/Swift/SwiftUI/Objective-C/Xcode 포함된 것만

### 3. 링크드인 (linkedin.com)

링크드인은 JSON API가 없으므로 curl로 guest search HTML을 가져와 파싱한다.

```bash
curl -s "https://www.linkedin.com/jobs-guest/jobs/api/seeMoreJobPostings/search?keywords={키워드 URL인코딩}&location=South+Korea&start=0" \
  -H "User-Agent: Mozilla/5.0"
```

응답 HTML에서 추출 (grep/sed 활용):
- 포지션명: `base-search-card__title">` 태그 내 텍스트 (공백 trim)
- 회사명: `base-search-card__subtitle` 태그 내 `<a>` 텍스트 (공백 trim)
- 지역: `job-search-card__location">` 태그 내 텍스트 (공백 trim)
- URL: `href="(https://kr\.linkedin\.com/jobs/view/[^"]+)"` 패턴
- 게시일: `<time[^>]+datetime="([^"]+)"` — ISO 날짜 (예: `2026-03-11`)

**마감일 없음 주의**: 링크드인은 마감일 정보를 제공하지 않는다.
대신 게시일(`datetime`)을 기준으로 **30일 이내 게시된 공고만** 포함한다.
게시일은 "N일 전" 형태로 표시한다.

## 결과 출력 형식

```
## {키워드} 채용공고

원티드 {N}건 · 점핏 {M}건 · 링크드인 {L}건 발견

---

### [{회사명}] {포지션명}
- 인원수: {인원수} (원티드만, 점핏·링크드인은 미제공)
- 경력: {경력조건} (링크드인은 정보 없을 수 있음)
- 지역: {지역}
- 기술스택: {스택} (점핏만)
- 연봉: {연봉} (원티드만)
- 마감: {마감일 또는 "상시"} / 링크드인은 "{N}일 전 게시"
- 플랫폼: 원티드 / 점핏 / 링크드인
- 링크: [바로가기]({URL})

...
```

- 세 플랫폼 결과를 합쳐서 최대 20개까지 보여준다
- 원티드·점핏은 `due_time` / `closedAt` 기준으로 마감 공고 제외
- 링크드인은 게시일이 30일 초과된 공고 제외
- 동일 회사·포지션으로 보이는 중복은 하나만 표시한다

## 결과 제공 후 추가 제안

```
더 찾아볼까요?
- 특정 공고 상세 내용 보기 → "N번 공고 상세 보여줘"
- 경력/지역 조건 변경 → "3년 이상으로 다시 찾아줘"
- 기술스택으로 필터 → "Swift 스택인 곳만"
```
