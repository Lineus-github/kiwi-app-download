#!/bin/bash
# 새 버전을 다운로드 페이지에 올린다. 앱은 version.json 을 읽어 «새 버전이 있어요» 창을 띄운다.
#
#   bash publish.sh android <빌드 번호> <APK 경로> ["이번 버전 안내"]
#   bash publish.sh ios     <빌드 번호> <TestFlight 공개 링크> ["이번 버전 안내"]
#
# android: APK 를 이 저장소의 Release(android-<번호>)에 올리고 그 주소를 version.json 에 적는다
# ios: 빌드를 TestFlight 외부 그룹에 넣은 뒤 부른다. 링크는 그룹마다 고정이라 번호만 바뀐다
# 빌드 번호는 앱의 KIWI_BUILD_NUMBER 와 같아야 한다(앱이 이 번호로 새 버전을 판정한다)
set -euo pipefail
cd "$(dirname "$0")"
REPO=Lineus-github/kiwi-app-download
platform=${1:?ios 또는 android}; build=${2:?빌드 번호}; target=${3:?APK 경로 또는 TestFlight 링크}; notes=${4:-}
[[ $build =~ ^[1-9][0-9]*$ ]] || { echo "빌드 번호는 1 이상의 정수"; exit 1; }

case $platform in
  android)
    [ -f "$target" ] || { echo "APK 가 없다: $target"; exit 1; }
    name="kiwi-test-$build.apk"
    cp "$target" "/tmp/$name"
    gh release create "android-$build" "/tmp/$name" -R "$REPO" --title "안드로이드 $build" --notes "${notes:-안드로이드 $build}"
    url="https://github.com/$REPO/releases/download/android-$build/$name"
    ;;
  ios)
    [[ $target == https://testflight.apple.com/join/* ]] || { echo "TestFlight 공개 링크가 아니다: $target"; exit 1; }
    url=$target
    ;;
  *) echo "ios 또는 android"; exit 1 ;;
esac

python3 - "$platform" "$build" "$url" "$notes" <<'EOF'
import json, sys
platform, build, url, notes = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4]
m = json.load(open('version.json'))
m[platform] = {"build": build, "version": f"1.0.0 ({build})", "url": url}
if notes:
    m["notes"] = notes
json.dump(m, open('version.json', 'w'), ensure_ascii=False, indent=2)
open('version.json', 'a').write('\n')
EOF
git add version.json
git commit -q -m "$platform $build 올림"
git push -q origin main
echo "올림: $platform $build → $url"
