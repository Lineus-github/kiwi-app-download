# KIWI 앱 사내 다운로드

- 페이지: https://lineus-github.github.io/kiwi-app-download/
- 앱이 읽는 버전 파일: https://lineus-github.github.io/kiwi-app-download/version.json
  (앱 빌드 때 `KIWI_UPDATE_MANIFEST_URL` 로 넣는다. 앱 코드는 `kiwi-mobile-app` 의 `src/lib/app-update.ts`)
- 새 버전 올리기: `publish.sh` 주석 참고
- 비밀 값(서명 키·비밀번호)은 여기에 두지 않는다. 이 저장소는 공개다
