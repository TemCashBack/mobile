#!/bin/sh
# Generate dSYMs for Firebase/gRPC binary frameworks (SPM) so Xcode 16 can upload symbols.

if [ -z "${DWARF_DSYM_FOLDER_PATH}" ] || [ ! -d "${DWARF_DSYM_FOLDER_PATH}" ]; then
  exit 0
fi

FRAMEWORKS_DIR="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
if [ ! -d "${FRAMEWORKS_DIR}" ]; then
  exit 0
fi

generate_dsym() {
  framework_name="$1"
  binary="${FRAMEWORKS_DIR}/${framework_name}.framework/${framework_name}"
  output="${DWARF_DSYM_FOLDER_PATH}/${framework_name}.framework.dSYM"

  if [ ! -f "${binary}" ]; then
    return 0
  fi

  if [ -d "${output}" ]; then
    return 0
  fi

  echo "note: generating dSYM for ${framework_name}.framework"
  dsymutil "${binary}" -o "${output}" >/dev/null 2>&1 || true
}

for framework in FirebaseFirestoreInternal absl grpc grpcpp openssl_grpc; do
  generate_dsym "${framework}"
done

SPM_ARTIFACTS="${BUILD_DIR%/Build/*}/SourcePackages/artifacts"
if [ -d "${SPM_ARTIFACTS}" ]; then
  find "${SPM_ARTIFACTS}" -type d -name "*.dSYM" 2>/dev/null | while IFS= read -r dsym; do
    name=$(basename "${dsym}")
    dest="${DWARF_DSYM_FOLDER_PATH}/${name}"
    if [ ! -d "${dest}" ]; then
      echo "note: copying ${name} from SPM artifacts"
      ditto "${dsym}" "${dest}"
    fi
  done
fi

if [ -n "${PODS_ROOT}" ] && [ -d "${PODS_ROOT}" ]; then
  find "${PODS_ROOT}" -type d -name "*.dSYM" 2>/dev/null | while IFS= read -r dsym; do
    name=$(basename "${dsym}")
    dest="${DWARF_DSYM_FOLDER_PATH}/${name}"
    if [ ! -d "${dest}" ]; then
      echo "note: copying ${name} from Pods"
      ditto "${dsym}" "${dest}"
    fi
  done
fi

exit 0
