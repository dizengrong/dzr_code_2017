#include "mainwindow.h"
#include "maptab.h"
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
    executePythonCmd("export_all|erl|" + Setting::getInstatnce().getErlDir() + "\n");
}

void MainWindow::onExportAllLuaModAction()
{
    executePythonCmd("export_all|lua|" + Setting::getInstatnce().getLuaDir() + "\n");
}

void MainWindow::onExportAllCsModAction()
{

}

void MainWindow::onAboutAction()
{
    QString title;
    title = QMessageBox::tr(
        "<h3>Excel配置导出工具-v1.0</h3>"
        "<p>本程序使用Qt（version %1）作为页面展示，使用python作为数据处理</p>"
        ).arg(QLatin1String(QT_VERSION_STR));
    QString content = QMessageBox::tr(
        "<p align=\"right\" style=\"color:red\">开发者：dzR    构建时间：2019-09-15</p>"
        );
    QMessageBox *msgBox = new QMessageBox(this);
    msgBox->setAttribute(Qt::WA_DeleteOnClose);
    msgBox->setWindowTitle("关于");
    msgBox->setText(title);
    msgBox->setInformativeText(content);

    QPixmap pm(QLatin1String(":/picture/qtlogo-64.png"));
    if (!pm.isNull())
            msgBox->setIconPixmap(pm);

    msgBox->exec();
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
    setWindowTitle("策划配置工具");
    QDir dir(QCoreApplication::applicationDirPath());
    dir.cdUp();
    m_excel_src_path = dir.path();
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


    m_timer = new QTimer(this);
    connect(m_timer, &QTimer::timeout, this, &MainWindow::onUpdateTimer);
    m_timer->start(3000);
    //QTimer::singleShot(6000, this, &MainWindow::onUpdateTimer);
    //m_test_act = new QAction(tr("test_act"), this);
}

void MainWindow::onUpdateTimer()
{
    QString cmd = "query_lang_is_ready\n";
    m_pyProcess->write(cmd.toLocal8Bit().data());
    QString ret = readProcessOut(m_pyProcess, 100);
    ret = ret.trimmed();
    qDebug() << ret;
    if (ret.isEmpty())
        return;
    if(ret != 'wait'){
        m_lang_tab->loadConfigJson(ret);
        m_tabWidget->setTabText(m_tabWidget->indexOf(m_lang_tab), tr("多语言翻译配置"));
        m_timer->stop();
    }
}


MainWindow::~MainWindow()
{
    //qDebug() << "delete MainWindow";
}

void MainWindow::exportOneFile(const QString &save_dir, const QString &tpl_file)
{
    qDebug() << m_mod_tab;
    QString cmd = "export_one_file|" + save_dir + "|" + tpl_file + "\n";
    executePythonCmd(cmd);
}

void MainWindow::exportErlMap(const QString &save_dir, const QString &obj, const QString &file)
{
    QString cmd = "export_erl_map|" + save_dir + "|" + obj + "|" + file + "\n";
    executePythonCmd(cmd);
}

void MainWindow::exportCMap(const QString &save_dir, const QString &obj, const QString &file)
{
    QString cmd = "export_c_map|" + save_dir + "|" + obj + "|" + file + "\n";
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

void MainWindow::exportLangFile(const QString &save_dir, const QString &file)
{
    QString cmd = "export_lang_file|" + save_dir + "|" + file + "\n";
    executePythonCmd(cmd);
}

const QString MainWindow::getExcelSrcPath() const
{
    return m_excel_src_path;
}

void MainWindow::createMenus()
{
    QMenu *menu = menuBar()->addMenu(tr("工具"));
    menu->addAction(m_export_all_erl_act);
    menu->addAction(m_export_all_lua_act);
    menu->addAction(m_export_all_cs_act);

    menu = menuBar()->addMenu(tr("帮助"));
    menu->addAction(m_about_act);
}

void MainWindow::createActions()
{
    m_export_all_erl_act = new QAction(tr("导出所有Erl功能配置"), this);
    connect(m_export_all_erl_act, &QAction::triggered, this, &MainWindow::onExportAllErlModAction);

    m_export_all_lua_act = new QAction(tr("导出所有Lua功能配置"), this);
    connect(m_export_all_lua_act, &QAction::triggered, this, &MainWindow::onExportAllLuaModAction);

    m_export_all_cs_act = new QAction(tr("导出所有C#功能配置"), this);
    connect(m_export_all_cs_act, &QAction::triggered, this, &MainWindow::onExportAllCsModAction);

    m_about_act = new QAction(tr("关于"), this);
    connect(m_about_act, &QAction::triggered, this, &MainWindow::onAboutAction);
}

void MainWindow::initTabs(QWidget* centralWidget)
{
    m_tabWidget = new QTabWidget(centralWidget);

    // init module config tab
    m_mod_tab = new ModTab(this);
    m_tabWidget->addTab(m_mod_tab, QString(tr("游戏功能配置")));

    QDir dir(QCoreApplication::applicationDirPath());
    QString jsonFile = dir.absoluteFilePath("cfg_game_config.json");
    if (! m_mod_tab->loadConfigJson(jsonFile))
        exit(0);

    // init map config tab
    m_map_tab = new MapTab(this);
    m_tabWidget->addTab(m_map_tab, QString(tr("地图配置")));
    jsonFile = dir.absoluteFilePath("map_conf.json");
    if (! m_map_tab->loadConfigJson(jsonFile))
        exit(0);

    // init lang config tab
    m_lang_tab = new LangTab(this);
    m_tabWidget->addTab(m_lang_tab, QString(tr("多语言翻译配置(等到就绪)")));
}

void MainWindow::executePythonCmd(const QString &cmd)
{
    qDebug() << "execute cmd:" << cmd;
    m_pyProcess->write(cmd.toLocal8Bit().data());
    QString ret = readProcessOut(m_pyProcess);
    qDebug() << "return result:" << ret;
    QStringList result = ret.split('|');
    int ret_code = result[0].toInt();
    if (ret_code == 1) {
        QMessageBox dialog(QMessageBox::Information, "tips", "export succ\t\t\t\t\t\t\t\t", QMessageBox::Ok | QMessageBox::Cancel, this);
        if(!(result[1].size() > 100))
            dialog.setInformativeText(result[1].split('\n').at(0));
        dialog.setDetailedText(result[1]);
        dialog.exec();
    } else {
        QMessageBox::information(this, "export failed", result[1]);
    }
}
