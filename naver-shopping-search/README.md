# naver-shopping-search

네이버 쇼핑 **공식 검색 Open API**로 상품을 조회하는 Claude Code / 에이전트 스킬입니다.

## 설치

```bash
# 이 스킬만 설치
npx skills add https://github.com/wwwshe/skills/tree/main/naver-shopping-search

# 전체 스킬 한 번에 설치
npx skills add wwwshe/skills
```

## 사전 준비: 네이버 개발자 앱

1. [네이버 개발자 센터](https://developers.naver.com/apps)에서 애플리케이션 등록
2. **API 설정**에서 **검색** 사용 (쇼핑 검색 포함)
3. 환경변수 추가 (아래 중 하나)

### Claude Code

파일: `~/.claude/settings.json`

```json
{
  "env": {
    "NAVER_CLIENT_ID": "발급_Client_ID",
    "NAVER_CLIENT_SECRET": "발급_Client_Secret"
  }
}
```

저장 후 **Claude Code를 재시작**합니다.

### Cursor

통합 터미널에 넘길 환경변수로 설정합니다. **사용자** `settings.json`을 열어 OS에 맞는 키를 씁니다.

| OS | settings.json 경로 | 환경변수 블록 키 |
|----|---------------------|------------------|
| macOS | `~/Library/Application Support/Cursor/User/settings.json` | `terminal.integrated.env.osx` |
| Windows | `%APPDATA%\Cursor\User\settings.json` | `terminal.integrated.env.windows` |
| Linux | `~/.config/Cursor/User/settings.json` | `terminal.integrated.env.linux` |

예시 (macOS):

```json
{
  "terminal.integrated.env.osx": {
    "NAVER_CLIENT_ID": "발급_Client_ID",
    "NAVER_CLIENT_SECRET": "발급_Client_Secret"
  }
}
```

**Cursor를 재시작**한 뒤 **새 터미널**을 열어야 적용됩니다. 확인: `echo $NAVER_CLIENT_ID`

### 에이전트 셸만 (`~/.zshenv` / `~/.zshrc`)

에이전트가 **통합 터미널 설정을 상속하지 않는** 경우, zsh이 실제로 읽는 파일에 `export`를 넣어야 할 수 있습니다.

```bash
export NAVER_CLIENT_ID='발급_Client_ID'
export NAVER_CLIENT_SECRET='발급_Client_Secret'
```

- 비대화형·스크립트에서도 읽히게 하려면 **`~/.zshenv`**에 두는 경우가 많고, **`~/.zshrc`**는 대화형 위주라 에이전트에 안 잡힐 수 있습니다.
- Bash를 쓰면 `~/.bash_profile`, `~/.bashrc` 등 **해당 셸의 규칙**을 따릅니다.
- 설정 후 **에이전트가 실행하는 Shell**에서 길이만 확인합니다(값 노출 방지):

```bash
echo ${#NAVER_CLIENT_ID}
```

`0`이 아니면 변수가 설정된 것입니다. 여전히 `0`이면 에이전트가 다른 셸/다른 홈을 쓰는지 확인합니다.

### 대화에서만 쓰기

에이전트에게 `"NAVER_CLIENT_ID는 …, 시크릿은 …"`처럼 알려 주면 해당 대화에서만 호출에 사용할 수 있습니다. (파일에 남기지 않을 때)

## 사용법

자연어 예시:

```
네이버쇼핑에서 무선 이어폰 찾아줘
노트북 가격 낮은 순으로 쇼핑 검색
아이폰 케이스 20개까지 네이버 쇼핑에서 검색해줘
키보드 찾아줘 → (에이전트가 정렬을 물어볼 수 있음) → 3번 / 가격 싼 순
```

정렬·필터는 한 문장에 넣거나, 질문에 번호·자연어로 답하면 된다. **평점순**은 공식 쇼핑 검색 API에 없다(`SKILL.md` 참고).

검색 결과의 **썸네일**은 API `image` URL을 마크다운 `![alt](url)`로 넣어 표시한다(`SKILL.md`「썸네일」절). "썸네일 빼고" 요청 시 생략.

슬래시 커맨드 예시:

```
/naver-shopping-search 갤럭시 탭
```

## 옵션

| 항목 | 설명 |
|------|------|
| 검색어 | 필수 |
| 정렬 | API는 `sim`(기본) 또는 `date`(최신). 가격 오름/내림은 **`asc`/`dsc` 호출 없이** 수신 목록을 에이전트가 `lprice`로 정렬 (`SKILL.md` 참고) |
| 표시 건수 | 1~100 (기본 10) |
| 필터 | 네이버페이만, 중고/렌탈/해외직구 제외 등 (SKILL.md 참고) |
| 대화형 | 검색어만 주어지면 기본 정렬로 검색하거나, 정렬·필터를 한 번 질문할 수 있음 (`SKILL.md`「사용자와 조건 맞추기」) |
| 평점순 | **미지원** (API `sort`·응답 필드에 없음) |
| 결과만 좁히기 | 가격·브랜드·몰명 등 **이미 받은 `items`에 `jq`로 후처리** 가능. 전체 검색 건수 기준 필터는 한 페이지(최대 100건) 한계 있음 (`SKILL.md`「검색 결과 후처리」) |

## 문서

- [쇼핑 검색 API 레퍼런스](https://developers.naver.com/docs/serviceapi/search/shopping/shopping.md)
