#!/usr/bin/env bash
# Node tests for the JavaScript libraries; QML tests need Qt 6's qmltestrunner and are skipped without it.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== node: Contrast.js, I18n.js"
node --test tests/*.test.mjs

qml_runner=""
for c in qmltestrunner6 /usr/lib/qt6/bin/qmltestrunner /usr/lib64/qt6/bin/qmltestrunner; do
  if command -v "$c" >/dev/null; then qml_runner="$c"; break; fi
done
if [ -n "$qml_runner" ]; then
  echo "== qml: components against a stub of the shell"
  QT_QPA_PLATFORM=offscreen QML_IMPORT_PATH="$PWD/tests/stubs" "$qml_runner" -import tests/stubs -input tests/tst_kit.qml
else
  echo "== qml: skipped (Qt 6 qmltestrunner not installed)"
fi
echo "all suites passed"
