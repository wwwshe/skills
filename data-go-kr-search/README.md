# data-go-kr-search

한국 공공데이터포털(data.go.kr) API/데이터셋 검색 Claude Code Skill.

공공데이터포털 카탈로그 검색 API를 직접 호출해 **실시간으로 공공 API 목록**을 가져옵니다.

## 설치

```bash
# 이 스킬만 설치
npx skills add https://github.com/wwwshe/skills/tree/main/data-go-kr-search

# 전체 스킬 한 번에 설치
npx skills add wwwshe/skills
```

## 사전 준비: 서비스키 발급

1. [data.go.kr](https://www.data.go.kr) 로그인
2. 마이페이지 > 인증키 발급 > **일반 인증키** 발급
3. `~/.claude/settings.json`에 환경변수 추가

```json
{
  "env": {
    "DATA_GO_KR_API_KEY": "발급받은키"
  }
}
```

## 사용법

Claude Code에서 자연어로 요청:

```
날씨 API 찾아줘
노인복지 관련 API 있어?
기상청 API 목록 알려줘
교통 공공데이터 뭐 있어?
대기오염 API 있나요?
```

또는 슬래시 커맨드:

```
/data-go-kr-search 날씨
```

## 검색 옵션

| 옵션 | 예시 |
|------|------|
| 키워드 | 날씨, 교통, 부동산, 노인복지 |
| 데이터 유형 | API(기본), 파일, 표준데이터 |
| 제공기관 | 기상청, 환경부, 서울특별시 |
| 정렬 | 정확도(기본), 조회순, 활용순, 최신순 |

## 출력 예시

```
## "날씨" 공공데이터 API 검색 결과

전체 88건 중 10건 표시 · 기준: 정확도순

### ⭐ 기상청_단기예보 조회서비스
- 기관: 기상청
- 유형: REST (API)
- 분류: 과학기술 > 과학기술연구
- 수정일: 2025-11-19
- 상세: [바로가기](https://www.data.go.kr/data/15084084/openapi.do)
```

> ⭐ 는 국가중점데이터를 나타냅니다.
