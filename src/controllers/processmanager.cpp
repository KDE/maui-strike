#include "processmanager.h"
#include <QProcess>
#include <QDir>
#include <QDebug>

#include <MauiKit/FileBrowsing/fmstatic.h>

const QString CMAKE_PROGRAM = "cmake";

ProcessManager::ProcessManager(QObject *parent) : QObject(parent)
  ,m_configureProcess(new QProcess(this))
  ,m_buildProcess(new QProcess(this))
  ,m_runProcess(new QProcess(this))
{
    // Configure Process
    connect(m_configureProcess, &QProcess::readyReadStandardOutput,[this]()
    {
//        qWarning() << "Configure output" << m_configureProcess->readAllStandardOutput();
        emit outputLine(m_configureProcess->readAllStandardOutput());
    });

    connect(m_configureProcess, &QProcess::started,[this]()
    {
        qWarning() << "Configure step started" ;
        m_infoLabel = "Configuring project...";
        emit infoLabelChanged(m_infoLabel);

        m_configureRunning = true;
        emit configureRunningChanged(m_configureRunning);

        m_processRunning = true;
        emit this->processRunningChanged(m_processRunning);
    });

    connect(m_configureProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), [this](int exitCode, QProcess::ExitStatus)
    {
        qWarning() << "Configure step finished" << exitCode;

        m_infoLabel = QString("Configuring finished with %1").arg(QString::number(exitCode));
        emit infoLabelChanged(m_infoLabel);

        m_configureRunning = false;
        emit configureRunningChanged(m_configureRunning);

        m_processRunning = false;
        emit this->processRunningChanged(m_processRunning);

    });

    // Build Process
    connect(m_buildProcess, &QProcess::readyReadStandardOutput,[this]()
    {
//        qWarning() << "Build output" << m_buildProcess->readAllStandardOutput();
        emit outputLine(m_buildProcess->readAllStandardOutput());
    });

    connect(m_buildProcess, &QProcess::started,[this]()
    {
        qWarning() << "Build step started" ;
        m_infoLabel = "Building project...";
        emit infoLabelChanged(m_infoLabel);

        m_buildRunning = true;
        emit this->buildRunningChanged(m_buildRunning);

        m_processRunning = true;
        emit this->processRunningChanged(m_processRunning);
    });

    connect(m_buildProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), [this](int exitCode, QProcess::ExitStatus)
    {
        qWarning() << "Building step finished" << exitCode;

        m_infoLabel = QString("Building finished with %1").arg(QString::number(exitCode));
        emit infoLabelChanged(m_infoLabel);

        m_buildRunning = false;
        emit buildRunningChanged(m_buildRunning);

        m_processRunning = false;
        emit this->processRunningChanged(m_processRunning);

    });

    // Run Process
    connect(m_runProcess, &QProcess::readyReadStandardOutput,[this]()
    {
//        qWarning() << "Run output" << m_runProcess->readAllStandardOutput();
        emit outputLine(m_runProcess->readAllStandardOutput());

    });

    connect(m_runProcess, &QProcess::started,[this]()
    {
        qWarning() << "Running step started" ;

        m_infoLabel = "Running binary...";
        emit infoLabelChanged(m_infoLabel);

        m_binaryRunning = true;
        emit binaryRunningChanged(m_binaryRunning);

        m_processRunning = true;
        emit this->processRunningChanged(m_processRunning);
    });

    connect(m_runProcess, &QProcess::errorOccurred,[this](QProcess::ProcessError error)
    {
        qWarning() << "Running binary error << " << error;
        emit outputLine(m_runProcess->errorString());
    });


    connect(m_runProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), [this](int exitCode, QProcess::ExitStatus)
    {
        qWarning() << "Running step finished" << exitCode;

        m_infoLabel = QString("Binary exited with %1").arg(QString::number(exitCode));
        emit infoLabelChanged(m_infoLabel);

        m_binaryRunning = false;
        emit this->binaryRunningChanged(m_binaryRunning);

        m_processRunning = false;
        emit this->processRunningChanged(m_processRunning);

    });
}

void ProcessManager::setProjectUrl(const QUrl &url)
{
    m_projectUrl = url;
    m_rootDir = FMStatic::fileDir(m_projectUrl);
    m_buildDir = QUrl(m_rootDir.toString()+"/build");

    m_infoLabel = m_rootDir.toLocalFile();
    emit infoLabelChanged(m_infoLabel);

    if(m_projectUrl.isEmpty() || !m_projectUrl.isValid() || !FMH::fileExists(m_projectUrl))
    {
        qWarning() << "CMake Project file URL has not been set, is not valid or does not exists << " << m_projectUrl;
        return;
    }

    configure();
}

