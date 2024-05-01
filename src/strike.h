#pragma once

#include <QFileInfo>
#include <QObject>
#include <QProcess>
#include <QDebug>

#include <MauiKit4/FileBrowsing/fmstatic.h>

class Strike : public QObject
{
    Q_OBJECT

public:
    static Strike *instance()
    {
        static Strike strike;
        return &strike;
    }

    Strike(const Strike &) = delete;
    Strike &operator=(const Strike &) = delete;
    Strike(Strike &&) = delete;
    Strike &operator=(Strike &&) = delete;

public Q_SLOTS:
    void requestFiles(const QStringList &urls)
    {
        qDebug() << "REQUEST FILES" << urls;
        QStringList res;
        for (const auto &url : urls) {
            const auto url_ = QUrl::fromUserInput(url);
            qDebug() << "REQUEST FILES" << url_.toString() << FMStatic::getMime(url_);

            if (FMStatic::checkFileType(FMStatic::FILTER_TYPE::TEXT, FMStatic::getMime(url_)))
                res << url_.toString();
        }

        qDebug() << "REQUEST FILES" << res;

        Q_EMIT this->openFiles(res);
    }

    bool run(const QString &process, const QStringList &params = {})
    {
        auto m_process = new QProcess;
        //            connect(myProcess,SIGNAL(readyReadStandardError()),this,SLOT(vEdProcess()));
        //            connect(myProcess,SIGNAL(readyReadStandardOutput()),this,SLOT(processStandardOutput()));
        connect(m_process, SIGNAL(finished(int)), m_process, SLOT(deleteLater()));
        connect(this, &QObject::destroyed, m_process, &QProcess::kill);
        m_process->start(process, params);
        return true;
    }

Q_SIGNALS:
    void openFiles(QStringList urls);

private:
    explicit Strike(QObject *parent = nullptr)
        : QObject(parent)
    {
    }
};
