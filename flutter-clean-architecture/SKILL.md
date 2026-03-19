---
name: flutter-clean-architecture
description: Flutter 클린 아키텍처 패턴 안내. feature-first 3계층(data/domain/presentation) 구조, Repository·UseCase·Riverpod 적용 시 사용.
---

# Flutter 클린 아키텍처

## 계층 구조

```
lib/features/feature_name/
├── data/           # 데이터 소스, 모델, 리포지토리 구현
├── domain/         # 비즈니스 로직, 엔티티, 유스케이스/서비스
└── presentation/   # UI, Riverpod providers, 화면
```

### 의존성 방향
- **domain** ← data (domain은 data에 의존하지 않음)
- **presentation** ← domain (선택: presentation → data 직접 접근 가능, 단 domain은 건너뛰지 않음)

---

## data 계층

### datasources/
API, DB, SharedPreferences 등 **원시 데이터 소스**.

```dart
/// API 호출, 로컬 DB 접근 등
abstract class SomeDatasource {
  Future<ApiResponse> fetch();
}
```

### models/
API/DTO 모델. JSON 직렬화, freezed 등 사용 가능.

### repositories/
데이터 소스를 조합·추상화. **Repository 구현체**.

```dart
/// data/repositories/some_repository.dart
class SomeRepository {
  SomeRepository(this._client);

  final SomeApiClient _client;

  Future<SomeOut> getData(SomeIn input) async {
    return await _client.fetch(input);
  }
}

// Provider에서 주입
final someRepositoryProvider = Provider<SomeRepository>((ref) {
  final client = ref.watch(someApiClientProvider);
  return SomeRepository(client);
});
```

---

## domain 계층

### entities/
순수 Dart 객체. API 모델과 분리할 수 있으나, 단순하면 API 모델 재사용 가능.

### use_cases/ 또는 service
비즈니스 로직. Repository 호출, 에러 변환, 플로우 제어.

```dart
/// domain/some_service.dart
class SomeService {
  SomeService({SomeRepository? repo}) : _repo = repo ?? SomeRepository();

  final SomeRepository _repo;

  Future<void> doSomething(SomeInput input) async {
    final out = await _repo.getData(input);
    // 저장, 토큰 처리 등 비즈니스 로직
  }
}
```

### 원칙
- domain은 **Flutter/UI에 의존하지 않음**
- `Navigator`, `BuildContext` 직접 사용 금지
- 의존성 주입: 생성자로 `Repository`, `Datasource` 주입

---

## presentation 계층

### providers/
Riverpod Provider 정의. Service/Repository 인스턴스 생성·노출.

```dart
/// presentation/providers/some_providers.dart
final someServiceProvider = Provider<SomeService>((ref) => SomeService());

final someStateProvider = FutureProvider.autoDispose<SomeState>((ref) async {
  final service = ref.watch(someServiceProvider);
  return service.fetchState();
});
```

### screens/ 또는 pages/
`ConsumerWidget` / `ConsumerStatefulWidget`로 UI. `ref.watch(provider)`로 상태 구독.

```dart
class SomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(someStateProvider);
    return async.when(
      data: (data) => _buildContent(data),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('에러: $e'),
    );
  }
}
```

---

## 새 feature 추가 체크리스트

1. **data**: `datasources/`, `models/`, `repositories/` 필요 시 생성
2. **domain**: `entities/`, `use_cases/` 또는 `service.dart` 추가
3. **presentation**: `providers/`, `screens/` 추가
4. Provider에서 Service/Repository를 생성하고, 화면에서 `ref.watch`로 구독
5. 화면에서 직접 Repository 호출 지양 → domain Service 경유

---

## 폴더 규모별 선택

| 규모 | domain 구조 |
|------|-------------|
| 소규모 | `service.dart` 하나로 UseCase 역할 통합 |
| 중규모 | `use_cases/` 폴더에 작업별 UseCase 클래스 분리 |
| 대규모 | UseCase 인터페이스 + 구현체, Repository 인터페이스 분리 |

---

## 네이밍

- 파일: `snake_case.dart`
- 클래스: `PascalCase`
- Repository: `XxxRepository`
- Service/UseCase: `XxxService` 또는 `GetXxxUseCase`
- Provider: `xxxProvider`, `xxxStateProvider`, `xxxNotifierProvider`
