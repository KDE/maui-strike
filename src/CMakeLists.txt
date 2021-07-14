set(strike_SRCS
    main.cpp
    strike.h
    models/fonts.cpp
    models/cmakeprojectsmodel.cpp
    controllers/cmakeprojectmanager.cpp
    controllers/projectmanager.cpp
    controllers/processmanager.cpp
    controllers/cmaketarget.cpp
    controllers/cmakeapi.cpp
    controllers/cmakeproject.cpp
    controllers/process.cpp
    controllers/projectpreferences.cpp
    controllers/processes/configureprocess.cpp
    )


set(strike_ASSETS
    qml.qrc
    assets/img_assets.qrc
    )

add_executable(${PROJECT_NAME}
    ${strike_SRCS}
    ${strike_ASSETS})

target_link_libraries(${PROJECT_NAME} KF5::ConfigCore KF5::KIOCore KF5::KIOFileWidgets KF5::KIONTLM KF5::KIOWidgets)

target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME} MauiKit MauiKit::FileBrowsing Qt5::Sql Qt5::Quick Qt5::Qml Qt5::Svg KF5::CoreAddons KF5::I18n KF5::SyntaxHighlighting)

install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
