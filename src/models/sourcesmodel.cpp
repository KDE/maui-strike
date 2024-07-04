#include "sourcesmodel.h"
#include <MauiKit4/FileBrowsing/fmstatic.h>
#include <QDebug>
#include <QDir>

SourcesModel::SourcesModel(QObject *parent) : MauiList(parent)
{

}

void SourcesModel::setData(const QList<QUrl> &data, const QUrl &baseUrl)
{
  this->m_list.clear ();
    Q_EMIT this->preListChanged();
    for(const auto &url : data)
    {
        qDebug() << "Getting model sources data";
        auto localUrl = QUrl::fromLocalFile(url.toString());
        auto item = FMStatic::getFileInfoModel(localUrl);
        item[FMH::MODEL_KEY::PLACE] = (FMStatic::fileDir (localUrl).toLocalFile ()).replace (baseUrl.toLocalFile ()+"/", "");
        item[FMH::MODEL_KEY::SOURCE] = baseUrl.toString ();
        m_list << item;
    }
    Q_EMIT this->postListChanged();
}

const FMH::MODEL_LIST &SourcesModel::items() const
{
    return m_list;
}
