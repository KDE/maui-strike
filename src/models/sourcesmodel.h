#ifndef SOURCESMODEL_H
#define SOURCESMODEL_H

#include <MauiKit4/Core/mauilist.h>

#include <QObject>

class SourcesModel : public MauiList
{
    Q_OBJECT
public:
    SourcesModel(QObject *parent =nullptr);

    void setData(const QList<QUrl> &data, const QUrl &baseUrl);
    const FMH::MODEL_LIST &items() const override final;

private:
    FMH::MODEL_LIST m_list;

};

#endif // SOURCESMODEL_H
