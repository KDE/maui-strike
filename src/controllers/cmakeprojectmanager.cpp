#include "cmakeprojectmanager.h"

#include <QDebug>
#include <QDir>
#include <QJsonObject>

#include <MauiKit/FileBrowsing/fmstatic.h>

#include "cmakeapi.h"
#include "cmakedata.h"

#include "controllers/cmakeproject.h"
#include "controllers/processes/configureprocess.h"
#include "controllers/projectmanager.h"
#include "controllers/projectpreferences.h"

#include "models/cmakeprojectsmodel.h"

CMakeProjectManager::CMakeProjectManager(ProjectManager *parent) : QObject(parent)
,m_projectsModel(new CMakeProjectsModel(this))
,m_configureProcess(new ConfigureProcess(parent, this))
,m_project(new CMakeProject(this))
,m_root(parent) //root project
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

CMakeProject *CMakeProjectManager::project() const
{
  return m_project;
}

ProjectManager *CMakeProjectManager::root()
{
  return m_root;
}

CMakeProjectManager::Status CMakeProjectManager::status() const
{
  return m_status;
}

void CMakeProjectManager::initServer()
{
  CMake::FileApi::writeClientQueryFile(m_root->preferences()->buildDir().toLocalFile());
}

void CMakeProjectManager::initConfigure()
{
  m_configureProcess->prepare();
  m_configureProcess->start();
}

void CMakeProjectManager::initBuildDir()
{
  const QDir dir(m_root->preferences()->buildDir().toLocalFile());
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
  const auto sourceDir = m_root->projectPath().toLocalFile();
  const auto buildDir = m_root->preferences()->buildDir().toLocalFile();

  auto indexResponse = CMake::FileApi::findReplyIndexFile(buildDir);

  qDebug() << sourceDir << buildDir;
  qDebug() << indexResponse.keys();

  auto projects = CMake::FileApi::parseReplyIndexFile(indexResponse,sourceDir, buildDir);

  m_projectsModel->setData(projects); //parent each project to the model

  if(!projects.isEmpty ())
    {
      m_project->setData (projects.first ());
    }
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
