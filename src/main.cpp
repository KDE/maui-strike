#include <QApplication>
#include <QCommandLineParser>
#include <QDate>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>

#include <KI18n/KLocalizedString>

#include <MauiKit3/Core/mauiapp.h>

#include "controllers/processmanager.h"
#include "controllers/projectmanager.h"
#include "controllers/cmakeproject.h"
#include "controllers/cmakeprojecttarget.h"

#include "controllers/cmakeprojectmanager.h"
#include "controllers/projectpreferences.h"
#include "models/fonts.h"
#include "models/cmakeprojectsmodel.h"
#include "models/cmaketargetsmodel.h"
#include "models/sourcesmodel.h"

#include "../strike_version.h"
#include "strike.h"

#define STRIKE_URI "org.slike.strike"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    QApplication app(argc, argv);

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon(":/img/strike.svg"));

    KLocalizedString::setApplicationDomain("strike");

    KAboutData about(QStringLiteral("strike"), "Strike", STRIKE_VERSION_STRING, i18n("Build and run code."), KAboutLicense::LGPL_V3,i18n("© 2021-%1 Camilo Higuita", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));

    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://slike.org");
    about.setProductName("slike/strike");
    about.setBugAddress("https://invent.kde.org/maui/strike/-/issues");
    about.setOrganizationDomain(STRIKE_URI);
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);
    MauiApp::instance()->setIconName("qrc:/img/strike.svg");

    QCommandLineParser parser;

    about.setupCommandLine(&parser);
    parser.process(app);

    about.processCommandLine(&parser);
    const QStringList args = parser.positionalArguments();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
                &engine,
                &QQmlApplicationEngine::objectCreated,
                &app,
                [url, args](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

        if (!args.isEmpty())
            Strike::instance()->requestFiles(args);
    },
    Qt::QueuedConnection);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    qmlRegisterSingletonInstance<Strike>(STRIKE_URI, 1, 0, "Strike", Strike::instance());
    qmlRegisterType<ProjectManager>(STRIKE_URI, 1, 0, "Project"); //entry point for the project

    qmlRegisterAnonymousType<ProjectPreferences>(STRIKE_URI, 1);
    qmlRegisterAnonymousType<CMakeProjectsModel>(STRIKE_URI, 1);
    qmlRegisterAnonymousType<CMakeProjectTarget>(STRIKE_URI, 1);
    qmlRegisterAnonymousType<CMakeTargetsModel>(STRIKE_URI, 1);
    qmlRegisterAnonymousType<SourcesModel>(STRIKE_URI, 1);
    qmlRegisterUncreatableType<ProcessManager>(STRIKE_URI, 1, 0, "Process", "For the enums. To use it get it from the manager");

    qmlRegisterUncreatableType<CMakeProject>(STRIKE_URI, 1, 0, "CMakeProject", "Get the pointer from CMakeProjectManager");

    qmlRegisterUncreatableType<CMakeProjectManager>(STRIKE_URI, 1, 0, "Manager", "The Project Manager get obtained form StrikeProjec.");

    qmlRegisterSingletonType<Fonts>(STRIKE_URI, 1, 0, "Fonts", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
      Q_UNUSED(engine)
      Q_UNUSED(scriptEngine)
      return new Fonts;
    });

    engine.load(url);

    return app.exec();
}
