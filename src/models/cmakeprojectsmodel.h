#ifndef CMAKEPROJECTSMODEL_H
#define CMAKEPROJECTSMODEL_H

#include <QAbstractListModel>
#include <QObject>
#include <QVector>

#include "controllers/cmakedata.h"

class CMakeProject;
class CMakeProjectsModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles
    {
        Title,
        Data
    };

    explicit CMakeProjectsModel(QObject *parent = nullptr);
    void setProjectsData(const QVector<CMakeProjectData> &data);

    int rowCount(const QModelIndex &parent) const override final;
    QVariant data(const QModelIndex &index, int role) const override final;
    QHash<int, QByteArray> roleNames() const override final;

private:
    QVector<CMakeProjectData> m_data;

Q_SIGNALS:
    void currentProjectIndexChanged(int currentProjectIndex);
};

#endif // CMAKEPROJECTMODEL_H
