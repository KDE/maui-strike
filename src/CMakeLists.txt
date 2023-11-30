set(strike_SRCS
    main.cpp
    strike.h
    controllers/cmakedata.cpp
    controllers/cmakeapi.cpp
    models/fonts.cpp
    models/cmakeprojectsmodel.cpp
    models/cmaketargetsmodel.cpp
    models/sourcesmodel.cpp

    controllers/cmakeproject.cpp
    controllers/cmakeprojecttarget.cpp
    controllers/projectmanager.cpp
    controllers/processmanager.cpp
    controllers/cmakeproject.cpp
    controllers/process.cpp
    controllers/projectpreferences.cpp
    controllers/processes/configureprocess.cpp
    controllers/cmakeprojectmanager.cpp
    controllers/git/gitprocess.cpp
    controllers/git/cloneprocess.cpp)

set(strike_ASSETS
    assets/img_assets.qrc)

if(QUICK_COMPILER)
    qtquick_compiler_add_resources(strike_QML_QRC qml.qrc)
else()
    qt5_add_resources(strike_QML_QRC qml.qrc)
endif()

add_executable(${PROJECT_NAME}
    ${strike_SRCS}
    ${strike_QML_QRC}
    ${strike_ASSETS})

target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    MauiKit3
    MauiKit3::FileBrowsing
    MauiKit3::Terminal
    MauiKit3::TextEditor
    Qt5::Quick
    Qt5::Widgets
    Qt5::Qml
    KF5::CoreAddons
    KF5::I18n)

install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
