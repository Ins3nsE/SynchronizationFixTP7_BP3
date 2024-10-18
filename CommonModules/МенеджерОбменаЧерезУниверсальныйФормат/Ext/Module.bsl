﻿
&ИзменениеИКонтроль("ПКО_СписаниеНекондицииОприходование_ПриОтправкеДанных")
Процедура ИО_ПКО_СписаниеНекондицииОприходование_ПриОтправкеДанных(ДанныеИБ, ДанныеXDTO, КомпонентыОбмена, СтекВыгрузки)
	НомерБезПрефикса = Прав(ДанныеИБ.Номер, 6);
	НомерДокумента = КомпонентыОбмена.УзелКорреспондента.ПрефиксНомераДокументов + "НО-" + НомерБезПрефикса;

	Если ЗначениеЗаполнено(ДанныеИБ.Фирма) Тогда
		Организация = ДанныеИБ.Фирма;
	Иначе
		Организация = КомпонентыОбмена.УзелКорреспондента.Организация;
	КонецЕсли;

	Если ЗначениеЗаполнено(ДанныеИБ.Склад.Подразделение) Тогда 
		Подразделение = ДанныеИБ.Склад.Подразделение;
	Иначе
		Подразделение = КомпонентыОбмена.УзелКорреспондента.Подразделение;
	КонецЕсли;

	СтатьяДоходов = КомпонентыОбмена.УзелКорреспондента.СтатьяДоходов;

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	УчетнаяПолитикаОрганизацийСрезПоследних.ЯвляетсяПлательщикомНДС КАК ЯвляетсяПлательщикомНДС
	|ИЗ
	|	РегистрСведений.УчетнаяПолитикаОрганизаций.СрезПоследних(&Период, ) КАК УчетнаяПолитикаОрганизацийСрезПоследних
	|ГДЕ
	|	УчетнаяПолитикаОрганизацийСрезПоследних.Организация = &Организация";

	Запрос.УстановитьПараметр("Период", ДанныеИБ.Дата);
	Запрос.УстановитьПараметр("Организация", ДанныеИБ.Фирма);

	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Если Выборка.ЯвляетсяПлательщикомНДС Тогда
			Налогообложение = "ПродажаОблагаетсяНДС";
		Иначе
			Налогообложение = "ПродажаНеОблагаетсяНДС";
		КонецЕсли;	
	Иначе
		Налогообложение = "ПродажаОблагаетсяНДС";
	КонецЕсли;	

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	СписаниеНекондицииТовары.УникальныйНомерСтрокиДокумента КАК УникальныйНомерСтрокиДокумента,
	|	ВЫБОР
	|		КОГДА &ЭтоНТТ
	|			ТОГДА СписаниеНекондицииТовары.РозничнаяСуммаНекондиция
	|		ИНАЧЕ СписаниеНекондицииТовары.ПриходнаяСумма
	|	КОНЕЦ КАК Сумма,
	|	СписаниеНекондицииТовары.КоличествоНекондиция КАК Количество,
	|	ВЫБОР
	|		КОГДА &ЭтоНТТ
	|			ТОГДА СписаниеНекондицииТовары.РозничнаяСуммаНекондиция / (СписаниеНекондицииТовары.КоличествоНекондиция * СписаниеНекондицииТовары.КоэффициентНекондиция)
	|		ИНАЧЕ СписаниеНекондицииТовары.ПриходнаяСумма / (СписаниеНекондицииТовары.КоличествоНекондиция * СписаниеНекондицииТовары.КоэффициентНекондиция)
	|	КОНЕЦ КАК Цена,
	|	СписаниеНекондицииТовары.КоэффициентНекондиция КАК Коэффициент,
	|	СписаниеНекондицииТовары.НоменклатураНекондиция.БазоваяЕдиницаПоКлассификатору КАК ЕдиницаИзмерения,
	|	СписаниеНекондицииТовары.Партия.ГТД КАК ГТД,
	|	СписаниеНекондицииТовары.Партия.СтранаПроисхождения КАК СтранаПроисхождения,
	|	СписаниеНекондицииТовары.Номенклатура.ЕдиницаПрослеживаемости КАК ЕдиницаИзмеренияПрослеживаемости,
	|	СписаниеНекондицииТовары.Номенклатура.ПодлежитПрослеживаемости КАК ПрослеживаемыйТовар,
	|	0 КАК КоличествоРНПТ
	|ПОМЕСТИТЬ ВТ_ТабличнаяЧасть
	|ИЗ
	|	Документ.СписаниеНекондиции.Товары КАК СписаниеНекондицииТовары
	|ГДЕ
	|	СписаниеНекондицииТовары.Ссылка = &Ссылка
	|	И СписаниеНекондицииТовары.Количество > 0
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ОстаткиНоменклатуры.Номенклатура КАК Номенклатура,
	|	СУММА(ОстаткиНоменклатуры.Количество) КАК Количество,
	|	ВЫБОР
	|		КОГДА ОстаткиНоменклатуры.Партия.НаРеализации = ИСТИНА
	|			ТОГДА ""КомиссионныеТовары""
	|		ИНАЧЕ ""СобственныеТовары""
	|	КОНЕЦ КАК ТипЗапасов,
	|	ОстаткиНоменклатуры.УникальныйНомерСтрокиДокумента КАК УникальныйНомерСтрокиДокумента,
	|	ОстаткиНоменклатуры.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры
	|ПОМЕСТИТЬ ВТ_Движения
	|ИЗ
	|	РегистрНакопления.ОстаткиНоменклатуры КАК ОстаткиНоменклатуры
	|ГДЕ
	|	ОстаткиНоменклатуры.Регистратор = &Ссылка
	|	И ОстаткиНоменклатуры.УникальныйНомерСтрокиДокумента В
	|			(ВЫБРАТЬ
	|				ВТ_ТабличнаяЧасть.УникальныйНомерСтрокиДокумента
	|			ИЗ
	|				ВТ_ТабличнаяЧасть КАК ВТ_ТабличнаяЧасть)
	|	И ОстаткиНоменклатуры.Фирма = &Организация
	|	И ОстаткиНоменклатуры.ВидДвижения = ЗНАЧЕНИЕ(ВидДвиженияНакопления.Приход)
	|
	|СГРУППИРОВАТЬ ПО
	|	ОстаткиНоменклатуры.УникальныйНомерСтрокиДокумента,
	|	ОстаткиНоменклатуры.Номенклатура,
	|	ВЫБОР
	|		КОГДА ОстаткиНоменклатуры.Партия.НаРеализации = ИСТИНА
	|			ТОГДА ""КомиссионныеТовары""
	|		ИНАЧЕ ""СобственныеТовары""
	|	КОНЕЦ,
	|	ОстаткиНоменклатуры.ХарактеристикаНоменклатуры
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Движения.Номенклатура КАК Номенклатура,
	|	ВТ_Движения.Количество КАК Количество,
	|	ВЫРАЗИТЬ(ВТ_ТабличнаяЧасть.Цена КАК ЧИСЛО(15, 2)) КАК Цена,
	|	ВЫБОР
	|		КОГДА ВТ_ТабличнаяЧасть.Количество * ВТ_ТабличнаяЧасть.Коэффициент = ВТ_Движения.Количество
	|			ТОГДА ВТ_ТабличнаяЧасть.Сумма
	|		ИНАЧЕ ВЫБОР
	|				КОГДА ВТ_Движения.ТипЗапасов = ""СобственныеТовары""
	|					ТОГДА ВЫРАЗИТЬ(ВТ_ТабличнаяЧасть.Сумма * ВТ_Движения.Количество / (ВТ_ТабличнаяЧасть.Количество * ВТ_ТабличнаяЧасть.Коэффициент) КАК ЧИСЛО(15, 2))
	|				ИНАЧЕ ВТ_ТабличнаяЧасть.Сумма - (ВЫРАЗИТЬ(ВТ_ТабличнаяЧасть.Сумма * (ВТ_ТабличнаяЧасть.Количество * ВТ_ТабличнаяЧасть.Коэффициент - ВТ_Движения.Количество) / (ВТ_ТабличнаяЧасть.Количество * ВТ_ТабличнаяЧасть.Коэффициент) КАК ЧИСЛО(15, 2)))
	|			КОНЕЦ
	|	КОНЕЦ КАК Сумма,
	|	ВТ_Движения.ТипЗапасов КАК ТипЗапасов,
	|	ВТ_ТабличнаяЧасть.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	ВТ_Движения.ХарактеристикаНоменклатуры КАК ХарактеристикаНоменклатуры,
	|	ВТ_ТабличнаяЧасть.ГТД КАК ГТД,
	|	ВТ_ТабличнаяЧасть.СтранаПроисхождения КАК СтранаПроисхождения,
	|	ВТ_ТабличнаяЧасть.ЕдиницаИзмеренияПрослеживаемости КАК ЕдиницаИзмеренияПрослеживаемости,
	|	ВТ_ТабличнаяЧасть.ПрослеживаемыйТовар КАК ПрослеживаемыйТовар,
	|	ВТ_ТабличнаяЧасть.КоличествоРНПТ КАК КоличествоРНПТ,
	|	ВТ_Движения.УникальныйНомерСтрокиДокумента КАК УникальныйНомерСтрокиДокумента
	|ПОМЕСТИТЬ ВТ_Промежуточная
	|ИЗ
	|	ВТ_Движения КАК ВТ_Движения
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ТабличнаяЧасть КАК ВТ_ТабличнаяЧасть
	|		ПО ВТ_Движения.УникальныйНомерСтрокиДокумента = ВТ_ТабличнаяЧасть.УникальныйНомерСтрокиДокумента
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Промежуточная.Номенклатура КАК Номенклатура,
	|	ВТ_Промежуточная.Количество КАК Количество,
	|	ВТ_Промежуточная.Цена КАК Цена,
	|	ВТ_Промежуточная.Сумма КАК Сумма,
	|	ВТ_Промежуточная.ТипЗапасов КАК ТипЗапасов,
	|	ВТ_Промежуточная.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	ВТ_Промежуточная.ХарактеристикаНоменклатуры КАК Характеристика,
	|	ВТ_Промежуточная.ГТД КАК ГТД,
	|	ВТ_Промежуточная.СтранаПроисхождения КАК СтранаПроисхождения,
	|	ВТ_Промежуточная.ЕдиницаИзмеренияПрослеживаемости КАК ЕдиницаИзмеренияПрослеживаемости,
	|	ВТ_Промежуточная.ПрослеживаемыйТовар КАК ПрослеживаемыйТовар,
	|	ВТ_Промежуточная.КоличествоРНПТ КАК КоличествоРНПТ,
	|	ВТ_Промежуточная.УникальныйНомерСтрокиДокумента КАК УникальныйНомерСтрокиДокумента
	|ИЗ
	|	ВТ_Промежуточная КАК ВТ_Промежуточная
	|ГДЕ
	|	ВТ_Промежуточная.Количество > 0
	|	И ВТ_Промежуточная.Сумма > 0";

	Запрос.УстановитьПараметр("Организация", Организация); 
	Запрос.УстановитьПараметр("ЭтоНТТ", ЭтоНТТ(ДанныеИБ.Склад, ДанныеИБ.Дата)); 
	Запрос.УстановитьПараметр("Ссылка", ДанныеИБ.Ссылка);
	ТаблицаТоварыПромежуточная = Запрос.Выполнить().Выгрузить();  

	ТаблицаТоварыПромежуточная.Колонки.Добавить("НомерГТД");

	ТаблицаТовары = ТаблицаТоварыПромежуточная.СкопироватьКолонки();

	ТаблицаПрослеживаемости = ДанныеИБ.Ссылка.Прослеживаемости.Выгрузить();

	Для Каждого СторокаТаблицы Из ТаблицаТоварыПромежуточная Цикл

		СуммаПоПозиции = СторокаТаблицы.Сумма;
		НарастающийИтогСумма = 0;
		КоличествоПоПозиции = СторокаТаблицы.Количество; 
		УбывающийИтогКоличество = СторокаТаблицы.Количество;

		Если СторокаТаблицы.ПрослеживаемыйТовар = Истина Тогда
			СтрокиПрослеживаемости = ТаблицаПрослеживаемости.НайтиСтроки(Новый Структура("УникальныйНомерСтрокиДокумента", СторокаТаблицы.УникальныйНомерСтрокиДокумента));

			Для Каждого СтрокаТаблицыПрослежеваемости Из СтрокиПрослеживаемости Цикл

				Если СтрокаТаблицыПрослежеваемости.КоличествоБазовое = 0 Тогда
					Продолжить;
				КонецЕсли;	
				Если УбывающийИтогКоличество = 0 Тогда
					Прервать;
				КонецЕсли;	
				Если УбывающийИтогКоличество = СтрокаТаблицыПрослежеваемости.КоличествоБазовое Тогда
					НоваяСтрока = ТаблицаТовары.Добавить();
					ЗаполнитьЗначенияСвойств(НоваяСтрока, СторокаТаблицы);
					НоваяСтрока.КоличествоРНПТ = СтрокаТаблицыПрослежеваемости.КоличествоБазовое;
					НоваяСтрока.НомерГТД = Новый Структура("ИмяПКО,Значение", "СправочникНомерГТД", Новый Структура("Ссылка, НомерГТД, СтранаПроисхождения, ЯвляетсяРНПТ,", СтрокаТаблицыПрослежеваемости.РНПТ, СтрокаТаблицыПрослежеваемости.РНПТ.НомерГТД, СтрокаТаблицыПрослежеваемости.РНПТ.СтранаПроисхождения, СтрокаТаблицыПрослежеваемости.РНПТ.ЭтоРНПТ)); 
					НоваяСтрока.СтранаПроисхождения = СтрокаТаблицыПрослежеваемости.РНПТ.СтранаПроисхождения;
					НоваяСтрока.Количество = УбывающийИтогКоличество;
					НоваяСтрока.Сумма = НоваяСтрока.Количество * НоваяСтрока.Цена;
					НарастающийИтогСумма = НарастающийИтогСумма + НоваяСтрока.Сумма; 
					УбывающийИтогКоличество = 0;
					СтрокаТаблицыПрослежеваемости.КоличествоБазовое = 0; 
					Если НарастающийИтогСумма <> СуммаПоПозиции Тогда
						ДельтаСумма = СуммаПоПозиции - НарастающийИтогСумма;
						НоваяСтрока.Сумма = НоваяСтрока.Количество * НоваяСтрока.Цена + ДельтаСумма; 
					КонецЕсли;	
				ИначеЕсли УбывающийИтогКоличество > СтрокаТаблицыПрослежеваемости.КоличествоБазовое Тогда
					НоваяСтрока = ТаблицаТовары.Добавить();
					ЗаполнитьЗначенияСвойств(НоваяСтрока, СторокаТаблицы);
					НоваяСтрока.КоличествоРНПТ = СтрокаТаблицыПрослежеваемости.КоличествоБазовое;
					НоваяСтрока.НомерГТД = Новый Структура("ИмяПКО,Значение", "СправочникНомерГТД", Новый Структура("Ссылка, НомерГТД, СтранаПроисхождения, ЯвляетсяРНПТ,", СтрокаТаблицыПрослежеваемости.РНПТ, СтрокаТаблицыПрослежеваемости.РНПТ.НомерГТД, СтрокаТаблицыПрослежеваемости.РНПТ.СтранаПроисхождения, СтрокаТаблицыПрослежеваемости.РНПТ.ЭтоРНПТ)); 
					НоваяСтрока.СтранаПроисхождения = СтрокаТаблицыПрослежеваемости.РНПТ.СтранаПроисхождения;
					НоваяСтрока.Количество = СтрокаТаблицыПрослежеваемости.КоличествоБазовое;
					НоваяСтрока.Сумма = НоваяСтрока.Количество * НоваяСтрока.Цена;
					НарастающийИтогСумма = НарастающийИтогСумма + НоваяСтрока.Сумма; 
					УбывающийИтогКоличество = УбывающийИтогКоличество - СтрокаТаблицыПрослежеваемости.КоличествоБазовое;
					СтрокаТаблицыПрослежеваемости.КоличествоБазовое = 0; 
				ИначеЕсли УбывающийИтогКоличество < СтрокаТаблицыПрослежеваемости.КоличествоБазовое Тогда	
					НоваяСтрока = ТаблицаТовары.Добавить();
					ЗаполнитьЗначенияСвойств(НоваяСтрока, СторокаТаблицы);
					НоваяСтрока.КоличествоРНПТ = УбывающийИтогКоличество;
					НоваяСтрока.НомерГТД = Новый Структура("ИмяПКО,Значение", "СправочникНомерГТД", Новый Структура("Ссылка, НомерГТД, СтранаПроисхождения, ЯвляетсяРНПТ,", СтрокаТаблицыПрослежеваемости.РНПТ, СтрокаТаблицыПрослежеваемости.РНПТ.НомерГТД, СтрокаТаблицыПрослежеваемости.РНПТ.СтранаПроисхождения, СтрокаТаблицыПрослежеваемости.РНПТ.ЭтоРНПТ)); 
					НоваяСтрока.СтранаПроисхождения = СтрокаТаблицыПрослежеваемости.РНПТ.СтранаПроисхождения;
					НоваяСтрока.Количество = УбывающийИтогКоличество;
					НоваяСтрока.Сумма = НоваяСтрока.Количество * НоваяСтрока.Цена;
					НарастающийИтогСумма = НарастающийИтогСумма + НоваяСтрока.Сумма; 
					СтрокаТаблицыПрослежеваемости.КоличествоБазовое = СтрокаТаблицыПрослежеваемости.КоличествоБазовое - УбывающийИтогКоличество; 
					УбывающийИтогКоличество = 0;
					Если НарастающийИтогСумма <> СуммаПоПозиции Тогда
						ДельтаСумма = СуммаПоПозиции - НарастающийИтогСумма;
						НоваяСтрока.Сумма = НоваяСтрока.Количество * НоваяСтрока.Цена + ДельтаСумма; 
					КонецЕсли;	
				КонецЕсли;
			КонецЦикла;	
		Иначе	
			НоваяСтрока = ТаблицаТовары.Добавить();
			ЗаполнитьЗначенияСвойств(НоваяСтрока, СторокаТаблицы);
			#Удаление
			НоваяСтрока.НомерГТД = Новый Структура("ИмяПКО,Значение", "СправочникНомерГТД", Новый Структура("Ссылка, НомерГТД, СтранаПроисхождения, ЯвляетсяРНПТ,", СторокаТаблицы.ГТД, СторокаТаблицы.ГТД.НомерГТД, СторокаТаблицы.ГТД.СтранаПроисхождения, СторокаТаблицы.ГТД.ЭтоРНПТ));
			#КонецУдаления
			#Вставка
			НоваяСтрока.НомерГТД = Новый Структура("ИмяПКО,Значение", "СправочникНомерГТД", Новый Структура("Ссылка, НомерГТД, СтранаПроисхождения, ЯвляетсяРНПТ," 
													,?(СторокаТаблицы.ГТД = Null, Справочники.ГТД.ПустаяСсылка(), СторокаТаблицы.ГТД)
													,?(СторокаТаблицы.ГТД = Null, "", СторокаТаблицы.ГТД.НомерГТД), 
													,?(СторокаТаблицы.ГТД = Null, Справочники.СтраныМира.ПустаяСсылка(), СторокаТаблицы.ГТД.СтранаПроисхождения)
													,?(СторокаТаблицы.ГТД = Null, Ложь, СторокаТаблицы.ГТД.ЭтоРНПТ)));
			#КонецВставки
		КонецЕсли;	
	КонецЦикла;	

	Если КомпонентыОбмена.УзелКорреспондента.СворачиватьТЧДокументовПоТоварамИзСтавокНДС Или ЭтоНТТ(ДанныеИБ.Склад, ДанныеИБ.Дата) Тогда
		КолонкиГруппировок = "Номенклатура, ЕдиницаИзмерения, ТипЗапасов";
		КолонкиСуммирования = "Количество, Цена, Сумма";
		ТаблицаТовары = ПроизвестиСверткуКоллекцииОбъектовПоНоменклатуре(ТаблицаТовары, КолонкиГруппировок, КолонкиСуммирования, "СписаниеНекондицииОприходование", Неопределено);
	КонецЕсли;

	ТаблицаДопРеквизитов = Новый ТаблицаЗначений;
	ТаблицаДопРеквизитов.Колонки.Добавить("Свойство");
	ТаблицаДопРеквизитов.Колонки.Добавить("ЗначениеСвойства");

	НоваяСтрока = ТаблицаДопРеквизитов.Добавить();
	НоваяСтрока.Свойство = "Номер ТП7";
	НоваяСтрока.ЗначениеСвойства = ДанныеИБ.Номер;

	НоваяСтрока = ТаблицаДопРеквизитов.Добавить();
	НоваяСтрока.Свойство = "Вид документа ТП7";
	НоваяСтрока.ЗначениеСвойства = "Списание некондиции";

	Если КомпонентыОбмена.УзелКорреспондента.ВыгружатьНомерДокумента Тогда 
		ДанныеXDTO.Вставить("ДополнительныеРеквизиты", ТаблицаДопРеквизитов);
	КонецЕсли;

	ДанныеXDTO.КлючевыеСвойства.Вставить("Организация", Организация);
	Если ТаблицаТовары.Количество() > 0 Тогда
		ДанныеXDTO.Вставить("Товары", ТаблицаТовары);
	КонецЕсли;	
	ДанныеXDTO.Вставить("СтатьяДоходов", СтатьяДоходов);
	ДанныеXDTO.КлючевыеСвойства.Вставить("Номер", НомерДокумента);
	ДанныеXDTO.Вставить("Подразделение", Подразделение);
	ДанныеXDTO.Вставить("Налогообложение", Налогообложение);
