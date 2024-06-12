trivy-fs() {
    CURDIR="$(basename $(pwd))"
    OUTPUT_FILE="${1:-${CURDIR}-trivy.json}"
    trivy fs . --scanners license --license-full --format spdx-json > "${OUTPUT_FILE}"

    echo
    echo "wrote output to ${OUTPUT_FILE}"
    echo "NOTE: pip reqs require pinning to scan; try \`pip freeze\` if needed"
}

trivy-image() {
    IMAGE="${1:?requires image arg}"
    OUTPUT_FILE="${IMAGE}-trivy.json"
    trivy image "${IMAGE}" --scanners license --license-full --format spdx-json > "${OUTPUT_FILE}"

    echo "wrote output to ${OUTPUT_FILE}"
}
