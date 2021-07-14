#include "cmakeprojectsmodel.h"

#include "controllers/cmakeproject.h"

CMakeProjectsModel::CMakeProjectsModel(QObject *parent) : QAbstractListModel(parent)
{

}

void CMakeProjectsModel::insertProject(CMakeProject *project)
{
    emit this->beginInsertRows(QModelIndex(), rowCount(QModelIndex()), rowCount(QModelIndex()));
    this->m_projects.append(project);
    emit this->endInsertRows();
}

int CMakeProjectsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
    {
        return 0;
    }

    return this->m_projects.size();
}

QVariant CMakeProjectsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    auto value = this->m_projects.at(index.row());

    switch(role)
    {
    case Roles::Title : return QVariant(value->title());
    case Roles::Project : return QVariant::fromValue(value);
    default: return QVariant();
    }
}

QHash<int, QByteArray> CMakeProjectsModel::roleNames() const
{
    return QHash<int, QByteArray> {{Roles::Title, "title"}, {Roles::Project, "project"}};
}
