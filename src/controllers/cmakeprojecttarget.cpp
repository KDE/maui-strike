#include "cmakeprojecttarget.h"
#include <QDebug>

#include "models/sourcesmodel.h"

CMakeProjectTarget::CMakeProjectTarget(QObject *parent) : QObject(parent)
  ,m_sources(new SourcesModel(this))
{

}

QString CMakeProjectTarget::name() const
{
    return m_data.name;
}

CMakeTarget CMakeProjectTarget::data() const
{
    return m_data;
}

QList<QUrl> CMakeProjectTarget::artifacts() const
{
    return m_data.artifacts;
}

SourcesModel *CMakeProjectTarget::sources() const
{
    return m_sources;
}

void CMakeProjectTarget::setData(CMakeTarget data, const QUrl &source)
{
    qDebug() << "Setting target data" << data.name << data.artifacts;
    m_data = data;
    m_sources->setData(m_data.sources, source);
    emit this->dataChanged();
}
