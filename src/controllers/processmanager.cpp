#include "processmanager.h"
#include <QProcess>
#include <QDir>
#include <QDebug>

#include "cmakeproject.h"

#include "processes/configureprocess.h"
#include "cmakeprojectmanager.h"
#include "cmakeprojectmanager.h"
#include "projectpreferences.h"
#include "projectmanager.h"
#include "cmakeprojecttarget.h"

#include <MauiKit3/FileBrowsing/fmstatic.h>

ProcessManager::ProcessManager(CMakeProject *project) : QObject(project)
,m_project(project)
,m_configureProcess(new ConfigureProcess(project->manager ()))
,m_buildProcess(new QProcess(this))
,m_deployProcess(new QProcess())
{

      m_deployProcess->setReadChannel(QProcess::StandardOutput);
      m_deployProcess->setProcessChannelMode (QProcess:: ForwardedChannels);
  // Configure Process
  connect(m_configureProcess, &QProcess::readyReadStandardOutput,[this]()
  {
      //        qWarning() << "Configure output" << m_configureProcess->readAllStandardOutput();
      emit this->outputLine(m_configureProcess->readAllStandardOutput());
    });

  connect(m_configureProcess, &QProcess::readyReadStandardError, [this](){
      emit this->outputLine(m_buildProcess->readAllStandardError());
  });

  connect(m_configureProcess, &QProcess::started,[this]()
  {
      qWarning() << "Configure step started" ;
      m_infoLabel = "Configuring project...";
      emit this->infoLabelChanged(m_infoLabel);

      m_configureStatus = Status::Running;
      emit this->configureStatusChanged(m_configureStatus);

      m_processRunning = true;
      emit this->processRunningChanged(m_processRunning);
    });

  connect(m_configureProcess, &QProcess::errorOccurred,[this](QProcess::ProcessError error)
  {
    qWarning() << "Building error << " << error;
    m_configureStatus = Status::Error;
    emit this->configureStatusChanged (m_configureStatus);

    emit this->outputLine(m_configureProcess->errorString());
  });

  connect(m_configureProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), [this](int exitCode, QProcess::ExitStatus status)
  {
      qWarning() << "Configure step finished" << exitCode;

      if(status == QProcess::CrashExit)
        {
          m_infoLabel = QString("Error Configuring project:  %1").arg(m_configureProcess->errorString ());

          m_configureStatus = Status::Error;

          m_processRunning = false;

        }else
        {
          m_infoLabel = QString("Configuring finished with %1").arg(QString::number(exitCode));

          m_configureStatus = exitCode == 0 ? Status::Finished : Status::Error;

          m_processRunning = false;
        }

      emit this->configureStatusChanged(m_configureStatus);
      emit this->processRunningChanged(m_processRunning);
      emit this->infoLabelChanged(m_infoLabel);

    });

  // Build Process
  connect(m_buildProcess, &QProcess::readyReadStandardOutput,[this]()
  {
      //        qWarning() << "Build output" << m_buildProcess->readAllStandardOutput();
      emit this->outputLine(m_buildProcess->readAllStandardOutput());
    });



  connect(m_buildProcess, &QProcess::readyReadStandardError, [this](){
      emit this->outputLine(m_buildProcess->readAllStandardError());
  });

  connect(m_buildProcess, &QProcess::started,[this]()
  {
      qWarning() << "Build step started" ;
      m_infoLabel = "Building project...";
      emit this->infoLabelChanged(m_infoLabel);

      m_buildStatus = Status::Running;
      emit this->buildStatusChanged(m_buildStatus);

      m_processRunning = true;
      emit this->processRunningChanged(m_processRunning);
    });

  connect(m_buildProcess, &QProcess::errorOccurred,[this](QProcess::ProcessError error)
  {
    qWarning() << "Building error << " << error;
    m_buildStatus = Status::Error;
    emit this->buildStatusChanged (m_buildStatus);

    emit this->outputLine(m_buildProcess->errorString());
  });

  connect(m_buildProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), [this](int exitCode, QProcess::ExitStatus status)
  {
      if(status == QProcess::CrashExit)
        {
          m_infoLabel = QString("Error Bulding project:  %1").arg(m_buildProcess->errorString ());

          m_buildStatus = Status::Error;

          m_processRunning = false;

        }else
        {
          m_infoLabel = QString("Building finished with %1").arg(QString::number(exitCode));

          m_buildStatus = exitCode == 0 ? Status::Finished : Status::Error;

          m_processRunning = false;
        }

      emit this->buildStatusChanged (m_configureStatus);
      emit this->processRunningChanged(m_processRunning);
      emit this->infoLabelChanged(m_infoLabel);

    });

  // Run Process
  connect(m_deployProcess, &QProcess::readyReadStandardOutput,[this]()
  {
      //        qWarning() << "Run output" << m_deployProcess->readAllStandardOutput();
      emit this->outputLine(m_deployProcess->readAll());

    });

  connect(m_deployProcess, &QProcess::readyReadStandardError, [this](){
      emit this->outputLine(m_deployProcess->readAllStandardError());
  });

  connect(m_deployProcess, &QProcess::started,[this]()
  {
      qWarning() << "Running step started" ;

      m_infoLabel = "Running binary...";
      emit this->infoLabelChanged(m_infoLabel);

      m_deployStatus = Status::Running;
      emit this->deployStatusChanged(m_deployStatus);

      m_processRunning = true;
      emit this->processRunningChanged(m_processRunning);
    });

  connect(m_deployProcess, &QProcess::errorOccurred,[this](QProcess::ProcessError error)
  {
    qWarning() << "Running binary error << " << error;
    m_deployStatus = Status::Error;
    emit this->deployStatusChanged (m_deployStatus);

    emit this->outputLine(m_deployProcess->errorString());
  });


  connect(m_deployProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), [this](int exitCode, QProcess::ExitStatus status)
  {
      qWarning() << "Running step finished" << exitCode;
      if(status == QProcess::CrashExit)
        {
          m_infoLabel = QString("Error Deploying project:  %1").arg(m_deployProcess->errorString ());

          m_deployStatus = Status::Error;

          m_processRunning = false;

        }else
        {
          m_infoLabel = QString("Deploying finished with %1").arg(QString::number(exitCode));

          m_deployStatus = exitCode == 0 ? Status::Finished : Status::Error;

          m_processRunning = false;
        }

      emit this->deployStatusChanged (m_deployStatus);
      emit this->processRunningChanged(m_processRunning);
      emit this->infoLabelChanged(m_infoLabel);
    });
}

