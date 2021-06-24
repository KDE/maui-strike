#ifndef CMAKETARGET_H
#define CMAKETARGET_H

#include <QObject>
#include <QVector>


class CMakeTarget : public QObject
{
    Q_OBJECT
public:
    explicit CMakeTarget(QObject *parent = nullptr);

signals:

};



#endif // CMAKETARGET_H
