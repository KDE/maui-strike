#ifndef CMAKEPROJECTMANAGER_H
#define CMAKEPROJECTMANAGER_H

#include <QObject>


class CMakeProjectManager : public QObject
{
    Q_OBJECT
public:
    explicit CMakeProjectManager(QObject *parent = nullptr);

signals:

};



#endif // CMAKEPROJECTMANAGER_H