ProcessManager::~ProcessManager()
{
  stopDeploy ();
  m_deployProcess->deleteLater ();
}

bool ProcessManager::processRunning() const
{
  return m_processRunning;
}

ProcessManager::Status ProcessManager::configureStatus() const
{
  return m_configureStatus;
}

ProcessManager::Status ProcessManager::buildStatus() const
{
  return m_buildStatus;
}

ProcessManager::Status ProcessManager::deployStatus() const
{
  return m_deployStatus;
}

bool ProcessManager::enabled() const
{
  return m_enabled;
}

QString ProcessManager::infoLabel() const
{
  return m_infoLabel;
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

void ProcessManager::deploy()
{
  QMetaObject::Connection * const connection = new QMetaObject::Connection;
  *connection = connect(m_buildProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, [this, connection](int exitCode, QProcess::ExitStatus exitStatus)
  {
      qDebug() << "Build step finished";

      if(exitStatus == QProcess::NormalExit)
        {
          qDebug() << "Build step sucessfull, now run will start";
          deployStep();
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
  m_buildProcess->waitForFinished ();
}

void ProcessManager::stopConfigure()
{
  m_configureProcess->terminate();
  m_configureProcess->waitForFinished ();
}

void ProcessManager::stopDeploy()
{
  m_deployProcess->terminate();
  m_deployProcess->waitForFinished ();
}

void ProcessManager::buildStep()
{
  m_buildProcess->setWorkingDirectory(m_project->manager ()->root ()->preferences ()->buildDir ().toLocalFile());
  m_buildProcess->start("make", QStringList());
}

void ProcessManager::configureStep()
{
  m_configureProcess->prepare ();

  this->m_enabled = true;
  emit this->enabledChanged(m_enabled);

  m_configureProcess->start ();
}

void ProcessManager::deployStep()
{
 qDebug() << "Execute:" <<  m_project->target ()->artifacts ().first ().toString ();
  m_deployProcess->start(m_project->target ()->artifacts ().first ().toString (), QStringList());
}
