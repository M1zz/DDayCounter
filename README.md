# 음력세기 (DDayCounter)

여러 개의 디데이(D-day)를 **양력·음력**으로 관리하고, **홈 화면 위젯**과 **잠금 화면 위젯**에서 남은 일수를 확인할 수 있는 iOS 앱입니다.

- SwiftUI + WidgetKit
- 최소 지원: **iOS 17.0**
- 앱 ↔ 위젯 데이터 공유: **App Group** (`group.com.example.DDayCounter`)

## 지원 · 개인정보 처리방침

- 🛟 지원(Support): https://m1zz.github.io/DDayCounter/support.html
- 🔒 개인정보 처리방침: https://m1zz.github.io/DDayCounter/privacy.html

> 위 페이지는 저장소의 [`docs/`](docs/) 폴더에서 서빙됩니다.
> GitHub 저장소 **Settings → Pages → Source** 를 `main` 브랜치 `/docs` 폴더로 설정하면 활성화됩니다.

## 폴더 구조

```
DDayCounter/
├─ DDayCounter.xcodeproj          # Xcode 프로젝트
├─ DDayCounter/                   # 메인 앱 타깃
│  ├─ DDayCounterApp.swift        # 앱 진입점
│  ├─ Views/
│  │  ├─ ContentView.swift        # 디데이 목록
│  │  └─ DDayEditorView.swift     # 추가/편집 화면
│  ├─ Shared/                     # 앱·위젯 공용 코드
│  │  ├─ DDayItem.swift           # 모델 + 날짜 계산
│  │  ├─ DDayStore.swift          # App Group 저장소
│  │  └─ Color+Hex.swift          # 색상 유틸
│  ├─ Assets.xcassets
│  ├─ Info.plist
│  └─ DDayCounter.entitlements    # App Group
└─ DDayWidget/                    # 위젯 익스텐션 타깃
   ├─ DDayWidgetBundle.swift      # 홈 + 잠금 위젯 등록
   ├─ DDayProvider.swift          # 타임라인 (자정마다 갱신)
   ├─ DDayWidgetViews.swift       # 위젯 레이아웃
   ├─ DDayConfigurationIntent.swift # 위젯에서 디데이 선택
   ├─ Info.plist
   └─ DDayWidget.entitlements     # App Group
```

## 처음 실행하는 방법

1. **Xcode 15.2 이상**에서 `DDayCounter.xcodeproj` 를 엽니다.
2. 두 타깃(`DDayCounter`, `DDayWidgetExtension`) 각각에서
   **Signing & Capabilities → Team** 을 본인 개발자 계정으로 설정합니다.
3. 두 타깃 모두 **App Groups** capability 에 `group.com.example.DDayCounter` 가
   체크되어 있는지 확인합니다. (이미 entitlements 에 포함되어 있습니다.)
   - 번들 ID를 바꾸고 싶다면, App Group ID도 함께 바꾸고
     `DDayStore.swift` 의 `AppGroup.identifier` 값을 동일하게 수정하세요.
4. 실행할 기기/시뮬레이터(iOS 17+)를 선택하고 ⌘R 로 실행합니다.

## 사용법

- 앱에서 **＋** 로 디데이를 추가합니다. 제목, 날짜, 카운트 방식(디데이 / 누적일),
  아이콘, 색상, 매년 반복 여부를 지정할 수 있습니다.
- 목록에서 항목을 왼쪽으로 밀면 **위젯에 고정(📌)** 할 수 있습니다.
- 홈 화면 빈 곳을 길게 눌러 위젯을 추가하고, 위젯을 길게 눌러
  **"디데이 선택"** 에서 표시할 항목을 바꿀 수 있습니다.
- 잠금 화면 편집에서 원형/직사각형/인라인 위젯을 추가할 수 있습니다.

## 참고

- 위젯의 카운트는 매일 자정에 자동으로 갱신됩니다(타임라인 엔트리 사전 생성).
- 데이터는 기기 내 App Group `UserDefaults` 에 저장됩니다(서버 없음).
