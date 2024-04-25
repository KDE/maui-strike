#include "cmakeprojectmanager.h"

#include <QDebug>
#include <QDir>
#include <QJsonObject>

#include <MauiKit4/FileBrowsing/fmstatic.h>

#include "cmakeapi.h"
#include "cmakedata.h"

#include "controllers/processes/configureprocess.h"
#include "controllers/projectmanager.h"
#include "controllers/projectpreferences.h"


CMakeProjectManager::CMakeProjectManager(ProjectManager *parent) : QObject(parent)
,m_projectsModel(new CMakeProjectsModel(this))
,m_project(new CMakeProject(this))
,m_process(new ProcessManager(m_project))
,m_root(parent) //root project
{
  connect(this, &CMakeProjectManager::statusChanged, [this](Status status)
  {
    if(status == Status::Ready)
      {
        this->readIndexReply();
      }
  });

  connect(m_process, &ProcessManager::configureStatusChanged, [this](ProcessManager::Status status)
  {
    switch(status)
      {
      case ProcessManager::Status::Running:
        this->setStatus(Status::Loading);
        break;
      case ProcessManager::Status::Finished:
        this->setStatus(Status::Ready);
        break;
      case ProcessManager::Status::Error:
        this->setStatus(Status::Error);
        break;
      default:
        this->setStatus(Status::Error);
        break;
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

ProcessManager *CMakeProjectManager::process() const
{
  return m_process;
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
  m_process->configure ();
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

  m_projectsModel->setProjectsData(projects); //parent each project to the model

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
  Q_EMIT statusChanged(m_status);
}
