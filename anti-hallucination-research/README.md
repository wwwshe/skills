# anti-hallucination-research

웹 검색/조사형 AI 에이전트에서 **할루시네이션(환각)을 줄이기 위한 검증 중심 스킬**입니다.

핵심 원칙:
- 추측 단정 금지
- 근거 없는 주장 금지
- 불확실성 라벨링(`확실하지 않음`, `검증 필요`, `시점 확인 필요`)
- 사실 / 추정 / 의견 분리

## 설치

```bash
# 이 스킬만 설치
npx skills add https://github.com/wwwshe/skills/tree/main/anti-hallucination-research

# 전체 스킬 한 번에 설치
npx skills add wwwshe/skills
```

## 언제 쓰나

다음과 같은 요청에서 사용:

```
최신 정보 조사해줘
근거 있는 리서치로 정리해줘
이 라이브러리 진짜 존재해?
공식 문서 기준으로 사실 확인해줘
```

## 스킬이 강제하는 동작

1. 질문을 검증 단위로 분해
2. 최신 정보 검색 우선
3. 공식 문서/실제 사례 중심으로 근거 수집
4. 주장-근거 매핑
5. 불확실성 라벨링
6. 자기모순 점검 후 답변

## 출력 형식

응답을 아래 구조로 정리합니다.

- 결론
- 사실 (근거 있음)
- 추정 (근거 제한)
- 의견 (권장안)
- 충돌/리스크

## 포함 파일

- `SKILL.md`: 스킬 본문
- `TEST_REPORT.md`: 정적/시나리오 테스트 결과

## 참고 문서

- [Anthropic - Reduce hallucinations](https://docs.anthropic.com/en/docs/minimizing-hallucinations)
- [OpenAI - Web search guide](https://platform.openai.com/docs/guides/tools-web-search)
- [OpenAI - Citation formatting](https://developers.openai.com/api/docs/guides/citation-formatting)
