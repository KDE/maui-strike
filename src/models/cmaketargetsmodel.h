#ifndef CMAKETARGETSMODEL_H
#define CMAKETARGETSMODEL_H

#include <QAbstractListModel>
#include <QObject>

#include "controllers/cmakedata.h"

class CMakeTargetsModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles
    {
        Artifacts,
        Name,
        Url,
        Type,
        Sources,
        Folder,
        Target,
        Data
    };

    explicit CMakeTargetsModel(QObject *parent =nullptr);

    void setData(const CMakeProjectTargets &data);
    QVector<CMakeTarget> filterBy(const CMakeTarget::Type &type);

private:
    CMakeProjectTargets m_data;
    void setList();
    QVector<CMakeTarget> m_targets;

    // QAbstractItemModel interface
public:
    int rowCount(const QModelIndex &parent) const override final;
    QVariant data(const QModelIndex &index, int role) const override final;
    QHash<int, QByteArray> roleNames() const override final;

signals:
    void dataChanged(CMakeProjectTargets data);
};

#endif // CMAKETARGETSMODEL_H
