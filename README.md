# SynchronizationFixTP7_BP3

## Описание:
Расширение для Штрих-М: Торговое предприятие, редакция 7.0.
Исправляет синхронизацию между Штрих-М ТП7 и Бухгалтерия 3.0 через EnterpriseData.

## Требования к версиям:
 - Торговое предприятие, редакция 7.0 (7.0.43.1)
 - Бухгалтерия предприятия редакция 3.0 (3.0.158.23)
 - Версия формата EnterpriseData 1_10_2

## Использование:
Подключите расширение стандартным способом через конфигуратор. Снимите флажки "Безопасный режим" и "Защита от опасных действий".

## Пояснение:
- Исправляет ошибки при выгрузке данных из Штрих-М: Торговое предприятие, редакция 7.0. Обращение к реквизитам ссылки "СправочникСсылка.ГТД" через точку, когда она может быть NULL.


- Добавлена проверка заполнения организации в форме элемента договора контрагента, т.к. при обмене обязательное поле "Организация", ключевого свойства "Договор", формата EnterpriseData должно быть заполнено.
Если в существующих договорах не заполнена организация, то заполните используя, например, групповую обработку реквизитов.
