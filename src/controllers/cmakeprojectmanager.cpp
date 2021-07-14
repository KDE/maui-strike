#include "cmakeprojectmanager.h"

#include <QDebug>
#include <QDir>
#include <QJsonObject>

#include <MauiKit/FileBrowsing/fmstatic.h>

#include "cmakeapi.h"
#include "controllers/processes/configureprocess.h"
#include "controllers/projectmanager.h"
#include "controllers/projectpreferences.h"

#include "models/cmakeprojectsmodel.h"

CMakeProjectManager::CMakeProjectManager(ProjectManager *parent) : QObject(parent)
  ,m_configureProcess(new ConfigureProcess(parent, this))
  ,m_project(parent)
{
    connect(m_configureProcess, &ConfigureProcess::readyReadStandardOutput, [this](){
        emit this->outputLine(m_configureProcess->readAllStandardOutput());
    });

    connect(m_configureProcess, &ConfigureProcess::started, [this]()
    {
        this->setStatus(Status::Loading);
    });

    connect(m_configureProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), [this](int exitCode, QProcess::ExitStatus status)
    {
        if(status == QProcess::CrashExit)
        {
            this->setStatus(Status::Error);
        }else
        {
            this->setStatus( exitCode == 0 ? Status::Ready : Status::Error);
        }
    });

    connect(this, &CMakeProjectManager::statusChanged, [this](Status status)
    {
        if(status == Status::Ready)
        {
            this->readIndexReply();
        }
    });
}

void CMakeProjectManager::init()
{
    this->initBuildDir(); //first create needed build directory
    this->initServer(); //init the server then
    this->initConfigure(); //run configuration to get server replies
}

CMakeProjectsModel *CMakeProjectManager::projectsModel() const
{
    return m_projectsModel;
}

CMakeProjectManager::Status CMakeProjectManager::status() const
{
    return m_status;
}

void CMakeProjectManager::initServer()
{
    CMake::FileApi::writeClientQueryFile(m_project->preferences()->buildDir().toLocalFile());
}

void CMakeProjectManager::initConfigure()
{
    m_configureProcess->prepare();
    m_configureProcess->start();
}

void CMakeProjectManager::initBuildDir()
{
    const QDir dir(m_project->preferences()->buildDir().toLocalFile());
    if(!dir.exists())
    {
        if(!dir.mkpath("."))
        {
            qWarning() << "Working Build directory could not be created at << " << dir.absolutePath();
            return;
        }
    }
}

void CMakeProjectManager::readIndexReply()
{
    auto indexResponse = CMake::FileApi::findReplyIndexFile(m_project->preferences()->buildDir().toLocalFile());

    qDebug() << indexResponse.keys();
}

void CMakeProjectManager::setStatus(const CMakeProjectManager::Status &status)
{
    if(m_status == status)
    {
        return;
    }

    m_status = status;
    emit statusChanged(m_status);
}
