#
# Beryllium Auto Patch System
#
# Applies the patches under device/xiaomi/beryllium/patches to their
# respective source repositories at lunch time. Add a new entry to the
# PATCHES array below as "<patch file>|<target dir relative to source root>".
#
apply_beryllium_patches() {
    # Colors
    local CYAN="\033[1;36m"
    local BLUE="\033[1;34m"
    local GREEN="\033[1;32m"
    local YELLOW="\033[1;33m"
    local RED="\033[1;31m"
    local RESET="\033[0m"

    echo
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}🚀  Beryllium Auto Patch System${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    #
    # Detect Android source root
    #
    if [ -z "${ANDROID_BUILD_TOP}" ]; then
        ANDROID_BUILD_TOP="$(pwd)"
        while [ "${ANDROID_BUILD_TOP}" != "/" ] && [ ! -d "${ANDROID_BUILD_TOP}/build" ]; do
            ANDROID_BUILD_TOP="$(dirname "${ANDROID_BUILD_TOP}")"
        done
    fi

    if [ ! -d "${ANDROID_BUILD_TOP}/build" ]; then
        echo -e "❌ ${RED}Không tìm thấy mã nguồn Android.${RESET}"
        return 1
    fi

    local PATCH_DIR="${ANDROID_BUILD_TOP}/device/xiaomi/beryllium/patches"

    echo -e "📂 ${BLUE}Mã nguồn${RESET}      : ${ANDROID_BUILD_TOP}"

    #
    # List of patches to apply: "<patch file>|<target dir>"
    #
    local PATCHES=(
        "disable_hw_overlays.patch|frameworks/native"
        "preload_statslog.patch|frameworks/base"
    )

    local entry PATCH_FILE TARGET_REL TARGET_DIR
    for entry in "${PATCHES[@]}"; do
        PATCH_FILE="${PATCH_DIR}/${entry%%|*}"
        TARGET_REL="${entry##*|}"
        TARGET_DIR="${ANDROID_BUILD_TOP}/${TARGET_REL}"

        echo
        echo -e "📦 ${BLUE}Patch${RESET}        : $(basename "${PATCH_FILE}") → ${TARGET_REL}"

        if [ ! -f "${PATCH_FILE}" ]; then
            echo -e "❌ ${RED}Không tìm thấy file patch.${RESET}"
            continue
        fi

        if [ ! -d "${TARGET_DIR}/.git" ]; then
            echo -e "❌ ${RED}${TARGET_REL} không phải Git repository.${RESET}"
            continue
        fi

        echo -e "⚙️  ${CYAN}Đang áp dụng patch...${RESET}"

        if git -C "${TARGET_DIR}" apply --check "${PATCH_FILE}" >/dev/null 2>&1; then
            if git -C "${TARGET_DIR}" apply --whitespace=fix "${PATCH_FILE}"; then
                echo -e "✅ ${GREEN}Đã áp dụng patch thành công.${RESET}"
            else
                echo -e "❌ ${RED}Không thể áp dụng patch.${RESET}"
            fi
        else
            echo -e "⚠️  ${YELLOW}Patch đã được áp dụng hoặc không còn tương thích với source hiện tại.${RESET}"
        fi
    done

    echo
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "🎉 ${GREEN}Hoàn tất. Sẵn sàng build ROM!${RESET}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo
}

apply_beryllium_patches
