#include "langtabwidget.h"
#include "ui_langtabwidget.h"

LangTabWidget::LangTabWidget(QWidget *parent) :
    QTabWidget(parent),
    ui(new Ui::LangTabWidget)
{
    ui->setupUi(this);
}

LangTabWidget::~LangTabWidget()
{
    delete ui;
}
