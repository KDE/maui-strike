#include "cmakeproject.h"

CMakeProject::CMakeProject(QObject *parent) : QObject(parent)
{

}

QString CMakeProject::title() const
{
    return m_title;
}

CMakeTargetsModel *CMakeProject::targetsModel() const
{
    return m_targetsModel;
}
