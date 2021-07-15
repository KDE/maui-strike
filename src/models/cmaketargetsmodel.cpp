#include "cmaketargetsmodel.h"
#include <QDebug>

CMakeTargetsModel::CMakeTargetsModel(QObject *parent) : QAbstractListModel(parent)
{

}

void CMakeTargetsModel::setData(const CMakeProjectTargets &data)
{
    qDebug() << "Setting the targets model" << data.keys();
    m_data = data;
    this->setList();
    emit dataChanged(m_data);
}

QVector<CMakeTarget> CMakeTargetsModel::filterBy(const CMakeTarget::Type &type)
{
    QVector<CMakeTarget> res;
    for(const auto &key : m_data.keys())
    {
        for(const auto &target : m_data.value(key))
        {
            if(target.type == type)
            {
                res.append(target);
            }
        }
    }

    return res;
}

void CMakeTargetsModel::setList()
{
    this->beginResetModel();
    m_targets = this->filterBy(CMakeTarget::Executable);
    this->endResetModel();

}

int CMakeTargetsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
    {
        return 0;
    }

    return m_targets.size();
}

QVariant CMakeTargetsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    auto value = m_targets.at(index.row());

    switch(role)
    {
    case Roles::Name : return QVariant(value.name);
    case Roles::Type : return QVariant(value.type);
    case Roles::Target : return QVariant::fromValue(value);
    case Roles::Sources : return QVariant::fromValue(value.sources);
    case Roles::Artifacts : return QVariant::fromValue(value.artifacts);
    default: return QVariant();
    }
}

QHash<int, QByteArray> CMakeTargetsModel::roleNames() const
{
    return QHash<int, QByteArray> {
        {Roles::Url, "url"},
        {Roles::Target, "target"},
        {Roles::Name, "name"},
        {Roles::Type, "Type"},
        {Roles::Sources, "Sources"},
        {Roles::Data, "Data"},
        {Roles::Artifacts, "artifacts"},
    };
}
