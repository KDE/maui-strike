#include "cmakeproject.h"

#include "projectpreferences.h"
#include "cmakeprojectmanager.h"
#include "projectmanager.h"

#include <QDebug>

CMakeProject::CMakeProject(CMakeProjectManager *manager) : QObject(manager)
,m_targetsModel(new CMakeTargetsModel{this})
,m_target(new CMakeProjectTarget(this))
,m_manager(manager)
{


}

QString CMakeProject::title() const
{
  return m_data.name;
}

CMakeTargetsModel *CMakeProject::targetsModel() const
{
  return m_targetsModel;
}

CMakeProjectData CMakeProject::data() const
{
  return m_data;
}

CMakeProjectTarget *CMakeProject::target() const
{
  return m_target;
}

CMakeProjectManager *CMakeProject::manager() const
{
  return m_manager;
}

void CMakeProject::setData(CMakeProjectData data)
{
  qDebug() << "Setting the cmake project data" << data.name;

  m_data = data;

  m_targetsModel->setTargetData(m_data.targets);
  auto execs = m_targetsModel->filterBy(CMakeTarget::Executable);

  if(!execs.isEmpty())
    {
      m_target->setData(execs.first(), m_manager->root()->projectPath ());
    }

  Q_EMIT dataChanged(m_data);
}

