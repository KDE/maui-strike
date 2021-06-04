#ifndef DOCUMENTSMODEL_H
#define DOCUMENTSMODEL_H

#include <QObject>

#include <MauiKit/Core/fmh.h>
#include <MauiKit/Core/mauilist.h>

namespace FMH
{
class FileLoader;
}

class DocumentsModel : public MauiList
{
    Q_OBJECT
public:
    DocumentsModel(QObject *parent = nullptr);
    ~DocumentsModel() override;

    const FMH::MODEL_LIST &items() const override final;

    void componentComplete() override final;

public slots:
    int indexOfName(const QString &query);

private:
    void append(const FMH::MODEL_LIST &items);

    FMH::MODEL_LIST m_list;
    FMH::FileLoader *m_fileLoader;
};

#endif // DOCUMENTSMODEL_H
