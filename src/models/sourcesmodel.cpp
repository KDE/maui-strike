#include "sourcesmodel.h"
#include <MauiKit/FileBrowsing/fmstatic.h>
#include <QDebug>
#include <QDir>

SourcesModel::SourcesModel(QObject *parent) : MauiList(parent)
{

}

void SourcesModel::setData(const QList<QUrl> &data)
{
    emit this->preListChanged();
    for(const auto &url : data)
    {
        qDebug() << "Getting model sources data";
        auto localUrl = QUrl::fromLocalFile(url.toString());
        auto item = FMStatic::getFileInfoModel(localUrl);
        item[FMH::MODEL_KEY::PLACE] =  QDir(FMStatic::fileDir(localUrl).toLocalFile()).dirName();
        m_list << item;

    }
    emit this->postListChanged();
}

const FMH::MODEL_LIST &SourcesModel::items() const
{
    return m_list;
}
