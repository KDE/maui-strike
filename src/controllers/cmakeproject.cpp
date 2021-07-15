#include "cmakeproject.h"
#include "cmakedata.h"
#include "models/cmaketargetsmodel.h"
#include "cmakeprojecttarget.h"

#include <QDebug>

CMakeProject::CMakeProject(QObject *parent) : QObject(parent)
  ,m_targetsModel(new CMakeTargetsModel{this})
  ,m_target(new CMakeProjectTarget(this))
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

void CMakeProject::setData(CMakeProjectData data)
{
    qDebug() << "Setting the cmake project data" << data.name;

    m_data = data;

    m_targetsModel->setData(m_data.targets);
    auto execs = m_targetsModel->filterBy(CMakeTarget::Executable);

    if(!execs.isEmpty())
    {
        m_target->setData(execs.first());
    }

    emit dataChanged(m_data);
}
