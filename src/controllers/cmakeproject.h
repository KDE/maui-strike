#ifndef CMAKEPROJECT_H
#define CMAKEPROJECT_H

#include <QObject>

class CMakeProject : public QObject
{
    Q_OBJECT
public:
    explicit CMakeProject(QObject *parent = nullptr);

signals:

};

#endif // CMAKEPROJECT_H