QUrl ProcessManager::buildDir() const
{
return m_buildDir;
}

QUrl ProcessManager::rootDir() const
{
    return m_rootDir;
}


QStringList ProcessManager::args() const
{
    return m_args;
}

QStringList ProcessManager::envVar() const
{
    return m_envVar;
}

bool ProcessManager::processRunning() const
{
    return m_processRunning;
}

QString ProcessManager::installPrefix() const
{
    return m_installPrefix;
}

bool ProcessManager::configureRunning() const
{
    return m_configureRunning;
}

bool ProcessManager::buildRunning() const
{
    return m_buildRunning;
}

bool ProcessManager::binaryRunning() const
{
    return m_binaryRunning;
}

bool ProcessManager::enabled() const
{
    return m_enabled;
}

void ProcessManager::build()
{
    QMetaObject::Connection * const connection = new QMetaObject::Connection;
    *connection = connect(m_configureProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, [this, connection](int exitCode, QProcess::ExitStatus exitStatus)
    {
        qDebug() << "Configure step finished";

        if(exitStatus == QProcess::NormalExit)
        {
            qDebug() << "Configure step sucessfull, now build will start";

            buildStep();
        }else
        {
            qWarning() << "Configure step failed " << exitCode << exitStatus;
            qWarning() << "Build step can not continue.";
        }

        QObject::disconnect(*connection);
        delete connection;
    },  Qt::ConnectionType::UniqueConnection);

    configure();
}

void ProcessManager::configure()
{
    configureStep();
}

void ProcessManager::run()
{
    QMetaObject::Connection * const connection = new QMetaObject::Connection;
    *connection = connect(m_buildProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, [this, connection](int exitCode, QProcess::ExitStatus exitStatus)
    {
        qDebug() << "Build step finished";

        if(exitStatus == QProcess::NormalExit)
        {
            qDebug() << "Build step sucessfull, now run will start";
            runStep();
        }else
        {
            qWarning() << "Build step failed " << exitCode << exitStatus;
            qWarning() << "Run step can not continue.";
        }

        QObject::disconnect(*connection);
        delete connection;

    }, Qt::ConnectionType::UniqueConnection);

    build();
}

void ProcessManager::stopBuild()
{
    m_buildProcess->terminate();
}

void ProcessManager::stopConfigure()
{
    m_configureProcess->terminate();
}

void ProcessManager::stopRun()
{
    m_runProcess->terminate();
}

void ProcessManager::setArgs(QStringList args)
{
    if (m_args == args)
        return;

    m_args = args;
    emit argsChanged(m_args);
}

void ProcessManager::setEnvVar(QStringList envVar)
{
    if (m_envVar == envVar)
        return;

    m_envVar = envVar;
    emit envVarChanged(m_envVar);
}

void ProcessManager::setInstallPrefix(QString installPrefix)
{
    if (m_installPrefix == installPrefix)
        return;

    m_installPrefix = installPrefix;
    emit installPrefixChanged(m_installPrefix);
}

void ProcessManager::buildStep()
{
    m_buildProcess->setWorkingDirectory(m_buildDir.toLocalFile());
    m_buildProcess->start("make", QStringList());
}

void ProcessManager::configureStep()
{
    const auto workingDir = m_buildDir.toLocalFile();

    qDebug() << "Setting up working directory"<< workingDir;

    QDir dir(workingDir);
    if(!dir.exists())
    {
        if(! dir.mkpath("."))
        {
            qWarning() << "Build directory could not be created at << " << workingDir;
            return;
        }
    }

    this->m_enabled = true;
    emit this->enabledChanged(m_enabled);

    const QStringList args = {m_rootDir.toLocalFile(), QString("-DCMAKE_INSTALL_PREFIX=%1").arg(m_installPrefix)};

    m_configureProcess->setWorkingDirectory(workingDir);

    qDebug() << "Running cmake << " << CMAKE_PROGRAM << args << m_args << m_configureProcess->workingDirectory();

    m_configureProcess->start(CMAKE_PROGRAM, QStringList() << args << m_args);

    qDebug() << "Running configure" << m_configureProcess->errorString();
}

void ProcessManager::runStep()
{
    m_runProcess->setWorkingDirectory(m_buildDir.toLocalFile()+"/bin");
    m_runProcess->start("./nota", QStringList());
}
