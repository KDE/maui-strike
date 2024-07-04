#pragma once

#include <QObject>
#include <QVector>
#include "cmakedata.h"
#include "models/sourcesmodel.h"

class CMakeProjectTarget : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name NOTIFY dataChanged)
    Q_PROPERTY(SourcesModel *sources READ sources NOTIFY dataChanged)
    Q_PROPERTY(QList<QUrl> artifacts READ artifacts NOTIFY dataChanged)

public:
    explicit CMakeProjectTarget(QObject *parent = nullptr);

    QString name() const;
    CMakeTarget data() const;
    QList<QUrl> artifacts() const;
    SourcesModel *sources() const;

public Q_SLOTS:
    void setData(CMakeTarget data, const QUrl &source);

private:
    CMakeTarget m_data;
    SourcesModel *m_sources;

Q_SIGNALS:
    void dataChanged();
};
