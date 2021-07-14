
#ifndef CMAKETARGET_H
#define CMAKETARGET_H

#include <QObject>
#include <QVector>


class CMakeTargetProject : public QObject
{
    Q_OBJECT
public:
    explicit CMakeTargetProject(QObject *parent = nullptr);

signals:

};



#endif // CMAKETARGET_H
