---
name: data-go-kr-search
description: 한국 공공데이터포털(data.go.kr) API/데이터셋 검색 스킬. 공공데이터나 공공 API를 찾거나 존재 여부를 묻는 요청에 활성화. "~API 찾아줘", "~공공데이터 있어?", "~관련 API 뭐 있어?" 같은 패턴.
argument-hint: "[검색키워드] [데이터타입?] [기관명?]"
---

# 공공데이터포털 검색 (data.go.kr)

사용자가 공공데이터포털 API/데이터셋 검색을 요청하면 `api.odcloud.kr` 카탈로그 검색 API를 호출해 결과를 보여준다.

## 사전 준비: 서비스키 확인

아래 순서로 serviceKey를 확인한다:

1. 환경변수 `DATA_GO_KR_API_KEY` 확인
2. 없으면 사용자에게 요청:

```
data.go.kr 검색 API는 서비스키가 필요합니다.

1. https://www.data.go.kr 로그인
2. 마이페이지 > 인증키 발급 > 일반 인증키(공공데이터포털 카탈로그 검색용)
3. 발급된 키를 아래 방법 중 하나로 설정해 주세요.

[방법 A] ~/.claude/settings.json 에 환경변수 추가 (권장)
  "env": {
    "DATA_GO_KR_API_KEY": "발급받은키"
  }
  → 설정 후 Claude Code를 재시작하면 자동으로 적용됩니다.

[방법 B] 대화 중 직접 전달
  "키는 abc123이야" 처럼 알려주시면 해당 대화에서만 사용합니다.
```

## 입력 파싱

`$ARGUMENTS` 또는 사용자 메시지에서 추출:

| 항목 | 예시 | 기본값 |
|------|------|--------|
| 검색어 | 날씨, 교통, 부동산, 의료 | (필수) |
| 데이터타입 | API, FILE, STD | `["API"]` |
| 기관명 | 기상청, 환경부, 서울특별시 | 전체 |
| 정렬 | 정확도(기본), 조회순, 활용순, 최신순 | `_score` |

"API 찾아줘" 또는 키워드만 있으면 `dataType: ["API"]`로 검색한다.
"데이터셋", "파일" 언급 시 `dataType: ["FILE"]`을 추가한다.

## API 호출

**Bash tool + curl + jq 로 호출한다.**

### 엔드포인트

```
POST https://api.odcloud.kr/api/GetSearchDataList/v1/searchData?serviceKey={서비스키}
Content-Type: application/json
```

### 목록 검색

```bash
curl -s --tlsv1.2 -X POST \
  "https://api.odcloud.kr/api/GetSearchDataList/v1/searchData?serviceKey={SERVICE_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "page": 1,
    "size": 10,
    "keyword": "{검색어}",
    "dataType": ["API"],
    "sort": "_score",
    "sortOrder": "desc"
  }' | jq '{
    total: .result.sum,
    count: .result.dataCount,
    items: [.result.data[] | {
      name: .dataName,
      description: .dataDescription,
      organization: .organization,
      serviceType: .dataProvisionType,
      dataType: .dataType,
      category1: .firstBrmName,
      category2: .secondBrmName,
      keywords: .keywords,
      updateDate: .updateDate,
      url: .detailPageUrl,
      coreData: .coreData,
      corpApi: .corpApi
    }]
  }'
```

기관명 필터가 있으면 `"organizations": ["{기관명}"]`을 body에 추가한다.

### 정렬 기준 매핑

| 사용자 표현 | sort 값 |
|------------|---------|
| 정확도(기본) | `_score` |
| 조회순 | `inqireCo` |
| 활용순 | `reqCo` |
| 최신순 | `updtDt` |

## 결과 출력 형식

```
## "{검색어}" 공공데이터 검색 결과

전체 {total}건 중 {count}건 표시 · 기준: {정렬기준}

---

### 1. {데이터명}
- 기관: {제공기관}
- 유형: {서비스유형} ({데이터타입})
- 분류: {1단계분류} > {2단계분류}
- 키워드: {키워드 목록}
- 수정일: {수정일}
- 국가중점: {여부} / 기업전용: {여부}
- 상세: [바로가기]({detailPageUrl})

{설명 1~2줄}

---

### 2. ...
```

- 최대 10건 표시
- `coreData: true`이면 "⭐ 국가중점데이터" 표시
- `corpApi: true`이면 "(기업전용)" 표시
- `detailPageUrl`이 있으면 반드시 링크로 제공

## 결과 제공 후 추가 제안

```
더 찾아볼까요?
- 조회순/활용순으로 다시 정렬 → "활용 많은 순으로 보여줘"
- 기관 필터 → "기상청 API만 보여줘"
- 더 많은 결과 → "더 보여줘" (page 2)
- 파일 데이터도 포함 → "파일 데이터도 포함해서 찾아줘"
```
