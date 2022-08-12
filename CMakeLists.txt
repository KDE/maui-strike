# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

cmake_minimum_required(VERSION 3.16)

set(STRIKE_VERSION 1.0.0)
project(strike VERSION ${STRIKE_VERSION})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(REQUIRED_QT_VERSION 5.14.0)
set(REQUIRED_KF5_VERSION 5.60)

option(QUICK_COMPILER "Use QtQuick compiler to improve performance" TRUE)

find_package(ECM ${REQUIRED_KF5_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Qml Quick Widgets)
find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS I18n CoreAddons)

find_package(MauiKit REQUIRED)
find_package(MauiKit REQUIRED COMPONENTS FileBrowsing)

if(QUICK_COMPILER)
    find_package(Qt5QuickCompiler)
    set_package_properties(Qt5QuickCompiler PROPERTIES
        DESCRIPTION "Compile QML at build time"
        TYPE OPTIONAL
        )
endif()

include(KDEInstallDirs)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(ECMAddAppIcon)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(ECMSetupVersion)
include(ECMSourceVersionControl)
include(FeatureSummary)

if(${ECM_SOURCE_UNDER_VERSION_CONTROL})
    execute_process(
        COMMAND git rev-parse --abbrev-ref HEAD
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )

    # Get the latest abbreviated commit hash of the working branch
    execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )

    add_definitions(-DGIT_COMMIT_HASH="${GIT_COMMIT_HASH}")
    add_definitions(-DGIT_BRANCH="${GIT_BRANCH}")

else()
    add_definitions(-DGIT_COMMIT_HASH="${STRIKE_VERSION}")
    add_definitions(-DGIT_BRANCH="Stable")
endif()

ecm_setup_version(${STRIKE_VERSION}
    VARIABLE_PREFIX STRIKE
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/strike_version.h"
    )

add_subdirectory(src)

install(FILES org.kde.strike.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
install(FILES org.kde.strike.metainfo.xml DESTINATION ${KDE_INSTALL_METAINFODIR})
install(FILES src/assets/strike.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
