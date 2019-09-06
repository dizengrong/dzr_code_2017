#ifndef LANGTABWIDGET_H
#define LANGTABWIDGET_H

#include <QTabWidget>

namespace Ui {
class LangTabWidget;
}

class LangTabWidget : public QTabWidget
{
    Q_OBJECT

public:
    explicit LangTabWidget(QWidget *parent = 0);
    ~LangTabWidget();

private:
    Ui::LangTabWidget *ui;
};

#endif // LANGTABWIDGET_H
