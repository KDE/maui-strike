#include "historymodel.h"

#include <MauiKit/Core/utils.h>
#include <MauiKit/FileBrowsing/fmstatic.h>

static bool isTextDocument(const QUrl &url)
{
    return FMStatic::checkFileType(FMStatic::FILTER_TYPE::TEXT, FMStatic::getMime(url));
}

HistoryModel::HistoryModel(QObject *parent)
    : MauiList(parent)
{
}

const FMH::MODEL_LIST &HistoryModel::items() const
{
    return this->m_list;
}

void HistoryModel::append(const QUrl &url)
{
    auto urls = this->getHistory();
    if (urls.contains(url.toString()) || !isTextDocument(url))
        return;

    emit this->preItemAppended();
    this->m_list << FMStatic::getFileInfoModel(url);
    emit this->postItemAppended();

    urls << url;

    UTIL::saveSettings("URLS", QUrl::toStringList(urls), "HISTORY");
}

int HistoryModel::indexOfName(const QString &query)
{
    const auto it = std::find_if(this->items().constBegin(), this->items().constEnd(), [&](const FMH::MODEL &item) -> bool {
        return item[FMH::MODEL_KEY::LABEL].startsWith(query, Qt::CaseInsensitive);
    });

    if (it != this->items().constEnd())
        return this->mappedIndexFromSource(std::distance(this->items().constBegin(), it));
    else
        return -1;
}

QList<QUrl> HistoryModel::getHistory()
{
    auto urls = UTIL::loadSettings("URLS", "HISTORY", QStringList()).toStringList();
    urls.removeDuplicates();
    auto res = QUrl::fromStringList(urls);
    res.removeAll(QString(""));
    return res;
}

void HistoryModel::setList()
{
    const auto urls = this->getHistory();
    for (const auto &url : urls) {
        if (!url.isLocalFile() || !FMH::fileExists(url) || !isTextDocument(url))
        {
            continue;
        }

        emit this->preItemAppended();
        this->m_list << FMStatic::getFileInfoModel(url);
        emit this->postItemAppended();
        emit this->countChanged();
    }
}

void HistoryModel::componentComplete()
{
    this->setList();
}
