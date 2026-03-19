---
name: kotlin-clean-architecture
description: Kotlin/Android 클린 아키텍처 패턴 안내. feature-first 3계층(data/domain/presentation) 구조, Repository·UseCase·ViewModel 적용 시 사용.
---

# Kotlin 클린 아키텍처

## 계층 구조

```
feature_name/
├── data/           # DataSource, DTO, Repository 구현
├── domain/         # Entity, UseCase, Repository 인터페이스
└── presentation/   # ViewModel, UI (Compose/View)
```

### 의존성 방향
- **domain**은 data에 의존하지 않음
- **data**는 domain 인터페이스 구현
- **presentation**은 domain UseCase 주입

---

## Domain 계층

### Entity
순수 Kotlin data class. Android/외부 라이브러리 의존 없음.

```kotlin
data class User(
    val id: String,
    val name: String
)
```

### Repository 인터페이스
Data 계층이 구현.

```kotlin
interface UserRepository {
    suspend fun getUser(id: String): Result<User>
}
```

### UseCase
단일 비즈니스 흐름. `suspend` 함수.

```kotlin
class GetUserUseCase(
    private val repository: UserRepository
) {
    suspend operator fun invoke(id: String): Result<User> {
        return repository.getUser(id)
    }
}
```

---

## Data 계층

### DTO / Model
API/DB 모델. `@SerializedName`, `data class`.

```kotlin
data class UserDto(
    @SerializedName("id") val id: String,
    @SerializedName("name") val name: String
) {
    fun toEntity() = User(id = id, name = name)
}
```

### DataSource
API, Room, DataStore 등 원시 데이터 접근.

```kotlin
interface UserRemoteDataSource {
    suspend fun fetchUser(id: String): UserDto
}
```

### Repository 구현체
DataSource 사용, DTO → Entity 변환.

```kotlin
class UserRepositoryImpl(
    private val remote: UserRemoteDataSource
) : UserRepository {

    override suspend fun getUser(id: String): Result<User> = runCatching {
        remote.fetchUser(id).toEntity()
    }
}
```

---

## Presentation 계층

### ViewModel (MVVM)
UseCase 호출, `StateFlow`/`SharedFlow`로 상태 전달. `viewModelScope`.

```kotlin
class UserViewModel(
    private val getUserUseCase: GetUserUseCase
) : ViewModel() {

    private val _state = MutableStateFlow<UserState>(UserState.Loading)
    val state: StateFlow<UserState> = _state.asStateFlow()

    fun loadUser(id: String) {
        viewModelScope.launch {
            _state.value = UserState.Loading
            getUserUseCase(id)
                .onSuccess { _state.value = UserState.Success(it) }
                .onFailure { _state.value = UserState.Error(it) }
        }
    }
}
```

### UI (Compose)
ViewModel 주입, `collectAsState()`로 구독.

```kotlin
@Composable
fun UserScreen(
    viewModel: UserViewModel = hiltViewModel(),
    userId: String
) {
    val state by viewModel.state.collectAsState()
    LaunchedEffect(userId) { viewModel.loadUser(userId) }
    // ...
}
```

---

## 의존성 주입 (Hilt)

```kotlin
// Domain
@Module
@InstallIn(SingletonComponent::class)
object UserModule {
    @Provides
    @Singleton
    fun provideUserRepository(remote: UserRemoteDataSource): UserRepository =
        UserRepositoryImpl(remote)

    @Provides
    @Singleton
    fun provideGetUserUseCase(repository: UserRepository) =
        GetUserUseCase(repository)
}
```

---

## 네이밍

- 파일: `PascalCase.kt` (주요 클래스명과 동일)
- UseCase: `GetXxxUseCase`, `SaveXxxUseCase` — `operator fun invoke()` 권장
- Repository: `XxxRepository` (인터페이스), `XxxRepositoryImpl` (구현체)
- ViewModel: `XxxViewModel`
- State: `XxxState` (sealed class: Loading, Success, Error)
