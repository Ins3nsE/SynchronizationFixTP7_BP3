# SynchronizationFixTP7_BP3 
Расширение для Штрих-М: Торговое предприятие, редакция 7.0.
Исправляет синхронизацию между Штрих-М ТП7 и Бухгалтерия 3.0 через EnterpriseData.

Тестировалось на Штрих-М: Торговое предприятие, редакция 7.0 (7.0.43.1) и Бухгалтерия предприятия редакция 3.0 (3.0.158.23)

Исправляет ошибки при выгрузке данных из Штрих-М: Торговое предприятие, редакция 7.0. Обращение к реквизитам ссылки "СправочникСсылка.ГТД" через точку, когда она может быть NULL.
Добавлена проверка заполнения организации в договорах контрагентов, т.к. при обмене обязательное поле "Организация", ключевого свойства "Договор", формата EnterpriseData должно быть заполнено.
