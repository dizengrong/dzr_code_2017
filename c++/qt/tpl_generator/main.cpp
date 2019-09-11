#include "mainwindow.h"
#include <QApplication>
#include <QDebug>


int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    qDebug() << QCoreApplication::applicationDirPath();

    //启动python子进程
    QProcess* m_pyProcess =new QProcess();
    m_pyProcess->setWorkingDirectory(QCoreApplication::applicationDirPath());
    m_pyProcess->setProcessChannelMode(QProcess::MergedChannels);
    m_pyProcess->start("python D:/Documents/GitHub/dzr_code_2017/c++/qt/tpl_generator/py/main.py");
    qDebug() << m_pyProcess->state();
    qDebug() << m_pyProcess->processId();

    MainWindow w(nullptr, m_pyProcess);
    w.show();

    return a.exec();
}
