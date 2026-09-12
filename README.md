# 기도 나무 (Prayer Tree)

중보기도 제목을 유형별로 분류하고, 각 제목의 진행 상황을 날짜별로 기록·확인할 수 있는 Flutter 앱입니다.

## 진행 현황 (2026-09-12 기준)

- **완료**: 카테고리 분류/관리, 기도 제목 CRUD, 상태 관리(기도 중/응답됨/보류), 진행 기록 타임라인(기도내용 → 기록 목록 → 기록 추가 폼 순서), 날짜별 캘린더 보기
- **웹 데모**: https://songmyungsik.github.io/prayer_tree/ — `master`에 푸시할 때마다 GitHub Actions가 자동으로 빌드·배포 (설치 없이 링크만으로 열람 가능)
- **저장소**: https://github.com/SongMyungsik/prayer_tree (공개)
- **다음 할 일**: 화면/기능을 조금 더 보완한 뒤 Android APK 빌드 진행 예정 (GitHub Release로 배포 예정)
- 그 이후 계획: 소그룹/교회 공동체가 함께 쓰는 형태로 확장 시 Firebase(Firestore + Auth) 연동 검토

## 실행 방법

```bash
flutter pub get
flutter run            # 연결된 기기/에뮬레이터에서 실행
flutter run -d windows # Windows 데스크톱에서 바로 확인 (개발용)
flutter run -d chrome  # 브라우저에서 확인 (sqflite_common_ffi_web로 IndexedDB에 저장됨)
```

## 주요 기능

- 기도 제목 카테고리 분류 (환우 / 수험생 / 취업 / 결혼 / 가정 / 기타, 자유롭게 추가·수정·삭제 가능)
- 기도 제목별 상태 관리 (기도 중 / 응답됨 / 보류)
- 기도 제목별 진행 기록(날짜 + 메모) 타임라인
- 날짜별 보기: 캘린더에서 날짜를 선택해 그날 기록된 기도 진행 상황을 확인
- 카테고리 관리 화면

## 기술 스택

- Flutter (Dart)
- sqflite / sqflite_common_ffi — 기기 로컬 SQLite 저장 (모바일: sqflite, 데스크톱: sqflite_common_ffi)
- table_calendar — 날짜별 보기 캘린더 UI

## 데이터 저장 방식

모든 데이터는 기기 로컬 SQLite 데이터베이스에 저장됩니다(서버 전송 없음). 앱을 삭제하면 데이터도 함께 삭제되니 주의하세요.

추후 소그룹/교회 공동체가 함께 쓰는 형태로 확장할 경우, Firebase(Firestore + Auth) 등을 연동하고 현재의 `lib/data/prayer_store.dart` 레이어를 서버 호출로 교체/확장하는 방식으로 발전시킬 수 있도록 화면과 데이터 모델을 분리해 두었습니다.

## 프로젝트 구조

```
lib/
  models/        # PrayerCategory, PrayerItem, ProgressUpdate, PrayerStatus
  data/          # DbHelper(SQLite 스키마), PrayerStore(상태 관리 + CRUD)
  screens/       # 목록 / 상세 / 날짜별 / 카테고리 관리 화면
  widgets/       # 공통 위젯(상태 배지, 카테고리 라벨, 입력 폼 바텀시트)
  theme/         # 라이트/다크 테마
```
