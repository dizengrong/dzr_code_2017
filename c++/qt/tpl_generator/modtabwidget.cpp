#include "modtabwidget.h"
#include "ui_modtabwidget.h"

ModTabWidget::ModTabWidget(QWidget *parent) :
    QTabWidget(parent),
    ui(new Ui::ModTabWidget)
{
    ui->setupUi(this);
}

ModTabWidget::~ModTabWidget()
{
    delete ui;
}
