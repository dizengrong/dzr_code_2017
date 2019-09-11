#include "mainwindow.h"
#include "modtab.h"
#include "setting.h"
#include <QFile>
#include <QMenuBar> //前向声明需要
#include <QtWidgets/QHBoxLayout>
#include <QCoreApplication>
#include <QDir>
#include <QMessageBox>
#include <QDebug>

QString readProcessOut(QProcess *process, int waitSces = 60000) {
    const qint64 maxSize = 512;
    char buffer[maxSize];
    qint64 len;
    bool ret;
    QString ret_str;
    int count = 1;
    while(count > 0) {
        /*
         * 一个waitForReadyRead信号可能输出的是多行
         */
        --count;
        //qDebug() << "being wait for read";
        ret = process->waitForReadyRead(waitSces);
        //qDebug() << "got read signal:" << ret;
        if(!ret) {
            break;
        }
        while(true) {
            len = process->readLine(buffer, maxSize);
            /*
             * 因为每一行至少还有回车换行符，因此读到0，说明waitForReadyRead超时返回false
             */
            if(len <= 0) {
                break;
            }
            ret_str += QString::fromLocal8Bit(buffer);
        }
    }
    return ret_str;
}

void MainWindow::onExportAllErlModAction()
{

}

void MainWindow::onExportAllLuaModAction()
{

}

void MainWindow::onExportAllCsModAction()
{

}

void MainWindow::loadStyleSheet(const QString &styleSheetFile)
{
    QFile file(styleSheetFile);
        file.open(QFile::ReadOnly);
        if (file.isOpen())
        {
            QString styleSheet = this->styleSheet();
            styleSheet += QLatin1String(file.readAll());//读取样式表文件
            this->setStyleSheet(styleSheet);//把文件内容传参
            file.close();
        }
        else
        {
            QMessageBox::information(this,"tip","cannot find qss file");
        }
}

MainWindow::MainWindow(QWidget *parent, QProcess *process)
    : QMainWindow(parent), m_pyProcess(process)
{
    loadStyleSheet(":/qss/my_style_sheet.qss");
    createActions();
    createMenus();

    QWidget *centralWidget = new QWidget(this);
    centralWidget->setObjectName(QStringLiteral("centralWidget"));
    setCentralWidget(centralWidget);

    initTabs(centralWidget);

    QHBoxLayout *horizontalLayout = new QHBoxLayout(centralWidget);
    horizontalLayout->setMargin(0);

    horizontalLayout->addWidget(m_tabWidget);
    centralWidget->setLayout(horizontalLayout);


    //QTimer *m_timer = new QTimer(this);
    //connect(m_timer, &QTimer::timeout, this, &MainWindow::onTimerTest);
    //m_timer->start(3000);
}

void MainWindow::onTimerTest()
{
    m_pyProcess->write("bbbb\n");
}

MainWindow::~MainWindow()
{

}

void MainWindow::exportOneFile(const QString &save_dir, const QString &tpl_file)
{

    QString cmd = "export_one_file|" + save_dir + "|" + tpl_file + "\n";
    executePythonCmd(cmd);
}

void MainWindow::exportBySheet(const QString &sheet)
{
    QString dirStr;
    qDebug() << Setting::getInstatnce().getErlDir();
    qDebug() << Setting::getInstatnce().getLuaDir();
    const QString &erlDir = Setting::getInstatnce().getErlDir();
    const QString &luaDir = Setting::getInstatnce().getLuaDir();
    //dirStr.sprintf("{\"erl\":\"%s\", \"lua\":\"%s\"}", erlDir, luaDir);
    dirStr = QString("{\"erl\":\"%1\", \"lua\":\"%2\"}").arg(erlDir).arg(luaDir);
    qDebug() << dirStr;
    QString cmd = "export_by_sheet|" + dirStr + "|" + sheet + "\n";
    executePythonCmd(cmd);
}

void MainWindow::createMenus()
{
    QMenu *menu = menuBar()->addMenu(tr("工具"));
    menu->addAction(m_export_all_erl_act);
    menu->addAction(m_export_all_lua_act);
    menu->addAction(m_export_all_cs_act);
}

void MainWindow::createActions()
{
    m_export_all_erl_act = new QAction(tr("导出所有Erl功能配置"), this);
    connect(m_export_all_erl_act, &QAction::triggered, this, &MainWindow::onExportAllErlModAction);

    m_export_all_lua_act = new QAction(tr("导出所有Lua功能配置"), this);
    connect(m_export_all_lua_act, &QAction::triggered, this, &MainWindow::onExportAllLuaModAction);

    m_export_all_cs_act = new QAction(tr("导出所有C#功能配置"), this);
    connect(m_export_all_cs_act, &QAction::triggered, this, &MainWindow::onExportAllCsModAction);
}

void MainWindow::initTabs(QWidget* centralWidget)
{
    m_tabWidget = new QTabWidget(centralWidget);
    ModTab* m_mod_tab = new ModTab(this);
    m_tabWidget->addTab(m_mod_tab, QString(tr("游戏功能配置")));

    QDir dir(QCoreApplication::applicationDirPath());
    QString jsonFile = dir.absoluteFilePath("cfg_game_config.json");
    if (! m_mod_tab->loadConfigJson(jsonFile))
        exit(0);

}

void MainWindow::executePythonCmd(const QString &cmd)
{
    qDebug() << "execute cmd:" << cmd;
    qDebug() << "std string cmd:" << cmd.toStdWString().data();
    m_pyProcess->write(cmd.toStdString().data());
    QString ret = readProcessOut(m_pyProcess);
    qDebug() << "return result:" << ret;
    QStringList result = ret.split('|');
    if (result[0].toInt() == 1) {
        QMessageBox::information(this, "export succ", result[1]);
    } else {
        QMessageBox::information(this, "export failed", result[1]);
    }
}
