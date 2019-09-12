#include "mainwindow.h"
#include <QApplication>
#include <QDebug>
#include <QTextCodec>
#include <QTranslator>


int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    //QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
    QString pwd = QCoreApplication::applicationDirPath();
    qDebug() << pwd;

    QTranslator translator; //新建翻译类
    bool ret = translator.load("lang_Chinses", pwd); //导入生成的文件
    qDebug() << ret;
    a.installTranslator(&translator); //装入

    //启动python子进程
    QProcess* m_pyProcess =new QProcess();
    m_pyProcess->setWorkingDirectory(pwd);
    m_pyProcess->setProcessChannelMode(QProcess::MergedChannels);
    #ifdef QT_NO_DEBUG
    QString cmd = QString("python %1/py/main.py").arg(pwd);
    #else
    QString cmd = "python D:/Documents/GitHub/dzr_code_2017/c++/qt/tpl_generator/py/main.py";
    #endif
    qDebug() << cmd;
    m_pyProcess->start(cmd);
    qDebug() << m_pyProcess->state();
    qDebug() << m_pyProcess->processId();

    MainWindow w(nullptr, m_pyProcess);
    w.showMaximized();
    //w.show();

    return a.exec();
}
