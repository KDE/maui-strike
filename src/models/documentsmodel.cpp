#include "documentsmodel.h"

#ifdef STATIC_MAUIKIT
#include "fileloader.h"
#else
#include <MauiKit/fileloader.h>
#endif

static FMH::MODEL docInfo(const QUrl &url)
{
    auto item = FMH::getFileInfoModel(url);
    item[FMH::MODEL_KEY::PLACE] = FMH::fileDir(url);
    return item;
}

DocumentsModel::DocumentsModel(QObject *parent)
    : MauiList(parent)
    , m_fileLoader(new FMH::FileLoader())
{
    qRegisterMetaType<QList<QUrl>>("QList<QUrl>&");

    m_fileLoader->informer = &docInfo;
    connect(m_fileLoader, &FMH::FileLoader::itemsReady, this, &DocumentsModel::append);
}

DocumentsModel::~DocumentsModel()
{
    delete m_fileLoader;
}

void DocumentsModel::append(const FMH::MODEL_LIST &items)
{
    emit this->preItemsAppended(items.size());
    this->m_list << items;
    emit this->postItemAppended();
}

const FMH::MODEL_LIST &DocumentsModel::items() const
{
    return this->m_list;
}

void DocumentsModel::componentComplete()
{
  m_fileLoader->requestPath({FMH::DocumentsPath, FMH::DownloadsPath}, true, FMH::FILTER_LIST[FMH::FILTER_TYPE::TEXT]);
}

int DocumentsModel::indexOfName(const QString &query)
{
  const auto it = std::find_if(this->items().constBegin(), this->items().constEnd(), [&](const FMH::MODEL &item) -> bool {
          return item[FMH::MODEL_KEY::LABEL].startsWith(query, Qt::CaseInsensitive);
      });

      if (it != this->items().constEnd())
          return this->mappedIndexFromSource(std::distance(this->items().constBegin(), it));
      else
          return -1;
}
