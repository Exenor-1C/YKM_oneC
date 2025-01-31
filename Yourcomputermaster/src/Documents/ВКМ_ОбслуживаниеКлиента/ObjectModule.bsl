
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	
	ПроверкаПройдена = ПроверкаДоговораАбонентскойПлаты(Ссылка, Дата);
	
	Если НЕ ПроверкаПройдена Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	Если Не ЭтоНовый() Тогда
		ДанныеСсылка = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, "ДатаПроведенияРабот, Сотрудник, ВремяНачалаРаботПлан");
		
		Если ДанныеСсылка.ДатаПроведенияРабот <> ДатаПроведенияРабот Или
			ДанныеСсылка.Сотрудник <> Сотрудник Или
			ДанныеСсылка.ВремяНачалаРаботПлан <> ВремяНачалаРаботПлан Тогда
			Текст = СтрШаблон("Корректировка по заказу № %1!
			|Сотрудник: %2
			|Клиент: %3
			|Дата проведения работ: %4
			|Время (План) %5
			|Проблема : %6",Номер, Сотрудник, Клиент, ДатаПроведенияРабот, Формат(ВремяНачалаРаботПлан, "ДЛФ=T;"), ОписаниеПроблемы);
		КонецЕсли;
	ИначеЕсли ЭтоНовый() Тогда
		Текст = СтрШаблон("Появился новый заказ!
		|Сотрудник: %1
		|Клиент: %2
		|Дата проведения работ: %3
		|Время (План) %4
		|Проблема : %5", Сотрудник, Клиент, ДатаПроведенияРабот, Формат(ВремяНачалаРаботПлан, "ДЛФ=T;"), ОписаниеПроблемы);
	КонецЕсли;
		
	Элемент = Справочники.ВКМ_УведомленияТелеграммБоту.СоздатьЭлемент();
	Элемент.ТекстСообщения = Текст;
	Элемент.Записать();
	
КонецПроцедуры


Процедура ОбработкаПроведения(Отказ, Режим)
	
	СтавкаЧаса = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Договор,"СтавкаЧас" );
	Движения.ВКМ_ВыполненныеСотрудникомРаботы.Записывать = Истина;
	Движения.ВКМ_ВыполненныеСотрудникомРаботы.Записать();
	Движения.ВКМ_ВыполненныеКлиентуРаботы.Записывать = Истина;
	Движения.ВКМ_ВыполненныеКлиентуРаботы.Записать();
	
	Процент = РегистрыСведений.ВКМ_УсловияОплатыСотрудников.ПроверкаПроцентаОплатыОтРабот(Сотрудник, МоментВремени().Дата);
	Если Процент = Неопределено Тогда
		ОбщегоНазначения.СообщитьПользователю("У данного сотрудника не установлен пройент от работы!
		|Проведение документа невозможно!");
		ОтменитьТранзакцию();
		Возврат;
	КонецЕсли;
	
	Для Каждого Строка Из ВыполненныеРаботы Цикл
		
		ДвижениеКлиент = Движения.ВКМ_ВыполненныеКлиентуРаботы.Добавить();
		ДвижениеКлиент.Период = Дата;
		ДвижениеКлиент.Клиент = Клиент;
		ДвижениеКлиент.Договор = Договор;
		ДвижениеКлиент.КоличествоЧасов = Строка.ЧасыКОплатеКлиенту;
		ДвижениеКлиент.СуммаКОплате = СтавкаЧаса * Строка.ЧасыКОплатеКлиенту;
		
		ДвижениеСотрудник = Движения.ВКМ_ВыполненныеСотрудникомРаботы.Добавить();
		ДвижениеСотрудник.Период = Дата;
		ДвижениеСотрудник.ДатаПроведенияРабот = ДатаПроведенияРабот;
		ДвижениеСотрудник.Сотрудник = Сотрудник;
		ДвижениеСотрудник.ЧасовКОплате = Строка.ЧасыКОплатеКлиенту;
		
		Если Процент = 0 Тогда
			ДвижениеСотрудник.СуммаКОплате = 0;
		Иначе
			ДвижениеСотрудник.СуммаКОплате = Строка.ЧасыКОплатеКлиенту * СтавкаЧаса * Процент / 100;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПроверкаДоговораАбонентскойПлаты(ДанныеЗаполнения, ДатаДок)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ДоговорыКонтрагентов.ВидДоговора,
	|	ДоговорыКонтрагентов.ДействуетДо
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	ДоговорыКонтрагентов.Ссылка = &Ссылка
	|	И ДоговорыКонтрагентов.ВидДоговора = ЗНАЧЕНИЕ(Перечисление.ВидыДоговоровКонтрагентов.АбонентскаяПлата)
	|	И &ДатаДокумента МЕЖДУ ДоговорыКонтрагентов.Дата И ДоговорыКонтрагентов.ДействуетДо";
	Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);
	Запрос.УстановитьПараметр("ДатаДокумента", ДатаДок);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции

#КонецОбласти

#КонецЕсли
