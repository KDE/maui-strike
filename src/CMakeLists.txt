remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY -DQT_NO_URL_CAST_FROM_STRING)

set(strike_SRCS
    main.cpp
    strike.h
    controllers/cmakedata.cpp
    controllers/cmakeapi.cpp
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

qt_add_resources(strike_ASSETS
    assets/img_assets.qrc)

qt_add_executable(${PROJECT_NAME}
    ${strike_SRCS}
    ${strike_ASSETS})

qt_add_qml_module(${PROJECT_NAME} URI app.maui.strike
    NO_PLUGIN
    QML_FILES
    main.qml
    views/widgets/SettingsDialog.qml
    views/PlacesSidebar.qml
    views/editor/EditorView.qml
    views/editor/Editor.qml
    views/editor/EditorLayout.qml
    views/widgets/BuildBar.qml
    views/widgets/OutputPanel.qml
    views/widgets/ProjectConfigDialog.qml
    views/widgets/GitPanel.qml
    views/widgets/BuildOutputPanel.qml)

target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    MauiKit4
    MauiKit4::FileBrowsing
    MauiKit4::Terminal
    MauiKit4::TextEditor
    Qt6::Quick
    Qt6::Widgets
    Qt6::Qml
    KF6::CoreAddons
    KF6::I18n)

install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
