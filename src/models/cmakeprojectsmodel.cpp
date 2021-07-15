#include "cmakeprojectsmodel.h"

#include "controllers/cmakeproject.h"

CMakeProjectsModel::CMakeProjectsModel(QObject *parent) : QAbstractListModel(parent)
{
    qRegisterMetaType<CMakeProjectData>("CMakeProjectData");

}

void CMakeProjectsModel::setData(const QVector<CMakeProjectData> &data)
{
    this->beginResetModel();
    m_data = data;
    this->endResetModel();
}

int CMakeProjectsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
    {
        return 0;
    }

    return m_data.size();
}

QVariant CMakeProjectsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    auto value = m_data.at(index.row());

    switch(role)
    {
    case Roles::Title : return QVariant(value.name);
    case Roles::Data : return QVariant::fromValue(value);
    default: return QVariant();
    }
}

QHash<int, QByteArray> CMakeProjectsModel::roleNames() const
{
    return QHash<int, QByteArray> {{Roles::Title, "title"}, {Roles::Data, "data"}};
}
