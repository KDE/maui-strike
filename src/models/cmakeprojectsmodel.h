#ifndef CMAKEPROJECTSMODEL_H
#define CMAKEPROJECTSMODEL_H

#include <QAbstractListModel>
#include <QObject>
#include <QVector>

class CMakeProject;
class CMakeProjectsModel : public QAbstractListModel
{
    Q_OBJECT

public:
    typedef  QVector<CMakeProject*> CMakeProjects;
    enum Roles
    {
        Title,
        Project
    };

    explicit CMakeProjectsModel(QObject *parent = nullptr);
    void insertProject(CMakeProject * project);

    int rowCount(const QModelIndex &parent) const override final;
    QVariant data(const QModelIndex &index, int role) const override final;
    QHash<int, QByteArray> roleNames() const override final;


private:
    CMakeProjects m_projects;

signals:

};

#endif // CMAKEPROJECTMODEL_H