КонецПроцедуры

&ИзменениеИКонтроль("ПодготовитьДанныеКонтактнаяИнформация")
Процедура ИО_ПодготовитьДанныеКонтактнаяИнформация(КомпонентыОбмена, ДанныеИБ, ДанныеXDTO)
	Если ДанныеИБ.КонтактнаяИнформация.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;

	ТабКонтактнаяИнформация = Новый ТаблицаЗначений;
	ТабКонтактнаяИнформация.Колонки.Добавить("ЗначенияПолей");
	ТабКонтактнаяИнформация.Колонки.Добавить("ВидКонтактнойИнформации");
	ТабКонтактнаяИнформация.Колонки.Добавить("НаименованиеКонтактнойИнформации");

	Для Каждого СтрокаКИ ИЗ ДанныеИБ.КонтактнаяИнформация Цикл
		Если НЕ ЗначениеЗаполнено(СтрокаКИ.Вид)	ИЛИ (НЕ ЗначениеЗаполнено(СтрокаКИ.ЗначенияПолей) И НЕ ЗначениеЗаполнено(СтрокаКИ.Представление)) Тогда
			Продолжить;
		КонецЕсли;  
		
		#Удаление
		Если СтрокаКИ.Вид = Справочники.ВидыКонтактнойИнформации.ДанныеОтветственногоУКонтрагента 
			Или СтрокаКИ.Вид = Справочники.ВидыКонтактнойИнформации.ДругаяИнформацияКонтрагента 
			Или СтрокаКИ.Вид = Справочники.ВидыКонтактнойИнформации.ДругаяИнформацияОрганизации Тогда
			Продолжить;
		КонецЕсли;
		#КонецУдаления
		
		#Вставка
		Если СтрокаКИ.Вид = Справочники.ВидыКонтактнойИнформации.ДанныеОтветственногоУКонтрагента 
			Или СтрокаКИ.Вид = Справочники.ВидыКонтактнойИнформации.ДругаяИнформацияКонтрагента 
			Или СтрокаКИ.Вид = Справочники.ВидыКонтактнойИнформации.ДругаяИнформацияОрганизации
			Или СтрокаКИ.Вид = Справочники.ВидыКонтактнойИнформации.ИдентификаторТелеграмКонтрагента Тогда
			Продолжить;
		КонецЕсли;
		#КонецВставки

		СвойстваВидаКИ = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(СтрокаКИ.Вид, "Наименование,Предопределенный");

		Если СвойстваВидаКИ.Предопределенный = Ложь Тогда
			Продолжить;
		КонецЕсли;	

		ПравилаКонвертацииПредопределенныхДанных = КомпонентыОбмена.ПравилаКонвертацииПредопределенныхДанных;
		ПравилоКонвертации = ПравилаКонвертацииПредопределенныхДанных.Найти("ВидыКонтактнойИнформации", "ИмяПКПД");
		Если ПравилоКонвертации = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		СтрокаТЗКИ = ТабКонтактнаяИнформация.Добавить();
		СтрокаТЗКИ.ВидКонтактнойИнформации = СтрокаКИ.Вид;

		Если Лев(СокрЛ(СтрокаКИ.ЗначенияПолей),1) = "<" Тогда
			// КИ в правильном формате.
			СтрокаТЗКИ.ЗначенияПолей = СокрЛП(СтрокаКИ.ЗначенияПолей);
		Иначе
			ЗначенияПолей = "";
			// Попытка №1.
			Если ЗначениеЗаполнено(СокрЛП(СтрокаКИ.ЗначенияПолей)) Тогда 
				ЗначенияПолей = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияВXML(СокрЛП(СтрокаКИ.ЗначенияПолей), СокрЛП(СтрокаКИ.Представление), СтрокаКИ.Вид);
			КонецЕсли;
			Если Лев(СокрЛ(ЗначенияПолей),1) <> "<" Тогда
				// Попытка №2.
				ЗначенияПолей = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияXMLПоПредставлению(СокрЛП(СтрокаКИ.Представление), СтрокаКИ.Вид);
			КонецЕсли;
			СтрокаТЗКИ.ЗначенияПолей = ЗначенияПолей;
		КонецЕсли;

	КонецЦикла;

	ДанныеXDTO.Вставить("КонтактнаяИнформация", ТабКонтактнаяИнформация);
КонецПроцедуры
