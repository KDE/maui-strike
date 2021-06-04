set(nota_SRCS
    main.cpp
    models/historymodel.cpp
    )

set(nota_HDRS
    models/historymodel.h
    nota.h
    )

set(nota_ASSETS
    qml.qrc
    plugins/plugins.qrc
    assets/img_assets.qrc
    )

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${nota_SRCS}
        ${nota_HDRS}
        ${nota_ASSETS})
else()
    add_executable(${PROJECT_NAME}
        ${nota_SRCS}
        ${nota_HDRS}
        ${nota_ASSETS})
endif()

if (ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} KF5::ConfigCore KF5::KIOCore KF5::KIOFileWidgets KF5::KIONTLM KF5::KIOWidgets)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    if (EXISTS /usr/lib/qt/qml/QMLTermWidget OR EXISTS /lib/qt/qml/QMLTermWidget)
        message("QMLTermWidget found")
        set(QMLTermWidget_FOUND true)
    else()
        message("QMLTermWidget NOT found")
        set(QMLTermWidget_FOUND false)
    endif()

    if(QMLTermWidget_FOUND)
        add_definitions(-DEMBEDDED_TERMINAL)
    endif()
endif()

target_link_libraries(${PROJECT_NAME} MauiKit MauiKit::FileBrowsing Qt5::Sql Qt5::Quick Qt5::Qml Qt5::Svg KF5::CoreAddons KF5::I18n KF5::SyntaxHighlighting)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES assets/nota.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()
