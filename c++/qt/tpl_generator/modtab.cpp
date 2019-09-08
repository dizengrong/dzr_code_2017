#include "modtab.h"
#include "ui_modtab.h"
#include <QtWidgets/QPushButton>
#include <QFile>
#include <QJsonObject>
#include <QJsonParseError>
#include <QMessageBox>
#include <QDebug>
#include <QJsonArray>

QPushButton* makeBtn(QWidget* parent, const QString &btnLable)
{
    QPushButton *btn = new QPushButton(parent);
    btn->setText(btnLable);
    btn->setFlat(true);
    btn->setStyleSheet(QLatin1String("color: rgb(51, 153, 255);"));
    btn->setCursor(QCursor(Qt::PointingHandCursor));
    return btn;
}

ModTab::ModTab(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::ModTab)
{
    ui->setupUi(this);

    QStringList header;
    header.append("Excel文件(点击打开)");
    header.append("Sheet名称");
    header.append("erl配置(点击导出)");
    header.append("lua配置(点击导出)");
    header.append("c#配置(点击导出)");
    header.append("操作");
    ui->m_table->setColumnCount(header.size());

    ui->m_table->setHorizontalHeaderLabels(header);
    ui->m_table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

    ui->m_table->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    ui->m_table->horizontalHeader()->setSectionResizeMode(3, QHeaderView::ResizeToContents);
    //ui->m_table->horizontalHeader()->setSectionResizeMode(5, QHeaderView::ResizeToContents);
    ui->m_table->setSelectionBehavior(QAbstractItemView::SelectItems);
    ui->m_table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    ui->m_table->setSortingEnabled(false);
}

ModTab::~ModTab()
{
    delete ui;
}

bool ModTab::loadConfigJson(const QString &jsonFile)
{
    QFile loadFile(jsonFile);

    if(!loadFile.open(QIODevice::ReadOnly))
    {
        QMessageBox::critical(this,"error","cannot find file:" + jsonFile);
        return false;
    }

    QByteArray allData = loadFile.readAll();
    loadFile.close();

    QJsonParseError json_error;
    QJsonDocument jsonDoc(QJsonDocument::fromJson(allData, &json_error));

    if(json_error.error != QJsonParseError::NoError)
    {
        QMessageBox::critical(this,"error","parse json error:" + json_error.errorString());
        return false;
    }

    QJsonObject rootObj = jsonDoc.object();
    QJsonArray  filesObjs = rootObj.value("files").toArray();

    for(int i = 0; i < filesObjs.size(); i++)
    {
        qDebug() << "key" << i << " is:" << filesObjs.at(i).toObject();
        m_exports.push_back(ExportItem(filesObjs.at(i).toObject()));
    }
    showWith(m_exports);
    return true;
}

void ModTab::showWith(const QList<ExportItem> &datas)
{
    int count, addSize;
    qDebug() << datas.size();
    for (int i = 0; i < datas.size(); ++i) {
        const ExportItem* data = &datas.at(i);

        count = ui->m_table->rowCount();
        addSize = data->m_sheets.size();
        qDebug() << "addSize:" << addSize;
        QMap<QString, QMap<QString, QString>*>::const_iterator it = data->m_sheets.constBegin();
        int j = count;
        while (it != data->m_sheets.constEnd()) {
          ui->m_table->insertRow(j);
          if (j == count){
              QPushButton *btn = makeBtn(ui->m_table, data->m_excel_file);
              ui->m_table->setCellWidget(j, 0, btn);
          }
          ui->m_table->setItem(j, 1, new QTableWidgetItem(it.key()));
          //ui->m_table->setItem(j, 2, new QTableWidgetItem(it.value()->value("export_erl")));
          if(!it.value()->value("export_erl").isEmpty())
            ui->m_table->setCellWidget(j, 2, makeBtn(ui->m_table, it.value()->value("export_erl")));
          if(!it.value()->value("export_lua").isEmpty())
            ui->m_table->setCellWidget(j, 3, makeBtn(ui->m_table, it.value()->value("export_lua")));

          ui->m_table->setCellWidget(j, 5, makeBtn(ui->m_table, "导出该行配置"));
          ++it;
        }
        if (addSize > 1){
            ui->m_table->setSpan(count, 0, addSize, 1);
        }
    }
}
