# job-search-kr

한국 채용공고 검색 Claude Code Skill.

원티드·점핏 API를 직접 호출해 **실시간 활성 공고**만 가져옵니다.

## 설치

```bash
# 이 스킬만 설치
npx skills add https://github.com/wwwshe/skills/tree/main/job-posting-search-kr

# 전체 스킬 한 번에 설치
npx skills add wwwshe/skills
```

## 사용법

Claude Code에서 자연어로 요청:

```
iOS 개발자 채용 찾아줘
백엔드 신입 공고 알려줘
프론트엔드 서울 3년 이상 채용
데이터 엔지니어 공고 보여줘
```

또는 슬래시 커맨드:

```
/job-search-kr iOS 개발자 서울
```

## 검색 플랫폼

| 플랫폼 | 특징 |
|--------|------|
| [원티드](https://www.wanted.co.kr) | IT/스타트업 강세 |
| [점핏](https://www.jumpit.co.kr) | 개발자 특화, 기술스택 필터 |
| [링크드인](https://www.linkedin.com/jobs) | 외국계·대기업 강세, 게시일 기준 30일 이내 공고만 표시 |

## 필터 옵션

- **경력**: 신입, 1년, 3년, 5년, 전체
- **지역**: 서울, 경기, 부산, 전체
- **키워드**: 직무명, 기술스택 등
